//
//  OPEViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RMMapView.h"
#import <CoreLocation/CoreLocation.h>
#import "OPENode.h"

@interface OPEViewController : UIViewController {
    IBOutlet RMMapView* mapView;
    CLLocationManager* locationManager;
}
-(void) addMarkerAt:(CLLocationCoordinate2D) markerPosition;

@end
