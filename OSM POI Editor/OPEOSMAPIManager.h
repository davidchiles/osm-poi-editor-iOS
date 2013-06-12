//
//  OPEOSMAPIManager.h
//  OSM POI Editor
//
//  Created by David on 6/6/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

#import "OPEChangeset.h"
#import "OPEManagedOsmElement.h"
#import "GTMOAuthAuthentication.h"
#import "AFNetworking.h"
#import "OPEManagedOsmElement.h"

@interface OPEOSMAPIManager : NSObject
{
    NSMutableDictionary * apiFailures;
}

@property (nonatomic,strong) AFHTTPClient * httpClient;
@property (nonatomic, strong) GTMOAuthAuthentication * auth;

-(void)getDataWithSW:(CLLocationCoordinate2D)southWest NE:(CLLocationCoordinate2D)northEast
             success:(void (^)(NSData * response))success
             failure:(void (^)(NSError *error))failure;

-(void)uploadElement:(OPEManagedOsmElement *)element
withChangesetComment:(NSString *)changesetComment
     openedChangeset:(void (^)(int64_t changesetID))openedChangeset
     updatedElements:(void (^)(NSArray * updatedElements))updatedElements
     closedChangeSet:(void (^)(int64_t changesetID))closedChangeset
             failure:(void (^)(NSError * response))failure;


-(void)reverseLookupAddress:(CLLocationCoordinate2D )coordinate
                    success:(void (^)(NSDictionary * addressDictionary))success
                    failure:(void (^)(NSError * error))failure;

+(GTMOAuthAuthentication *)osmAuth;
-(BOOL) canAuth;

@end
