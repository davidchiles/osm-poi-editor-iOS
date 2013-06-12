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

@protocol OPEOSMAPIManagerDelegate <NSObject>

@optional
-(void)didOpenChangeset:(int64_t)changesetNumber withMessage:(NSString *)message;
-(void)didCloseChangeset:(int64_t)changesetNumber;
-(void)uploadFailed:(NSError *)error;

-(void)willStartDownloading;
-(void)didEndDownloading;

-(void)didFindAddress:(NSDictionary *)addressDictionary;

@end

@interface OPEOSMAPIManager : NSObject

@property (nonatomic,weak) id <OPEOSMAPIManagerDelegate> delegate;

- (void) getDataWithSW:(CLLocationCoordinate2D)southWest NE: (CLLocationCoordinate2D) northEast;
- (void) openChangeset:(OPEChangeset *)changeset;
- (void) closeChangeset: (int64_t) changesetNumber;

- (void) uploadElement: (OPEManagedOsmElement *) element;
- (void) deleteElement: (OPEManagedOsmElement *) element;

-(void)reverseLookupAddress:(CLLocationCoordinate2D)coordinate;

@end
