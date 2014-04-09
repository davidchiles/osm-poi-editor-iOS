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
#import "OPEOsmElement.h"
#import "GTMOAuthAuthentication.h"
#import "AFNetworking.h"
#import "OPEOsmElement.h"
#import "OSMNote.h"
#import "OSMComment.h"




@interface OPEOSMAPIManager : NSObject

@property (nonatomic,strong) AFHTTPRequestOperationManager * httpClient;
@property (nonatomic, strong) GTMOAuthAuthentication * auth;

-(void)downloadDataWithSW:(CLLocationCoordinate2D)southWest NE:(CLLocationCoordinate2D)northEast
             success:(void (^)(NSData * response))success
             failure:(void (^)(NSError *error))failure;
-(void)downloadStreamWithSW:(CLLocationCoordinate2D)southWest NE:(CLLocationCoordinate2D)northEast
                    success:(void (^)(NSData * response))success
                    failure:(void (^)(NSError *error))failure;
-(void)downloadNotesWithSW:(CLLocationCoordinate2D)southWest NE:(CLLocationCoordinate2D)northEast
             success:(void (^)(NSData * response))success
             failure:(void (^)(NSError *error))failure;

-(void)uploadElement:(OPEOsmElement *)element
withChangesetComment:(NSString *)changesetComment
     openedChangeset:(void (^)(int64_t changesetID))openedChangeset
     updatedElements:(void (^)(NSArray * updatedElements))updatedElements
     closedChangeSet:(void (^)(int64_t changesetID))closedChangeset
             failure:(void (^)(NSError * response))failure;


-(void)reverseLookupAddress:(CLLocationCoordinate2D )coordinate
                    success:(void (^)(NSDictionary * addressDictionary))success
                    failure:(void (^)(NSError * error))failure;

/////////////NOTES///////////////
-(void)createNewNote:(OSMNote *)note
             success:(void (^)(NSData * response))success
             failure:(void (^)(NSError *error))failure;

-(void)createNewComment:(OSMComment *)comment
               withNote:(OSMNote *)note
                success:(void (^)(id JSON))success
                failure:(void (^)(NSError *error))failure;

-(void)closeNote:(OSMNote *)note
     withComment:(NSString *)comment
         success:(void (^)(id JSON))success
         failure:(void (^)(NSError *error))failure;
-(void)reopenNote:(OSMNote *)note
         success:(void (^)(NSData * response))success
         failure:(void (^)(NSError *error))failure;

- (void)fetchCurrentUserWithComletion:(void (^)(BOOL success,NSError *error))completionBlock;

+(GTMOAuthAuthentication *)osmAuth;
-(BOOL) canAuth;

@end
