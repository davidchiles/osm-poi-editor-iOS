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
#import "OPEOSMData.h"

@implementation OPEViewController

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    [RMMapView class];
    
    id cmTilesource = [[RMCloudMadeHiResMapSource alloc] initWithAccessKey: @"0d68a3f7f77a47bc8ef3923816ebbeab" 
                                                           styleNumber: 36079];
    
    [[RMMapContents alloc] initWithView: mapView tilesource: cmTilesource];
    
    locationManager = [[CLLocationManager alloc] init];
    //locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    [locationManager startUpdatingLocation];
    
    
    CLLocationCoordinate2D initLocation;
    NSLog(@"location Manager: %@",[locationManager location]);
    
    initLocation.longitude = -0.127523;
    initLocation.latitude  = 51.51383;
    //initLocation = [[locationManager location] coordinate];
    
    [mapView moveToLatLong: initLocation];
    
    [mapView.contents setZoom: 16];
    //OPEParser *parser = [[OPEParser alloc] init];
    double bboxleft = -122.26341;
    double bboxbottom = 37.86981;
    double bboxright = -122.25421;
    double bboxtop = 37.87533;
    OPEOSMData* data = [[OPEOSMData alloc] initWithLeft:bboxleft bottom:bboxbottom right:bboxright top:bboxtop];
    [data getData];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
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
