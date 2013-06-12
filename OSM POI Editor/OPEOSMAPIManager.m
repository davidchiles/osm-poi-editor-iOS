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

typedef struct {
	double left;
    double right;
	double bottom;
    double top;
} boundingBox;

@implementation OPEOSMAPIManager
@synthesize auth = _auth;
@synthesize httpClient = _httpClient;

-(id)init
{
    if(self = [super init])
    {
        [self auth];
        apiFailures = [NSMutableDictionary dictionary];
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

-(AFHTTPClient *)httpClient
{
    if (!_httpClient) {
        NSString * baseUrl = @"http://api.openstreetmap.org/api/0.6/";
        _httpClient = [[AFHTTPClient alloc] initWithBaseURL:[NSURL URLWithString:baseUrl]];
    }
    return _httpClient;
}

-(void)getDataWithSW:(CLLocationCoordinate2D)southWest NE:(CLLocationCoordinate2D)northEast
             success:(void (^)(NSData * response))success
             failure:(void (^)(NSError *error))failure
{
    boundingBox bbox;
    bbox.left = southWest.longitude;
    bbox.bottom = southWest.latitude;
    bbox.right = northEast.longitude;
    bbox.top = northEast.latitude;
    
    NSURL* url = [self downloadURLWithBoundingBox:bbox];
    NSMutableURLRequest * request =[NSMutableURLRequest requestWithURL:url];
    [request setTimeoutInterval:30];
    
    
    [AFXMLRequestOperation addAcceptableContentTypes:[NSSet setWithObject:@"application/osm3s+xml"]];
    
    AFHTTPRequestOperation * httpRequestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    [httpRequestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        if (success) {
            success(responseObject);
        }
        
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        [apiFailures setObject:[NSNumber numberWithInt:1] forKey:[operation.request.URL.absoluteString componentsSeparatedByString:@"bbox"][0]];
        if ([apiFailures count] < 5) {
            [self getDataWithSW:southWest NE:northEast success:success failure:failure];
        }
        else if (failure)
        {
            NSLog(@"Failed Download after 5 tries");
            [apiFailures removeAllObjects];
            failure(error);
        }
        
        
    }];
    [httpRequestOperation start];
    
    NSLog(@"Download URL %@",url);
    
}

-(void)reverseLookupAddress:(CLLocationCoordinate2D )coordinate
                    success:(void (^)(NSDictionary * addressDictionary))success
                    failure:(void (^)(NSError * error))failure
{
    NSString * urlString = [NSString stringWithFormat:@"http://open.mapquestapi.com/nominatim/v1/reverse.php?format=json&lat=%@&lon=%@&zoom=18&addressdetails=1",[NSNumber numberWithDouble:coordinate.latitude],[NSNumber numberWithDouble:coordinate.longitude]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFJSONRequestOperation * jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        if (success) {
            success([JSON objectForKey:@"address"]);
        }
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        if (failure) {
            failure(error);
        }
    }];
    [jsonOperation start];
}

-(NSURL *)downloadURLWithBoundingBox:(boundingBox)bbox
{
    NSURL * finalUrl;
    NSString * baseURLString;
    switch ([apiFailures count]) {
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
    
    if ([apiFailures count] < 3) {
        finalUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@[bbox=%f,%f,%f,%f][@meta]",baseURLString,bbox.left,bbox.bottom,bbox.right,bbox.top]];
    }
    else
    {
        finalUrl = [NSURL URLWithString: [NSString stringWithFormat:@"%@map?bbox=%f,%f,%f,%f",baseURLString,bbox.left,bbox.bottom,bbox.right,bbox.top]];
        
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
    
    NSMutableURLRequest * urlRequest = [self.httpClient requestWithMethod:@"PUT" path:@"changeset/create" parameters:nil];
    [urlRequest setHTTPBody:changesetData];
    [self.auth authorizeRequest:urlRequest];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
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
    [requestOperation start];
}

-(void)uploadElements:(OPEChangeset *)changeset success:(void (^)(NSArray * elements))success failure:(void (^)(OPEManagedOsmElement * element, NSError * error))failure
{
    if (!changeset.changesetID && failure) {
        failure(nil,nil);
    }
    NSMutableArray * requestOperations = [NSMutableArray array];
    NSMutableArray * updatedElements = [NSMutableArray array];
    NSArray * elements =  @[changeset.nodes,changeset.ways,changeset.relations];
    for( NSArray * elmentArray in elements)
    {
        for(OPEManagedOsmElement * element in elmentArray)
        {
            if([element.action isEqualToString:kActionTypeDelete])
            {
                AFHTTPRequestOperation * deleteOperation = [self deleteRequestOperationWithElement:element changeset:changeset.changesetID success:^(OPEManagedOsmElement *Element) {
                    [updatedElements addObject:element];
                } failure:^(OPEManagedOsmElement * element,NSError *error) {
                    if (failure) {
                        failure(element,error);
                    }
                }];
                
                [requestOperations addObject:deleteOperation];
            }
            else if([element.action isEqualToString:kActionTypeModify])
            {
                AFHTTPRequestOperation * updateOperation = [self uploadRequestOperationWithElement:element changeset:changeset.changesetID success:^(OPEManagedOsmElement *Element) {
                    [updatedElements addObject:element];
                } failure:^(OPEManagedOsmElement * element,NSError *error) {
                    if (failure) {
                        failure(element,error);
                    }
                }];
                
                [requestOperations addObject:updateOperation];
                
            }
        }
    }
    
    [self.httpClient enqueueBatchOfHTTPRequestOperations:requestOperations progressBlock:^(NSUInteger numberOfFinishedOperations, NSUInteger totalNumberOfOperations) {
        NSLog(@"uploaded: %d/%d",numberOfFinishedOperations,totalNumberOfOperations);
        
    } completionBlock:^(NSArray *operations) {
        if (success) {
            success(updatedElements);
        }
    }];
    
    
}

-(void)closeChangeset:(int64_t) changesetNumber
              success:(void (^)(id response))success
              failure:(void (^)(NSError * error))failure
{
    NSString * path = [NSString stringWithFormat:@"changeset/%lld/close",changesetNumber];
    
    NSMutableURLRequest * urlRequest = [self.httpClient requestWithMethod:@"PUT" path:path parameters:nil];
    [self.auth authorizeRequest:urlRequest];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    [requestOperation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
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
    
    NSMutableURLRequest * urlRequest = [self.httpClient requestWithMethod:@"PUT" path:path parameters:nil];
    [urlRequest setHTTPBody:xmlData];
    [self.auth authorizeRequest:urlRequest];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
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
    
    NSMutableURLRequest * urlRequest = [self.httpClient requestWithMethod:@"DELETE" path:path parameters:nil];
    [urlRequest setHTTPBody:xmlData];
    [self.auth authorizeRequest:urlRequest];
    
    AFHTTPRequestOperation * requestOperation = [[AFHTTPRequestOperation alloc] initWithRequest:urlRequest];
    
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
