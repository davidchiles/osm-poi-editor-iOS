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
#import "OPENodeViewController.h"
#import "OPEMessage.h"

@interface OPEViewController : UIViewController <RMMapViewDelegate, CLLocationManagerDelegate, OPENodeViewDelegate,OPEInfoViewControllerDelegate,MBProgressHUDDelegate > {
    IBOutlet RMMapView* mapView;
    
}

@property (nonatomic,strong) OPEOSMData * osmData;
@property (nonatomic,strong) CLLocationManager* locationManager;
@property (nonatomic,strong) OPETagInterpreter * interpreter;

@property (nonatomic,strong) IBOutlet UIBarButtonItem * infoButton;
@property (nonatomic,strong) IBOutlet UIBarButtonItem * location;
@property (nonatomic,strong) IBOutlet UIBarButtonItem * addOPEPoint;
@property (nonatomic,strong) RMMarker *openMarker;
@property (nonatomic,strong) RMMarker *theNewMarker;
@property (nonatomic,strong) UIView * label;
@property (nonatomic,strong) UILabel * calloutLabel;
@property (nonatomic,strong) RMMarker * addedNode;
@property (nonatomic,strong) RMMarker * nodeInfo;
@property (nonatomic,strong) RMMarker * currentLocationMarker;
@property (nonatomic) int currentTile;
@property (nonatomic, strong) OPEMessage * message;
@property (nonatomic, strong) NSMutableDictionary * imagesDic;
@property (nonatomic) RMSphericalTrapezium currentSquare;


- (RMMarker *) addMarkerAt:(CLLocationCoordinate2D) markerPosition withNode:(OPENode *) node;
- (void) addMarkers:(NSNotification *) notification;
//- (void) pushMapAnnotationDetailedViewControllerDelegate:(id) sender;
//- (void) buttonEvent:(id)sender;

-(IBAction)infoButtonPressed:(id)sender;
-(IBAction)addPointButtonPressed:(id)sender;
-(IBAction)locationButtonPressed:(id)sender;

@end
