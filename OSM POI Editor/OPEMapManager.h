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
@class OSMNote;

@interface OPEMapManager : NSObject <RMMapViewDelegate>

@property (nonatomic,strong) OPEOSMData * osmData;

- (void)addNote:(OSMNote *)note withMapView:(RMMapView *)mapView;
- (void)addNotes:(NSArray *)notes withMapView:(RMMapView *)mapView;
- (void)reloadNotesInMapView:(RMMapView *)mapView;

- (void)addAnnotationsForOsmElements:(NSArray *)elementsArray withMapView:(RMMapView *)mapView;
- (void)updateAnnotationsForOsmElements:(NSArray *)elementsArray withMapView:(RMMapView *)mapView;


@end
