//
//  OPEOSMAPIManager.m
//  OSM POI Editor
//
//  Created by David on 6/6/13.
//
//

#import "OPEOSMAPIManager.h"
#import "OPEConstants.h"
#import "OPEAPIConstants.h"
#import "OPEChangeset.h"
#import "OPEUtility.h"

#import "OPEOSMUser.h"

#import "OPEGeo.h"
#import "OPEOSMRequestSerializer.h"

#import "OPELog.h"
#import "OSMStreamParser.h"
#import "AFOAuth1Client.h"
#import "OPEConstants.h"

NSString *const putMethod = @"PUT";
NSString *const deleteMethod = @"DELETE";

@interface OPEOSMAPIManager ()

@property (nonatomic,strong) NSMutableDictionary * apiFailures;
@property (nonatomic,strong) NSMutableDictionary * nominatimFailures;

@property (nonatomic, strong) OSMStreamParser *streamParser;

@property (nonatomic, strong) AFOAuth1Token *oAuthToken;

@end

@implementation OPEOSMAPIManager

-(id)init
{
    if(self = [super init])
    {
        self.apiFailures = [NSMutableDictionary dictionary];
        self.nominatimFailures = [NSMutableDictionary dictionary];
    }
    return self;
}

- (AFOAuth1Token *)oAuthToken
{
    if (!_oAuthToken) {
        _oAuthToken = [AFOAuth1Token retrieveCredentialWithIdentifier:kOPEUserOAuthTokenKey];
    }
    return _oAuthToken;
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
            DDLogError(@"Notes Download failed");
            failure(error);
        }
    }];
    
//    [httpRequestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        DDLogInfo(@"Bytes Read: %lu\nTotalBytesRead: %lld\nExpected: %lld",(unsigned long)bytesRead,totalBytesRead,totalBytesExpectedToRead);
//    }];
    
    [httpRequestOperation start];
}

-(void)downloadStreamWithSW:(CLLocationCoordinate2D)southWest NE:(CLLocationCoordinate2D)northEast
                    success:(void (^)(NSData * response))success
                    failure:(void (^)(NSError *error))failure
{
    self.streamParser = [[OSMStreamParser alloc] init];
    
    OPEBoundingBox * bbox = [OPEBoundingBox boundingBoxSW:southWest NE:northEast];
    
    NSURL* url = [self downloadURLWithBoundingBox:bbox];
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:20];
    
    
    //[AFXMLRequestOperation addAcceptableContentTypes:];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    requestOperation.responseSerializer=[AFHTTPResponseSerializer serializer];
    requestOperation.outputStream = self.streamParser.outputStream;
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successful");
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSLog(@"Error: %@", error);
    }];
    
    [requestOperation start];
    
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
//    [requestOperation setDownloadProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
//        DDLogVerbose(@"Bytes Read: %lu\nTotalBytesRead: %lld\nExpected: %lld",(unsigned long)bytesRead,totalBytesRead,totalBytesExpectedToRead);
//    }];
    
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [self.apiFailures setObject:[NSNumber numberWithInt:1] forKey:[operation.request.URL.absoluteString componentsSeparatedByString:@"bbox"][0]];
        if ([self.apiFailures count] < 5) {
            [self downloadDataWithSW:southWest NE:northEast success:success failure:failure];
        }
        else if (failure)
        {
            DDLogError(@"Failed Download after 5 tries");
            [self.apiFailures removeAllObjects];
            failure(error);
        }
        
        
    }];
    [requestOperation start];
    
    DDLogInfo(@"Download URL %@",url);
    
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
        [self.nominatimFailures setObject:[NSNumber numberWithBool:YES] forKey:[operation.request.URL.absoluteString componentsSeparatedByString:@"reverse"][0]];
        if ([self.apiFailures count] < 2) {
            [self reverseLookupAddress:coordinate success:success failure:failure];
        }
        else if (failure)
        {
            [self.nominatimFailures removeAllObjects];
            failure(error);
        }
    }];
    [jsonOperation start];
}

-(NSURL *)nominatimURLWithCoordinate:(CLLocationCoordinate2D)coordinate
{
    NSURL * finalURL;
    NSString * baseUrlString;
    switch ([self.nominatimFailures count]) {
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
    switch ([self.apiFailures count]) {
        case 0:
            baseURLString = kOPEAPIURL1;
            break;
        case 1:
            baseURLString = kOPEAPIURL2;
            break;
        case 2:
            baseURLString = kOPEAPIURL3;
            break;
        case 3:
            baseURLString = kOPEAPIURL4;
            break;
        case 4:
            baseURLString = kOPEAPIURL5;
            break;
        default:
            break;
    }
    
    if ([baseURLString rangeOfString:@"xapi?*"].location != NSNotFound) {
        finalUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@[bbox=%f,%f,%f,%f][@meta]",baseURLString,bbox.left,bbox.bottom,bbox.right,bbox.top]];
    }
    else
    {
        finalUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@map?bbox=%f,%f,%f,%f",baseURLString,bbox.left,bbox.bottom,bbox.right,bbox.top]];
        
    }
    return finalUrl;
}

-(void)uploadElement:(OPEOsmElement *)element
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
        } failure:^(OPEOsmElement * element,NSError *error) {
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
    
    NSError * error = nil;
    NSMutableURLRequest *request = [self.httpClient.requestSerializer requestWithMethod:putMethod URLString:[[NSURL URLWithString:@"changeset/create" relativeToURL:self.httpClient.baseURL] absoluteString] parameters:nil error:&error];
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

-(void)uploadElements:(OPEChangeset *)changeset success:(void (^)(NSArray * elements))success failure:(void (^)(OPEOsmElement * element, NSError * error))failure
{
    if (!changeset.changesetID && failure) {
        failure(nil,nil);
    }
    NSMutableArray * requestOperations = [NSMutableArray array];
    NSArray * elements =  @[changeset.nodes,changeset.ways,changeset.relations];
    for( NSArray * elmentArray in elements)
    {
        for(OPEOsmElement * element in elmentArray)
        {
            if([element.action isEqualToString:kActionTypeDelete])
            {
                AFHTTPRequestOperation * deleteOperation = [self deleteRequestOperationWithElement:element changeset:changeset.changesetID success:^(OPEOsmElement *Element) {
                    if (success) {
                        success(@[element]);
                    }
                } failure:^(OPEOsmElement * element,NSError *error) {
                    if (failure) {
                        failure(element,error);
                    }
                }];
                
                [requestOperations addObject:deleteOperation];
            }
            else if([element.action isEqualToString:kActionTypeModify])
            {
                AFHTTPRequestOperation * updateOperation = [self uploadRequestOperationWithElement:element changeset:changeset.changesetID success:^(OPEOsmElement *element) {
                    if (success) {
                        success(@[element]);
                    }
                } failure:^(OPEOsmElement * element,NSError *error) {
                    if (failure) {
                        failure(element,error);
                    }
                }];
                
                [requestOperations addObject:updateOperation];
                
            }
        }
    }
    
    NSArray * batched = [AFURLConnectionOperation batchOfRequestOperations:requestOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        DDLogInfo(@"uploaded: %lu/%lu",(unsigned long)numberOfFinishedOperations,(unsigned long)totalNumberOfOperations);
    } completionBlock:nil];
    
    [self.httpClient.operationQueue addOperations:batched waitUntilFinished:NO];
    
}

-(void)closeChangeset:(int64_t) changesetNumber
              success:(void (^)(id response))success
              failure:(void (^)(NSError * error))failure
{
    NSString * path = [NSString stringWithFormat:@"changeset/%lld/close",changesetNumber];
    
    NSError * error = nil;
    NSMutableURLRequest *request = [self.httpClient.requestSerializer requestWithMethod:putMethod URLString:[[NSURL URLWithString:path relativeToURL:self.httpClient.baseURL] absoluteString] parameters:nil error:&error];
    if (error) {
        DDLogWarn(@"Error setting parameters on close changeset");
    }
    
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
  


-(AFHTTPRequestOperation *)uploadRequestOperationWithElement:(OPEOsmElement *) element changeset: (int64_t) changesetNumber success:(void (^)(OPEOsmElement * Element))updateElement failure:(void (^)(OPEOsmElement * element, NSError * error))failure
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
    NSError * error = nil;
    NSMutableURLRequest *urlRequest = [self.httpClient.requestSerializer requestWithMethod:putMethod URLString:[[NSURL URLWithString:path relativeToURL:self.httpClient.baseURL] absoluteString] parameters:nil error:&error];
    if (error) {
        DDLogWarn(@"Error setting request paramters on upload");
    }
    [urlRequest setHTTPBody:xmlData];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"changeset %@",responseObject);
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

-(AFHTTPRequestOperation *)deleteRequestOperationWithElement:(OPEOsmElement *) element changeset: (int64_t) changesetNumber success:(void (^)(OPEOsmElement * Element))updateElement failure:(void (^)(OPEOsmElement * element, NSError * error))failure
{
    NSData * xmlData = [element deleteXMLforChangset:changesetNumber];
    NSString * path = [NSString stringWithFormat:@"%@/%lld",[element osmType],element.element.elementID];
    
    NSError * error = nil;
    NSMutableURLRequest *urlRequest = [self.httpClient.requestSerializer requestWithMethod:deleteMethod URLString:[[NSURL URLWithString:path relativeToURL:self.httpClient.baseURL] absoluteString] parameters:nil error:&error];
    if (error) {
        DDLogWarn(@"Error setting parameters on delete");
    }
    [urlRequest setHTTPBody:xmlData];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    requestOperation.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DDLogInfo(@"changeset %@",responseObject);
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

-(void)createNewNote:(OSMNote *)note
             success:(void (^)(NSData * response))success
             failure:(void (^)(NSError *error))failure
{
    
    NSDictionary * parameters = @{@"lat": @(note.coordinate.latitude),@"lon":@(note.coordinate.longitude),@"text":((OSMComment *)[note.commentsArray lastObject]).text};
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

-(void)createNewComment:(OSMComment *)comment withNote:(OSMNote *)note
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
-(void)closeNote:(OSMNote *)note withComment:(NSString *)comment
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

-(void)reopenNote:(OSMNote *)note
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

- (void)fetchUserInfoWithToken:(AFOAuth1Token *)token completion:(void (^)(BOOL success, id responseObject, NSError *error))completionBlock;
{
    
    
    AFHTTPRequestOperation *requestOperation = [self.httpClient GET:@"user/details" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (completionBlock) {
            completionBlock(YES,responseObject,nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionBlock) {
            completionBlock(NO,nil,error);
        }
    }];
    [requestOperation start];
}

- (void)fetchCurrentUserWithComletion:(void (^)(BOOL success,NSError *error))completionBlock
{
    AFHTTPRequestOperation *requestOperation = [self.httpClient GET:@"user/details" parameters:nil success:^(AFHTTPRequestOperation *operation, id responseObject) {
        
        if ([responseObject isKindOfClass:[NSXMLParser class]]) {
            OPEOSMUser *currentUser = [[OPEOSMUser alloc] initWithParser:responseObject];
            [OPEOSMUser setCurrentUser:currentUser];
        }
        
        if (completionBlock) {
            completionBlock(YES,nil);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        if (completionBlock) {
            completionBlock(NO,error);
        }
    }];
    [requestOperation start];
}

@end
