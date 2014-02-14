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

typedef void (^foundMatchingElements)(NSArray * newElements,NSArray * updatedElements);

@interface OPEDownloadManager : NSObject <OSMDatabaseManagerDelegate>
{
    OPEOSMData * osmData;
    OPEOSMAPIManager * apiManager;
    NSOperationQueue * parseQueue;
}



@property (nonatomic,strong)NSMutableSet * dowloadedAreas;
@property (nonatomic,strong)NSMutableDictionary * notesDictionary;
@property (nonatomic,copy)foundMatchingElements foundMatchingElementsBlock;


- (void)downloadDataWithSW:(CLLocationCoordinate2D)southWest
                     forNE: (CLLocationCoordinate2D) northEast
           didStartParsing:(void (^)(void))startParsing
          didFinsihParsing:(void (^)(void))finishParsing
                    faiure:(void (^)(NSError * error))failure;

- (void)downloadNotesWithSW:(CLLocationCoordinate2D)southWest
                     forNE: (CLLocationCoordinate2D) northEast
           didStartParsing:(void (^)(void))startParsing
          didFinsihParsing:(void (^)(NSArray * newNotes))finishParsing
                    faiure:(void (^)(NSError * error))failure;

- (BOOL)downloadedAreaContainsPoint:(CLLocationCoordinate2D)point;


@end
