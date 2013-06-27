//
//  OPEMoveNodeViewController.m
//  OSM POI Editor
//
//  Created by David on 6/26/13.
//
//

#import "OPEMoveNodeViewController.h"
#import "OPEUtility.h"
#import "OPEStrings.h"

@interface OPEMoveNodeViewController ()

@end

@implementation OPEMoveNodeViewController

@synthesize mapView,node;

-(id)initWithNode:(OPEManagedOsmNode *)newNode
{
    if (self=[super init]) {
        osmData = [[OPEOSMData alloc] init];
        self.node = newNode;
        self.title = MOVE_NODE_STRING;
    }
    return self;
}

-(void)viewDidLoad
{
    [self.view addSubview:mapView];
    
    UIBarButtonItem * cancelButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(cancelButtonPressed:)];
    UIBarButtonItem * doneButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemDone target:self action:@selector(doneButtonPressed:)];
    
    id <RMTileSource> newTileSource = [OPEUtility currentTileSource];
    self.mapView = [[OPECrosshairMapView alloc] initWithFrame:self.view.bounds andTilesource:newTileSource];
    self.mapView.centerCoordinate = [osmData centerForElement:self.node];
    self.mapView.zoom = MIN([newTileSource maxZoom],18.0);
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.navigationItem setLeftBarButtonItem:cancelButton];
    [self.navigationItem setRightBarButtonItem:doneButton];
    
    [self.view addSubview:self.mapView];
    
    
}

-(void)cancelButtonPressed:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}
-(void)doneButtonPressed:(id)sender
{
    node.element.coordinate = self.mapView.centerCoordinate;
    
    [self.navigationController popViewControllerAnimated:YES];
}

@end
