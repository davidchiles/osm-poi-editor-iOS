//
//  OPEViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"
#import "RMMapViewDelegate.h" 
#import <CoreLocation/CoreLocation.h>
#import "OPENode.h"
#import "OPEOSMData.h"
#import "OPEInfoViewController.h"
#import "CMMarkerWithControlLayer.h"


@interface OPEViewController : UIViewController<RMMapViewDelegate, CMMarkerWithControlLayerDelegate> {
    IBOutlet RMMapView* mapView;
    
}

@property (nonatomic,retain) OPEOSMData * osmData;
@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,retain) OPETagInterpreter * interpreter;

@property (nonatomic,retain) IBOutlet UIButton * infoButton;
@property (nonatomic,retain) IBOutlet UIBarButtonItem * location;
@property (nonatomic,retain) IBOutlet UIBarButtonItem * addOPEPoint;
@property (nonatomic,retain) RMMarker *openMarker;


-(void) addMarkerAt:(CLLocationCoordinate2D) markerPosition withNode:(OPENode *) node;
-(void) addMarkers;

-(IBAction)infoButtonPressed:(id)sender;
-(IBAction)addPointButtonPressed:(id)sender;
-(IBAction)locationButtonPressed:(id)sender;

@end
