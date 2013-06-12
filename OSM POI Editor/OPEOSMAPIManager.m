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

typedef struct {
	double left;
    double right;
	double bottom;
    double top;
} boundingBox;

@implementation OPEOSMAPIManager
@synthesize auth = _auth;
@synthesize httpClient = _httpClient;
@synthesize delegate;

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
    
    if ([delegate respondsToSelector:@selector(willStartDownloading)]) {
        [delegate willStartDownloading];
    }
    
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


-(void)reverseLookupAddress:(CLLocationCoordinate2D)coordinate
{
    NSString * urlString = [NSString stringWithFormat:@"http://open.mapquestapi.com/nominatim/v1/reverse.php?format=json&lat=%@&lon=%@&zoom=18&addressdetails=1",[NSNumber numberWithDouble:coordinate.latitude],[NSNumber numberWithDouble:coordinate.longitude]];
    NSURLRequest * urlRequest = [NSURLRequest requestWithURL:[NSURL URLWithString:urlString]];
    AFJSONRequestOperation * jsonOperation = [AFJSONRequestOperation JSONRequestOperationWithRequest:urlRequest success:^(NSURLRequest *request, NSHTTPURLResponse *response, id JSON) {
        //if ([self.delegate respondsToSelector:@selector(didFindAddress:)]) {
            //[self.delegate didFindAddress:[JSON objectForKey:@"address"]];
        //}
    } failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error, id JSON) {
        NSLog(@"Error!");
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
