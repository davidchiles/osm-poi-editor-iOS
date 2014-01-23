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
#import "OPEOsmNode.h"
#import "OPEOSMData.h"


@interface OPEMoveNodeViewController : UIViewController
{
    OPEOSMData * osmData;
}

@property (nonatomic,strong)OPECrosshairMapView * mapView;
@property (nonatomic,strong)OPEOsmNode * node;

-(id)initWithNode:(OPEOsmNode *)node;

@end
