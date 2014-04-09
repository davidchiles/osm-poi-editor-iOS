//
//  OPEDownloadManager.h
//  OSM POI Editor
//
//  Created by David on 9/6/13.
//
//

#import <Foundation/Foundation.h>

#import <CoreLocation/CoreLocation.h>
#import "OPEOSMAPIManager.h"

#import "OPEOSMAPIManager.h"
#import "OPEOSMData.h"

@class OSMNote;

typedef void (^foundMatchingElementsBlock)(NSArray * newElements,NSArray * updatedElements);

@interface OPEDownloadManager : NSObject <OSMDatabaseManagerDelegate>

@property (nonatomic, strong) NSMutableSet * dowloadedAreas;
@property (nonatomic, strong) NSMutableDictionary * notesDictionary;
@property (nonatomic, copy) foundMatchingElementsBlock foundMatchingElementsBlock;


- (void)downloadDataWithSW:(CLLocationCoordinate2D)southWest
                     forNE: (CLLocationCoordinate2D) northEast
           didStartParsing:(void (^)(void))startParsing
          didFinsihParsing:(void (^)(void))finishParsing
                    faiure:(void (^)(NSError * error))failure;

- (void)downloadNotesWithSW:(CLLocationCoordinate2D)southWest
                      forNE: (CLLocationCoordinate2D) northEast
            didStartParsing:(void (^)(void))startParsing
                onFoundNote:(void (^)(OSMNote *note))foundNote
                     faiure:(void (^)(NSError *error))failure;

- (BOOL)downloadedAreaContainsPoint:(CLLocationCoordinate2D)point;


@end
