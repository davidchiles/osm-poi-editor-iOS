//
//  OPEViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEViewController.h"
#import "RMCloudMadeMapSource.h"
#import "RMCloudMadeHiResMapSource.h" 
#import "OPEParser.h"
#import "RMMarkerManager.h" 
#import "RMMarkerAdditions.h"
#import "OPENodeViewController.h"



@implementation OPEViewController

@synthesize osmData;
@synthesize locationManager;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(addMarkers)
     name:@"DownloadComplete"
     object:nil ];
    
    [RMMapView class];
    
    [self.navigationController setNavigationBarHidden:YES];
    
    id cmTilesource = [[RMCloudMadeHiResMapSource alloc] initWithAccessKey: @"0d68a3f7f77a47bc8ef3923816ebbeab" 
                                                           styleNumber: 1];
    //36079

    [[RMMapContents alloc] initWithView: mapView tilesource: cmTilesource];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    
    CLLocationCoordinate2D initLocation;
    //NSLog(@"location Manager: %@",[locationManager location]);
    
    //initLocation.latitude  = 37.871667;
    //initLocation.longitude =  -122.272778;
   
    initLocation = [[locationManager location] coordinate];
    
    [mapView moveToLatLong: initLocation];
    
    [mapView.contents setZoom: 18];
    [self addMarkerAt:initLocation withNode:nil];
    RMSphericalTrapezium geoBox = [mapView latitudeLongitudeBoundingBoxForScreen];
    //OPEParser *parser = [[OPEParser alloc] init];

    double bboxleft = geoBox.southwest.longitude;
    double bboxbottom = geoBox.southwest.latitude;
    double bboxright = geoBox.northeast.longitude;
    double bboxtop = geoBox.northeast.latitude;
    osmData = [[OPEOSMData alloc] initWithLeft:bboxleft bottom:bboxbottom right:bboxright top:bboxtop];
    
    [osmData getData];
    
    //[mapView moveToLatLong: initLocation];
    //[mapView.contents setZoom: 16];
    
    //[self addMarkerAt: initLocation];

    mapView.delegate = self;
        
}

-(void) addMarkerAt:(CLLocationCoordinate2D) markerPosition withNode: (OPENode *) node
{
    NSLog(@"start addMarkerAt");
    UIImage *blueMarkerImage = [UIImage imageNamed:@"Blue_Dot.png"];
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:blueMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
    newMarker.data = node;
    [mapView.contents.markerManager addMarker:newMarker AtLatLong:markerPosition];
    //[newMarker retain];
}

- (void) setText: (NSString*) text forMarker: (RMMarker*) marker
{
    CGSize textSize = [text sizeWithFont: [RMMarker defaultFont]]; 
    
    CGPoint position = CGPointMake(  -(textSize.width/2 - marker.bounds.size.width/2), -textSize.height );
    
    [marker changeLabelUsingText: text position: position ];    
}


- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map
{
    //NSInteger clickCounter = [((NSNumber*) marker.data) intValue] + 1;
    
    //marker.data = [NSNumber numberWithInt: clickCounter ];
    
    //NSString* markerText = [NSString stringWithFormat:@"%@", @"test"];
    //[self setText: markerText forMarker: marker];
    //[marker addAnnotationViewWithTitle:@"test"];
    OPENodeViewController * viewer = [[OPENodeViewController alloc] initWithNibName:@"OPENodeViewController" bundle:nil];
    
    viewer.title = @"Node Info";
    viewer.node = (OPENode *)marker.data;
    

    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Map" style: UIBarButtonItemStyleBordered target: nil action: nil];
    
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    [self.navigationController pushViewController:viewer animated:YES];
    //[self.view addSubview:OPENodeViewController.view];
    
}

- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{
    return NO;
}

- (void) mapView:(RMMapView *)map didDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{
    NSSet* touches = [event allTouches];
    
    if([touches count] == 1)
    {
        UITouch* touch = [touches anyObject];
        if(touch.phase == UITouchPhaseMoved)
        {
            CGPoint position = [touch locationInView: mapView ];
            [mapView.markerManager moveMarker:marker AtXY: position];
        }
    }
}

-(void) afterMapMove:(RMMapView *)map
{
    NSLog(@"start map move");
    RMSphericalTrapezium geoBox = [mapView latitudeLongitudeBoundingBoxForScreen];
    
    osmData.bboxleft = geoBox.southwest.longitude; 
    osmData.bboxbottom = geoBox.southwest.latitude;
    osmData.bboxright = geoBox.northeast.longitude;
    osmData.bboxtop = geoBox.northeast.latitude;
    
    [osmData getData];
}

- (void) addMarkers
{
    for(id key in osmData.allNodes)
    {
        OPENode* node = [osmData.allNodes objectForKey:key];
        [self addMarkerAt:node.coordinate withNode:node];
        
    }
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [locationManager stopUpdatingLocation];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self.navigationController setNavigationBarHidden:YES];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
