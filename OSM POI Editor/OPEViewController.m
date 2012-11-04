//
//  OPEViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/2/12.
//  Copyright (c) 2011 David Chiles. All rights reserved.
//
//  This file is part of POI+.
//
//  POI+ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  POI+ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with POI+.  If not, see <http://www.gnu.org/licenses/>.

#import "OPEViewController.h" 
#import "GTMOAuthViewControllerTouch.h"
#import "RMFoundation.h"
#import "RMMarker.h"
#import "RMAnnotation.h"
#import "OPEUserTrackingBarButtonItem.h"
#import "OPEStamenTerrain.h"
#import "OPEPoint.h"


@implementation OPEViewController

@synthesize osmData;
@synthesize locationManager;
@synthesize interpreter;
@synthesize infoButton,location, addOPEPoint;
@synthesize openMarker,theNewMarker, label, calloutLabel;
@synthesize addedNode,nodeInfo,currentLocationMarker;
@synthesize currentTile;
@synthesize message;
@synthesize imagesDic;
@synthesize currentSquare;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

#define MINZOOM 17.0

-(void)setupButtons
{
    mapView.frame = self.view.bounds;
    
    
    
    UIBarButtonItem * locationBarButton;
    UIBarButtonItem * addBarButton;
    UIBarButtonItem * settingsBarButton;
    
    //locationBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"]style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonPressed:)];
    //locationBarButton = [[RMUserTrackingBarButtonItem alloc] initWithMapView:mapView];
    locationBarButton = [[OPEUserTrackingBarButtonItem alloc] initWithMapView:mapView];
    
    
    
    addBarButton = [[UIBarButtonItem alloc]initWithBarButtonSystemItem:UIBarButtonSystemItemAdd target:self action:@selector(addPointButtonPressed:)];
    
    settingsBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"] style:UIBarButtonItemStylePlain target:self action:@selector(infoButtonPressed:)];
    
    UIBarButtonItem * flexibleSpaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:mapView];
    
    plusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus.png"]];
    plusImageView.center = mapView.center;
    [self.view addSubview:plusImageView];
    
    
    self.toolbarItems = [NSArray arrayWithObjects:locationBarButton,flexibleSpaceBarItem,addBarButton,flexibleSpaceBarItem,settingsBarButton, nil];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self setupButtons];
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:NO animated:NO];
    //Check OAuth
    
    mapView = [[RMMapView alloc] init];
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(addMarkers:)
     name:@"DownloadComplete"
     object:nil ];
    
    interpreter = [[OPETagInterpreter alloc] init];
    [interpreter readPlist];
   
    //36079
    
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D initLocation;
    //NSLog(@"location Manager: %@",[locationManager location]);
    
    initLocation.latitude  = 37.871667;
    initLocation.longitude =  -122.272778;
    
    initLocation = [[locationManager location] coordinate];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        mapView.contentScaleFactor = 2.0;
    }
    else {
        mapView.contentScaleFactor = 1.0;
    }
    
    [mapView setDelegate:self];
    [mapView setCenterCoordinate:initLocation animated:YES];
    
    [mapView setZoom: 18];
    id <RMTileSource> newTileSource = nil;
    int num = 0;
    NSUserDefaults *settings = [NSUserDefaults standardUserDefaults];
    NSLog(@"stored TileSource: %@",[settings objectForKey:@"tileSourceNumber"]);
    if ([settings objectForKey:@"tileSourceNumber"]) {
        currentTile = [[settings objectForKey:@"tileSourceNumber"] intValue] ;
        newTileSource = [OPEInfoViewController getTileSourceFromNumber:currentTile];
        
    }
    else {
        newTileSource = [[OPEStamenTerrain alloc] init];
        currentTile = 0;
    }
    
    
    [self setTileSource:newTileSource at:num];
    
    
    
    RMSphericalTrapezium geoBox = [mapView latitudeLongitudeBoundingBox];
    currentSquare = [mapView latitudeLongitudeBoundingBox];
    
    osmData = [[OPEOSMData alloc] init];
    
    message = [[OPEMessage alloc] init];
    message.alpha = 0.0;
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
        if (mapView.zoom > MINZOOM) {
            [self removeZoomWarning];
            dispatch_async(q, ^{
                [osmData getDataWithSW:geoBox.southWest NE:geoBox.northEast];
             });
        }
        else {
            [self showZoomWarning];
        }
        
   
    
    //dispatch_release(q);
    
    imagesDic = [[NSMutableDictionary alloc] init];
}

- (UIImage*)imageWithBorderFromImage:(UIImage*)source  //Draw box around centered image
{
    CGSize imgSize = [source size];
    
    //NSLog(@"Image Size: h-%f w-%f",size.height,size.width);
    float rectSize;
    if (imgSize.width > imgSize.height) {
        rectSize = imgSize.width;
    }
    else {
        rectSize = imgSize.height;
    }
    UIView * view;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rectSize+4,rectSize+4)];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:source];  
    
    [view addSubview:imageView];
    [view sizeToFit];
    imageView.center = view.center; //Center the Image
    
    [view.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [view.layer setBorderWidth: 1.0];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    CGSize size = [view bounds].size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

-(RMMarker *)markerWithNode:(id<OPEPoint>)node
{
    UIImage * icon;   //Get image from stored value in node
    //UIImage * icon = [UIImage imageNamed:@"restaurant"];
    //if (node.ident>0 && ![node.image isEqualToString:@"none.png"]) {
    if(node.ident > 0) {
        if ([imagesDic objectForKey:node.image]) {
            icon = [imagesDic objectForKey:node.image];
        }
        else {
            icon = [self imageWithBorderFromImage:[UIImage imageNamed:node.image]]; //center image inside box
            [imagesDic setObject:icon forKey:node.image];
        }
    }
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:icon anchorPoint:CGPointMake(0.5, 0.5)];
    newMarker.userInfo = node;
    newMarker.zPosition = 0.2;
    return newMarker;
}

-(RMMapLayer *) mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    id<OPEPoint> node = annotation.userInfo;
    
    RMMarker * marker = [self markerWithNode:node];
    marker.canShowCallout = YES;
    marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return marker;
}

-(RMAnnotation *)annotationWithNode:(id<OPEPoint>)node
{
    RMAnnotation * annotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:node.coordinate andTitle:node.name];
    annotation.userInfo = node;
    
    return annotation;
}




-(RMMarker *) addMarkerAt:(CLLocationCoordinate2D) position withNode: (OPENode *) node
{
    //NSLog(@"start addMarkerAt %@",node.image);
    UIImage * icon;   //Get image from stored value in node
    //UIImage * icon = [UIImage imageNamed:@"restaurant"];
    //if (node.ident>0 && ![node.image isEqualToString:@"none.png"]) {
    if(node.ident > 0) {
        if ([imagesDic objectForKey:node.image]) {
            icon = [imagesDic objectForKey:node.image];
        }
        else {
            icon = [self imageWithBorderFromImage:icon]; //center image inside box
            [imagesDic setObject:icon forKey:node.image];
        }

    }
   
    //RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:icon anchorPoint:CGPointMake(0.5, 1.0)];
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:icon anchorPoint:CGPointMake(0.5, 0.5)];
    //[mapView.markerManager addMarker:newMarker AtLatLong:node.coordinate];
    
    
   
    return newMarker;

}

#define CENTER_IMAGE_WIDTH  31 
#define CALLOUT_HEIGHT  45 
#define MIN_LEFT_IMAGE_WIDTH  7 
#define MIN_RIGHT_IMAGE_WIDTH  7 
#define LABEL_HEIGHT  48 
#define LABEL_FONT_SIZE  20 
#define ANCHOR_Y  80

/*
-(void) tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    //[openMarker hideLabel];
    //openMarker.zPosition = 0.5;
    //marker.zPosition = 1.0;
    id<OPEPoint> tempNode = annotation.userInfo;
    
    if(tempNode.ident == -1)
    {
        //[marker setProjectedLocation:[[mapView.contents projection] latLongToPoint:[mapView pixelToLatLong:marker.position]]];
        
        tempNode.coordinate = [mapView pixelToCoordinate:CGPointMake(annotation.position.x, +annotation.position.y)];
        //[self tapOnLabelForMarker:marker onMap:mapView onLayer:nil];
    }
    else if (tempNode.ident > 0){
        
        //NSString * titulo = [((OPENode *)marker.data) getName];
        NSString * titulo = [interpreter getName:tempNode];
        CGSize size = [titulo sizeWithFont:[UIFont boldSystemFontOfSize:LABEL_FONT_SIZE]];
        float sizes = size.width;
        
        int left_width2 = ((int)(sizes + CENTER_IMAGE_WIDTH)/2)-5;
        int right_width2 = (int)(sizes + CENTER_IMAGE_WIDTH)/2;
        
        label=[[UIView alloc]initWithFrame:CGRectMake(((left_width2*2+21)/ 2)-18, 19 - ANCHOR_Y,0 , 0)];
        label.backgroundColor = [UIColor clearColor];
        label.userInteractionEnabled=YES;
        
        
        
        UIImage * CALLOUT_LEFT_IMAGE = [[UIImage imageNamed:@"left.png"]
                                        stretchableImageWithLeftCapWidth:15 topCapHeight:0];
        UIImage * CALLOUT_CENTER_IMAGE = [[UIImage
                                           imageNamed:@"center.png"]stretchableImageWithLeftCapWidth:30
                                          topCapHeight:0];
        UIImage * CALLOUT_RIGHT_IMAGE = [[UIImage imageNamed:@"right.png"]
                                         stretchableImageWithLeftCapWidth:1 topCapHeight:0];
        UIImageView * calloutCenter = [[UIImageView alloc]
                                       initWithFrame:CGRectMake(left_width2-5+5,0, right_width2+5+5,
                                                                CALLOUT_HEIGHT)];
        calloutCenter.image = CALLOUT_CENTER_IMAGE;
        [label addSubview:calloutCenter];
        UIImageView * calloutLeft = [[UIImageView alloc] initWithFrame:CGRectMake(round(0),
                                                                                  round(0), left_width2-5+5, round(CALLOUT_HEIGHT))];
        calloutLeft.image = CALLOUT_LEFT_IMAGE;
        [label addSubview:calloutLeft];
        UIImageView * calloutRight = [[UIImageView alloc]
                                      initWithFrame:CGRectMake(left_width2*2+5+10, round(0), 16,
                                                               round(CALLOUT_HEIGHT))];
        calloutRight.image = CALLOUT_RIGHT_IMAGE;
        [label addSubview:calloutRight];
        
        
        
        calloutLabel = [[UILabel alloc]
                        initWithFrame:CGRectMake(MIN_LEFT_IMAGE_WIDTH-3,0 , sizes, LABEL_HEIGHT)];
        calloutLabel.font = [UIFont boldSystemFontOfSize:LABEL_FONT_SIZE];
        calloutLabel.text=titulo;
        calloutLabel.textColor = [UIColor whiteColor];
        calloutLabel.backgroundColor = [UIColor clearColor];
        [label addSubview:calloutLabel];
        
        UIButton *buttongo= [UIButton
                             buttonWithType:UIButtonTypeDetailDisclosure];
        //[buttongo setTitle:@"TTT" forState:UIControlStateNormal];
        //[buttongo addTarget:self action:@selector(testItOut) forControlEvents:UIControlEventTouchUpInside];
        buttongo.frame=CGRectMake(left_width2*2-3, 8, 30, 30);
        buttongo.userInteractionEnabled=YES;
        buttongo.enabled=YES;
        [label addSubview:buttongo];
        [label bringSubviewToFront:buttongo];
        
        [mapView addSubview: label];
        
        
    
        
    }

}
 */

- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    OPENodeViewController * nodeVC = [[OPENodeViewController alloc] init];
    
    nodeVC.title = @"Node Info";
    nodeVC.point = (id<OPEPoint>)annotation.userInfo;
    [nodeVC setDelegate:self];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Map" style: UIBarButtonItemStyleBordered target: nil action: nil];
    
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    [self.navigationController pushViewController:nodeVC animated:YES];
}

- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{   
    OPENode * node = (OPENode *)marker.userInfo;
    if(node.ident<0)
    {
        return YES;
    }
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
            //[mapView.markerManager moveMarker:marker AtXY: position];
            CGSize delta = CGSizeMake((position.x-(marker.position.x)), 
                                      (position.y-(marker.position.y))); 
            //[marker moveBy: delta];
            //[marker setProjectedLocation:[[mapView.contents projection] latLongToPoint:[mapView pixelToLatLong:marker.position]]]; 
            //[marker setProjectedLocation: [[mapView projection] latLongToPoint:[mapView pixelToLatLong:marker.position]]];
            //[mapView.markerManager moveMarker:marker AtXY:position];
        }
    }
}

-(void) singleTapOnMap:(RMMapView *)map At:(CGPoint)point
{
    if (openMarker) {
        //[openMarker hideLabel];
        //openMarker = nil;
    }
    
}

-(void) showZoomWarning
{
    [self.view addSubview:message];
    message.userInteractionEnabled = NO;
    [UIView beginAnimations:nil context:nil];
	[UIView setAnimationDuration:1.0];
	//[UIView setAnimationDelegate:self];
    //[UIView setAnimationDidStopSelector:@selector(finishedFadIn)];
	
	[message setAlpha:0.8];
	
	[UIView commitAnimations];
    
}
-(void)animationDidStop:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context
{
    [message removeFromSuperview];
    
}
-(void) removeZoomWarning
{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDelegate:self];
	[UIView setAnimationDuration:1.0];
	
	[message setAlpha:0.0];
	
	[UIView commitAnimations];
    
}

- (void) setText: (NSString*) text forMarker: (RMMarker*) marker
{
    CGSize textSize = [text sizeWithFont: [RMMarker defaultFont]]; 
    
    CGPoint position = CGPointMake(  -(textSize.width/2 - marker.bounds.size.width/2), -textSize.height );
    
    [marker changeLabelUsingText: text position: position ];    
}

-(void)downloadNewArea:(RMMapView *)map
{
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
    
    RMSphericalTrapezium geoBox = [map latitudeLongitudeBoundingBox];
    if (map.zoom > MINZOOM) {
        [self removeZoomWarning];
        dispatch_async(q, ^{
            [osmData getDataWithSW:geoBox.southWest NE:geoBox.northEast];
        });
        dispatch_release(q);
    }
    else {
        [self showZoomWarning];
    }
}

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    [self downloadNewArea:map];
}

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    [self downloadNewArea:map];
}

- (void) addMarkers:(NSNotification*)notification 
{
    NSDictionary * newNodes = notification.userInfo;
    //[mapView removeAllAnnotations];
    for(id key in newNodes)
    {
        id<OPEPoint> node = [osmData.allNodes objectForKey:key];
        [mapView addAnnotation:[self annotationWithNode:node]];
    }
}

#pragma - LocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Denied Location: %@",error.userInfo);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if (currentLocationMarker == nil) {
        UIImage *icon = [UIImage imageNamed:@"userLocation.png"]; 
        currentLocationMarker = [[RMMarker alloc] initWithUIImage:icon anchorPoint:CGPointMake(0.5, 0.5)];
        
        //[mapView.markerManager addMarker:currentLocationMarker AtLatLong:newLocation.coordinate];
    }
    else {
        //[mapView.markerManager moveMarker:currentLocationMarker AtLatLon:newLocation.coordinate];
    }
}

#pragma - NodeViewDelegate

-(void) updatedNode:(OPENode *)newNode
{
    //[mapView.markerManager removeMarker:nodeInfo];
    [self addMarkerAt:newNode.coordinate withNode:newNode];
    [self.osmData.allNodes setObject:newNode forKey:[newNode uniqueIdentifier]];
}
-(void) createdNode:(OPENode *)newNode
{
    NSLog(@"Created New Node: %@",[newNode uniqueIdentifier]);
    //[mapView.markerManager removeMarker:nodeInfo];
    [self addMarkerAt:newNode.coordinate withNode:newNode];
    [self.osmData.allNodes setObject:newNode forKey:[newNode uniqueIdentifier]];
    theNewMarker = nil;
    
}
-(void) deletedNode:(OPENode *)newNode
{
    //[mapView.markerManager removeMarker:nodeInfo];
    [self.osmData.allNodes removeObjectForKey:[newNode uniqueIdentifier]];
    [self.osmData.ignoreNodes setObject:newNode forKey:[newNode uniqueIdentifier]];
}

#pragma - InfoViewDelegate

-(void)setTileSource:(id)tileSource at:(int)number
{
    if (tileSource) {
        currentTile = number;
        [mapView removeAllCachedImages];
        [mapView setTileSource:tileSource];
    }
    NSLog(@"TileSource: %@",((id<RMTileSource>)tileSource));
    
}

#pragma - Actions

- (IBAction)addPointButtonPressed:(id)sender
{
    CLLocationCoordinate2D center = mapView.centerCoordinate;
    
    center = [mapView pixelToCoordinate:plusImageView.center];
    if (mapView.zoom > MINZOOM) {
        if(openMarker) 
        {
            //[openMarker hideLabel];
            openMarker = nil;
        }
        if(theNewMarker)
        {
            //[mapView.contents.markerManager moveMarker: theNewMarker AtLatLon:center];
        }
        else
        {
            OPENode * node = [[OPENode alloc] initWithId:-1 latitude:center.latitude longitude:center.longitude version:1];
            node.image = @"newNodeMarker.png";
            theNewMarker = [self addMarkerAt:center withNode:node];
            theNewMarker.zPosition = 1.0;
        }
    }
    else {
        UIAlertView * zoomAlert = [[UIAlertView alloc]
                                   initWithTitle: @"Zoom Level"
                                   message: @"You need to zoom in to add a new POI"
                                   delegate: nil
                                   cancelButtonTitle:@"OK"
                                   otherButtonTitles:nil];
        [zoomAlert show];
    }
}

-(IBAction)locationButtonPressed:(id)sender
{
    CLLocationCoordinate2D currentLocation = [[locationManager location] coordinate];
    
    [mapView setCenterCoordinate: currentLocation animated:YES];
}

- (IBAction)infoButtonPressed:(id)sender
{
    //NSLog(@"info button pressed");
    OPEInfoViewController * viewer = [[OPEInfoViewController alloc] init];
    [viewer setDelegate:self];
    //[viewer setCurrentNumber:currentTile];
    viewer.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewer.title = @"Settings";
    [[self navigationController] pushViewController:viewer animated:YES];
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    
    [self setupButtons];
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    return NO;
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
