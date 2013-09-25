//
//  OPEMapManager.h
//  OSM POI Editor
//
//  Created by David on 9/24/13.
//
//

#import <Foundation/Foundation.h>

#import "RMMapViewDelegate.h"
@class OPEOSMData;

@interface OPEMapManager : NSObject <RMMapViewDelegate>
{
    NSMutableDictionary * imageDictionary;
    RMAnnotation * wayAnnotation;
    NSOperationQueue * operationQueue;
}

@property (nonatomic,strong) OPEOSMData * osmData;


-(void)addNotes:(NSArray *)notes withMapView:(RMMapView *)mapView;
-(void)addAnnotationsForOsmElements:(NSArray *)elementsArray withMapView:(RMMapView *)mapView;
-(void)updateAnnotationsForOsmElements:(NSArray *)elementsArray withMapView:(RMMapView *)mapView;


@end
