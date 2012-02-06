//
//  CMMarkerWithControlLayer.h
//  SponsoredPOIs
//
//  Created by user on 9/15/10.
//  Copyright 2010 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "RMMarker.h"

@class RMMapView;

@protocol CMMarkerWithControlLayerDelegate

-(void)pushMapAnnotationDetailedViewControllerDelegate:(id) sender;

@end


@interface CMMarkerWithControlLayer : RMMarker
{
  NSMutableArray* controlLayers;
  id<CMMarkerWithControlLayerDelegate>	annotationDelegate;
}

@property (nonatomic, retain) NSMutableArray* controlLayers;
@property (nonatomic, retain) id<CMMarkerWithControlLayerDelegate>	annotationDelegate;

-(void) addAnnotationViewWithTitle:(NSString *)title subtitle:(NSString*) subtitle inMapView:(RMMapView*) mapView;
-(void) addAnnotationViewWithPicture:(UIImage*) picture title:(NSString *)title subtitle:(NSString*) subtitle inMapView:(RMMapView*) mapView;

@end
