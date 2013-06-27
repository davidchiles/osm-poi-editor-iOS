//
//  OPEMoveNodeViewController.h
//  OSM POI Editor
//
//  Created by David on 6/26/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OPECrosshairMapView.h"
#import "OPEManagedOsmNode.h"
#import "OPEOSMData.h"


@interface OPEMoveNodeViewController : UIViewController
{
    OPEOSMData * osmData;
}

@property (nonatomic,strong)OPECrosshairMapView * mapView;
@property (nonatomic,strong)OPEManagedOsmNode * node;

-(id)initWithNode:(OPEManagedOsmNode *)node;

@end
