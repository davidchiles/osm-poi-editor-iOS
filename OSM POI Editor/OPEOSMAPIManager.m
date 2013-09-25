//
//  OPEOSMAPIManager.m
//  OSM POI Editor
//
//  Created by David on 6/6/13.
//
//

#import "OPEOSMAPIManager.h"
#import "GTMOAuthViewControllerTouch.h"
#import "OPEConstants.h"
#import "OPEAPIConstants.h"
#import "OPEChangeset.h"
#import "OPEUtility.h"

#import "OPEGeo.h"
#import "OPEOSMRequestSerializer.h"

#import "OSMParser.h"
@interface NSStream (BoundPairAdditions)
+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize;
@end
@implementation NSStream (BoundPairAdditions)

+ (void)createBoundInputStream:(NSInputStream **)inputStreamPtr outputStream:(NSOutputStream **)outputStreamPtr bufferSize:(NSUInteger)bufferSize
{
    CFReadStreamRef     readStream;
    CFWriteStreamRef    writeStream;
    
    assert( (inputStreamPtr != NULL) || (outputStreamPtr != NULL) );
    
    readStream = NULL;
    writeStream = NULL;
    
    CFStreamCreateBoundPair(
                            NULL,
                            ((inputStreamPtr  != nil) ? &readStream : NULL),
                            ((outputStreamPtr != nil) ? &writeStream : NULL),
                            (CFIndex) bufferSize
                            );
    
    if (inputStreamPtr != NULL) {
        *inputStreamPtr  = CFBridgingRelease(readStream);
    }
    if (outputStreamPtr != NULL) {
        *outputStreamPtr = CFBridgingRelease(writeStream);
    }
}

@end


@implementation OPEOSMAPIManager
@synthesize auth = _auth;
@synthesize httpClient = _httpClient;

-(id)init
{
    if(self = [super init])
    {
        [self auth];
        apiFailures = [NSMutableDictionary dictionary];
        nominatimFailures = [NSMutableDictionary dictionary];
    }
    return self;
}

-(GTMOAuthAuthentication *)auth
{
    if(!_auth)
    {
        _auth = [OPEOSMAPIManager osmAuth];
        [self canAuth];
    }
    return _auth;
    
}

-(BOOL) canAuth;
{
    BOOL didAuth = NO;
    BOOL canAuth = NO;
    if (_auth) {
        didAuth = [GTMOAuthViewControllerTouch authorizeFromKeychainForName:@"OSMPOIEditor" authentication:_auth];
        // if the auth object contains an access token, didAuth is now true
        canAuth = [_auth canAuthorize];
    }
    else {
        return NO;
    }
    return didAuth && canAuth;
    
    
}

-(AFHTTPRequestOperationManager *)httpClient
{
    if (!_httpClient) {
        NSString * baseUrl = @"http://api.openstreetmap.org/api/0.6/";
        _httpClient = [[AFHTTPRequestOperationManager alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
        
        AFXMLParserResponseSerializer * xmlParserResponseSerializer =  [AFXMLParserResponseSerializer serializer];
        NSMutableSet * contentTypes = [xmlParserResponseSerializer.acceptableContentTypes mutableCopy];
        [contentTypes addObject:@"application/osm3s+xml"];
        xmlParserResponseSerializer.acceptableContentTypes = contentTypes;
        _httpClient.responseSerializer = [AFCompoundResponseSerializer compoundSerializerWithResponseSerializers:@[[AFJSONResponseSerializer serializer],xmlParserResponseSerializer]];
        
        OPEOSMRequestSerializer * requestSerializer = [OPEOSMRequestSerializer serializer];
        [requestSerializer setAuth:self.auth];
        [_httpClient setRequestSerializer:requestSerializer];
    }
    return _httpClient;
}

-(void)downloadNotesWithSW:(CLLocationCoordinate2D)southWest NE:(CLLocationCoordinate2D)northEast
                   success:(void (^)(NSData * response))success
                   failure:(void (^)(NSError *error))failure
{
    
    OPEBoundingBox * bbox = [OPEBoundingBox boundingBoxSW:southWest NE:northEast];
    NSString * bboxString = [NSString stringWithFormat:@"%f,%f,%f,%f",bbox.left,bbox.bottom,bbox.right,bbox.top];
    NSDictionary * parametersDictionary = @{@"bbox": bboxString};
    AFHTTPRequestOperation * httpRequestOperation = [self.httpClient GET:@"notes.json" parameters:parametersDictionary success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure)
        {
            NSLog(@"Notes Download failed");
            failure(error);
        }
    }];
    [httpRequestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"Bytes Read: %d\nTotalBytesRead: %lld\nExpected: %lld",bytesRead,totalBytesRead,totalBytesExpectedToRead);
    }];
    
    [httpRequestOperation start];
}

-(void)downloadDataWithSW:(CLLocationCoordinate2D)southWest NE:(CLLocationCoordinate2D)northEast
             success:(void (^)(NSData * response))success
             failure:(void (^)(NSError *error))failure
{
    OPEBoundingBox * bbox = [OPEBoundingBox boundingBoxSW:southWest NE:northEast];
    
    NSURL* url = [self downloadURLWithBoundingBox:bbox];
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:20];
    
    
    //[AFXMLRequestOperation addAcceptableContentTypes:];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer=[AFHTTPResponseSerializer serializer];
    [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        NSLog(@"Bytes Read: %d\nTotalBytesRead: %lld\nExpected: %lld",bytesRead,totalBytesRead,totalBytesExpectedToRead);
    }];
    
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [apiFailures setObject:[NSNumber numberWithInt:1] forKey:[operation.request.URL.absoluteString componentsSeparatedByString:@"bbox"][0]];
        if ([apiFailures count] < 5) {
            [self downloadDataWithSW:southWest NE:northEast success:success failure:failure];
        }
        else if (failure)
        {
            NSLog(@"Failed Download after 5 tries");
            [apiFailures removeAllObjects];
            failure(error);
        }
        
        
    }];
    
    NSOutputStream * outputStream;
    NSInputStream * inpuStream;
    [NSStream createBoundInputStream:&inpuStream outputStream:&outputStream bufferSize:2048];
    requestOperation.outputStream = outputStream;
    OSMParser * parser = [[OSMParser alloc] initWithStream:inpuStream];
    
    [requestOperation start];
    
    NSLog(@"Download URL %@",url);
    
}

-(void)reverseLookupAddress:(CLLocationCoordinate2D )coordinate
                    success:(void (^)(NSDictionary * addressDictionary))success
                    failure:(void (^)(NSError * error))failure
{
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[self nominatimURLWithCoordinate:coordinate]];
    AFHTTPRequestOperation * jsonOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    jsonOperation.responseSerializer = [AFJSONResponseSerializer serializer];
    [jsonOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success([responseObject objectForKey:@"address"]);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [nominatimFailures setObject:[NSNumber numberWithBool:YES] forKey:[operation.request.URL.absoluteString componentsSeparatedByString:@"reverse"][0]];
        if ([apiFailures count] < 2) {
            [self reverseLookupAddress:coordinate success:success failure:failure];
        }
        else if (failure)
        {
            [nominatimFailures removeAllObjects];
            failure(error);
        }
    }];
    [jsonOperation start];
}

-(NSURL *)nominatimURLWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSURL * finalURL;
    NSString * baseUrlString;
    switch ([nominatimFailures count]) {
        case 0:
            baseUrlString = kOPENominatimURL1;
            break;
        default:
            baseUrlString = kOPENominatimURL2;
            break;
    }
    finalURL = [NSURL URLWithString: [NSString stringWithFormat:@"%@?format=json&lat=%@&lon=%@&zoom=18&addressdetails=1",baseUrlString,[NSNumber numberWithDouble:coordinate.latitude],[NSNumber numberWithDouble:coordinate.longitude]]];
    
    return finalURL;
}

-(NSURL *)downloadURLWithBoundingBox:(OPEBoundingBox *)bbox
{
    NSURL * finalUrl;
    NSString * baseURLString;
    NSString * path;
    switch ([apiFailures count]) {
        case 0:
            baseURLString = kOPEAPIURL1;
            finalUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@map?bbox=%f,%f,%f,%f",baseURLString,bbox.left,bbox.bottom,bbox.right,bbox.top]];
            break;
        case 1:
            baseURLString = kOPEAPIURL2;
            finalUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@[bbox=%f,%f,%f,%f][@meta]",baseURLString,bbox.left,bbox.bottom,bbox.right,bbox.top]];
            break;
        case 2:
            baseURLString = kOPEAPIURL3;
            finalUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@[bbox=%f,%f,%f,%f][@meta]",baseURLString,bbox.left,bbox.bottom,bbox.right,bbox.top]];
            break;
        case 3:
            baseURLString = kOPEAPIURL4;
            finalUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@[bbox=%f,%f,%f,%f][@meta]",baseURLString,bbox.left,bbox.bottom,bbox.right,bbox.top]];
            break;
        case 4:
            baseURLString = kOPEAPIURL5;
            finalUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@map?bbox=%f,%f,%f,%f",baseURLString,bbox.left,bbox.bottom,bbox.right,bbox.top]];
            break;
        default:
            break;
    }

    return finalUrl;
}

-(void)uploadElement:(OPEManagedOsmElement *)element
withChangesetComment:(NSString *)changesetComment
     openedChangeset:(void (^)(int64_t changesetID))openedChangeset
     updatedElements:(void (^)(NSArray * updatedElements))updatedElements
     closedChangeSet:(void (^)(int64_t changesetID))closedChangeset
             failure:(void (^)(NSError * response))failure
{
    OPEChangeset * changeset = [[OPEChangeset alloc] init];
    [changeset addElement:element];
    changeset.message = changesetComment;
    
    [self openChangeset:changeset success:^(int64_t changesetID) {
        if (openedChangeset) {
            openedChangeset(changesetID);
        }
        [self uploadElements:changeset success:^(NSArray *elements) {
            if (updatedElements) {
                updatedElements(elements);
            }
            
            [self closeChangeset:changesetID success:^(id response) {
                if (closedChangeset) {
                    closedChangeset(changesetID
                                    );
                }
        } failure:^(NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        } failure:^(OPEManagedOsmElement * element,NSError *error) {
            if (failure) {
                failure(error);
            }
        }];
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
}

-(void)openChangeset:(OPEChangeset *)changeset
             success:(void (^)(int64_t changesetID))success
             failure: (void (^)(NSError * error))failure
{
    NSString * createdByString = [NSString stringWithFormat:@"POI+ (%@) %@",[OPEUtility appVersion],[OPEUtility iOSVersion]];
    
    [changeset.tags setObject:createdByString forKey:@"created_by"];
    [changeset.tags setObject:[OPEUtility tileSourceName] forKey:@"imagery_used"];
    [changeset.tags setObject:[OPEUtility addHTML:changeset.message] forKey:@"comment"];
    
    NSData * changesetData = [[changeset xml] dataUsingEncoding:NSUTF8StringEncoding];
    
    NSMutableURLRequest *request = [self.httpClient.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:@"changeset/create" relativeToURL:self.httpClient.baseURL] absoluteString] parameters:nil];
    [request setHTTPBody:changesetData];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        changeset.changesetID = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] longLongValue];
        if (success) {
            success(changeset.changesetID);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [self.httpClient.operationQueue addOperation:requestOperation];
    [requestOperation start];
}

-(void)uploadElements:(OPEChangeset *)changeset success:(void (^)(NSArray * elements))success failure:(void (^)(OPEManagedOsmElement * element, NSError * error))failure
{
    if (!changeset.changesetID && failure) {
        failure(nil,nil);
    }
    NSMutableArray * requestOperations = [NSMutableArray array];
    NSArray * elements =  @[changeset.nodes,changeset.ways,changeset.relations];
    for( NSArray * elmentArray in elements)
    {
        for(OPEManagedOsmElement * element in elmentArray)
        {
            if([element.action isEqualToString:kActionTypeDelete])
            {
                AFHTTPRequestOperation * deleteOperation = [self deleteRequestOperationWithElement:element changeset:changeset.changesetID success:^(OPEManagedOsmElement *Element) {
                    if (success) {
                        success(@[element]);
                    }
                } failure:^(OPEManagedOsmElement * element,NSError *error) {
                    if (failure) {
                        failure(element,error);
                    }
                }];
                
                [requestOperations addObject:deleteOperation];
            }
            else if([element.action isEqualToString:kActionTypeModify])
            {
                AFHTTPRequestOperation * updateOperation = [self uploadRequestOperationWithElement:element changeset:changeset.changesetID success:^(OPEManagedOsmElement *element) {
                    if (success) {
                        success(@[element]);
                    }
                } failure:^(OPEManagedOsmElement * element,NSError *error) {
                    if (failure) {
                        failure(element,error);
                    }
                }];
                
                [requestOperations addObject:updateOperation];
                
            }
        }
    }
    
    NSArray * batched = [AFURLConnectionOperation batchOfRequestOperations:requestOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"uploaded: %d/%d",numberOfFinishedOperations,totalNumberOfOperations);
    } completionBlock:nil];
    
    [self.httpClient.operationQueue addOperations:batched waitUntilFinished:NO];
    
}

-(void)closeChangeset:(int64_t) changesetNumber
              success:(void (^)(id response))success
              failure:(void (^)(NSError * error))failure
{
    NSString * path = [NSString stringWithFormat:@"changeset/%lld/close",changesetNumber];
    
    NSMutableURLRequest *request = [self.httpClient.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:path relativeToURL:self.httpClient.baseURL] absoluteString] parameters:nil];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [self.httpClient.operationQueue addOperation:requestOperation];
    [requestOperation start];
}
  


-(AFHTTPRequestOperation *)uploadRequestOperationWithElement:(OPEManagedOsmElement *) element changeset: (int64_t) changesetNumber success:(void (^)(OPEManagedOsmElement * Element))updateElement failure:(void (^)(OPEManagedOsmElement * element, NSError * error))failure
{
    NSData * xmlData = [element uploadXMLforChangset:changesetNumber];
    
    NSMutableString * path = [NSMutableString stringWithFormat:@"%@/",[element osmType]];
    int64_t elementOsmID = element.element.elementID;
    
    if (elementOsmID < 0) {
        [path appendString:@"create"];
    }
    else{
        [path appendFormat:@"%lld",element.element.elementID];
    }
    
    
    NSMutableURLRequest *urlRequest = [self.httpClient.requestSerializer requestWithMethod:@"PUT" URLString:[[NSURL URLWithString:path relativeToURL:self.httpClient.baseURL] absoluteString] parameters:nil];
    [urlRequest setHTTPBody:xmlData];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"changeset %@",responseObject);
        int64_t response = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] longLongValue];
        
        if (elementOsmID < 0) {
            element.element.elementID = response;
            element.element.version = 1;
        }
        else{
            element.element.version = response;
        }
        
        if (updateElement) {
            updateElement(element);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(element,error);
        }
    }];
    return requestOperation;
}

-(AFHTTPRequestOperation *)deleteRequestOperationWithElement:(OPEManagedOsmElement *) element changeset: (int64_t) changesetNumber success:(void (^)(OPEManagedOsmElement * Element))updateElement failure:(void (^)(OPEManagedOsmElement * element, NSError * error))failure
{
    NSData * xmlData = [element deleteXMLforChangset:changesetNumber];
    NSString * path = [NSString stringWithFormat:@"%@/%lld",[element osmType],element.element.elementID];
    
    NSMutableURLRequest *urlRequest = [self.httpClient.requestSerializer requestWithMethod:@"DELETE" URLString:[[NSURL URLWithString:path relativeToURL:self.httpClient.baseURL] absoluteString] parameters:nil];
    [urlRequest setHTTPBody:xmlData];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"changeset %@",responseObject);
        NSInteger newVersion = [[[NSString alloc] initWithData:responseObject encoding:NSUTF8StringEncoding] integerValue];
        
        element.element.version = newVersion;
        element.isVisible = NO;
        
        if (updateElement) {
            updateElement(element);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(element,error);
        }
    }];
    
    return requestOperation;
}

-(void)createNewNote:(Note *)note
             success:(void (^)(NSData * response))success
             failure:(void (^)(NSError *error))failure
{
    
    NSDictionary * parameters = @{@"lat": @(note.coordinate.latitude),@"lon":@(note.coordinate.longitude),@"text":((Comment *)[note.commentsArray lastObject]).text};
    AFHTTPRequestOperation * requestOperation = [self.httpClient POST:@"notes.json" parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [requestOperation start];
    
}

-(void)createNewComment:(Comment *)comment withNote:(Note *)note
                success:(void (^)(id JSON))success
                failure:(void (^)(NSError *error))failure
{
    NSDictionary * parameters = @{@"text":comment.text};
    NSString * path = [NSString stringWithFormat:@"notes/%lld/comment.json",note.id];
    
    AFHTTPRequestOperation * requestOperation = [self.httpClient POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    [requestOperation start];

    
}
-(void)closeNote:(Note *)note withComment:(NSString *)comment
         success:(void (^)(id JSON))success
         failure:(void (^)(NSError *error))failure
{
    NSDictionary * parameters = nil;
    if ([comment length]) {
        parameters = @{@"text":comment};
    }
    
    NSString * path = [NSString stringWithFormat:@"notes/%lld/close.json",note.id];
    AFHTTPRequestOperation * requestOperation = [self.httpClient POST:path parameters:parameters success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [requestOperation start];
}

-(void)reopenNote:(Note *)note
          success:(void (^)(NSData * response))success
          failure:(void (^)(NSError *error))failure
{
    NSString * path = [NSString stringWithFormat:@"notes/%lld/reopen.json",note.id];
    AFHTTPRequestOperation * requestOperation = [self.httpClient POST:path parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    [requestOperation start];
    
}

+(GTMOAuthAuthentication *)osmAuth {
    NSString *myConsumerKey = osmConsumerKey; //@"pJbuoc7SnpLG5DjVcvlmDtSZmugSDWMHHxr17wL3";    // pre-registered with service
    NSString *myConsumerSecret = osmConsumerSecret; //@"q5qdc9DvnZllHtoUNvZeI7iLuBtp1HebShbCE9Y1"; // pre-assigned by service
    
    GTMOAuthAuthentication *auth;
    auth = [[GTMOAuthAuthentication alloc] initWithSignatureMethod:kGTMOAuthSignatureMethodHMAC_SHA1
                                                       consumerKey:myConsumerKey
                                                        privateKey:myConsumerSecret];
    
    // setting the service name lets us inspect the auth object later to know
    // what service it is for
    auth.serviceProvider = @"OSMPOIEditor";
    
    return auth;
}

@end

