//
//  OPEViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEViewController.h" 
#import "GTMOAuthViewControllerTouch.h"
#import "RMFoundation.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"
#import "OPEStamenTerrain.h"


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

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    //Check OAuth
    
    
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
    [mapView moveToLatLong: initLocation];
    
    [mapView.contents setZoom: 18];
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
    [self addMarkerAt:initLocation withNode:nil];
    
    RMSphericalTrapezium geoBox = [mapView latitudeLongitudeBoundingBoxForScreen];
    currentSquare = [mapView latitudeLongitudeBoundingBoxForScreen];
    
    osmData = [[OPEOSMData alloc] init];
    
    message = [[OPEMessage alloc] init];
    message.alpha = 0.0;
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
        if (mapView.contents.zoom > MINZOOM) {
            [self removeZoomWarning];
            dispatch_async(q, ^{
                [osmData getDataWithSW:geoBox.southwest NE:geoBox.northeast];
             });
        }
        else {
            [self showZoomWarning];
        }
        
   
    
    dispatch_release(q);
    
    imagesDic = [[NSMutableDictionary alloc] init];
    //[mapView moveToLatLong: initLocation];
    //[mapView.contents setZoom: 16];
    
    //[self addMarkerAt: initLocation];

    
    /*
    RMAnnotation * annotation = [RMAnnotation annotationWithMapView:mapView coordinate: initLocation andTitle:@"Hello"];
    annotation.anchorPoint = CGPointMake(0.5, 1.0);
    annotation.annotationIcon = [UIImage imageNamed:@"taxi.png"]; 
     */
    
    //[mapView addAnnotation:annotation];
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


-(RMMarker *) addMarkerAt:(CLLocationCoordinate2D) position withNode: (OPENode *) node
{
    //NSLog(@"start addMarkerAt %@",node.image);
    UIImage *icon = [UIImage imageNamed:node.image];   //Get image from stored value in node
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
    
    newMarker.data = node;
    newMarker.zPosition = 0.2;
    [mapView.markerManager addMarker:newMarker AtLatLong:node.coordinate];
    
    
   
    return newMarker;

}

#define CENTER_IMAGE_WIDTH  31 
#define CALLOUT_HEIGHT  45 
#define MIN_LEFT_IMAGE_WIDTH  7 
#define MIN_RIGHT_IMAGE_WIDTH  7 
#define LABEL_HEIGHT  48 
#define LABEL_FONT_SIZE  20 
#define ANCHOR_Y  80

-(void) tapOnMarker:(RMMarker *)marker onMap:(RMMapView *)map
{
    
    [openMarker hideLabel];
    openMarker.zPosition = 0.5;
    marker.zPosition = 1.0;
    OPENode * tempNode = (OPENode *)marker.data;
    
    if(tempNode.ident == -1)
    {
        //[marker setProjectedLocation:[[mapView.contents projection] latLongToPoint:[mapView pixelToLatLong:marker.position]]]; 
        
        ((OPENode *)marker.data).coordinate = [mapView pixelToLatLong:CGPointMake(marker.position.x, marker.bounds.size.height/2+marker.position.y)];
        [self tapOnLabelForMarker:marker onMap:mapView onLayer:nil];
    }
    else if (marker.label) {
        [marker showLabel];
        openMarker = marker;
        [mapView bringSubviewToFront:marker.label];
    }
    else if (tempNode.ident > 0){
    
        //NSString * titulo = [((OPENode *)marker.data) getName];
        NSString * titulo = [interpreter getName:tempNode];
        CGSize size = [titulo sizeWithFont:[UIFont boldSystemFontOfSize:LABEL_FONT_SIZE]]; 
        float sizes = size.width;
        
        int left_width2 = ((int)(sizes + CENTER_IMAGE_WIDTH)/2)-5; 
        int right_width2 = (int)(sizes + CENTER_IMAGE_WIDTH)/2;
        
        label=[[UIView alloc]initWithFrame:CGRectMake(((-left_width2*2+21)/ 2)-18, 19 - ANCHOR_Y,0 , 0)];
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
        [marker setDelegate:self];
        [marker setLabel:label];
        
        
        
        openMarker = marker;
        [mapView bringSubviewToFront:marker.label];
    }
    
}


-(void) tapOnLabelForMarker:(RMMarker *)marker onMap:(RMMapView *)map onLayer:(CALayer *)layer
{
    NSLog(@"hello %@",layer.name);
    nodeInfo = marker;
    OPENodeViewController * viewer = [[OPENodeViewController alloc] initWithNibName:@"OPENodeViewController" bundle:nil];
    
    viewer.title = @"Node Info";
    viewer.node = (OPENode *)marker.data;
    [viewer setDelegate:self];
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Map" style: UIBarButtonItemStyleBordered target: nil action: nil];
    
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    [self.navigationController pushViewController:viewer animated:YES];
}

- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{   
    OPENode * node = (OPENode *)marker.data;
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
            [marker moveBy: delta];
            //[marker setProjectedLocation:[[mapView.contents projection] latLongToPoint:[mapView pixelToLatLong:marker.position]]]; 
            //[marker setProjectedLocation: [[mapView projection] latLongToPoint:[mapView pixelToLatLong:marker.position]]];
            [mapView.markerManager moveMarker:marker AtXY:position];
        }
    }
}

-(void) singleTapOnMap:(RMMapView *)map At:(CGPoint)point
{
    if (openMarker) {
        [openMarker hideLabel];
        openMarker = nil;
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


/*
- (RMMarker *) addNewMarkerAt:(CLLocationCoordinate2D) markerPosition withNode: (OPENode *) node
{
    UIImage *blueMarkerImage = [UIImage imageNamed:@"bar.png"];
    blueMarkerImage = [self imageWithBorderFromImage:blueMarkerImage];
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:blueMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
    newMarker.data = node;
    [mapView.contents.markerManager addMarker:newMarker AtLatLong:markerPosition];
    return newMarker;
}
 */

- (void) setText: (NSString*) text forMarker: (RMMarker*) marker
{
    CGSize textSize = [text sizeWithFont: [RMMarker defaultFont]]; 
    
    CGPoint position = CGPointMake(  -(textSize.width/2 - marker.bounds.size.width/2), -textSize.height );
    
    [marker changeLabelUsingText: text position: position ];    
}

-(void) afterMapTouch:(RMMapView *)map
{
    //RMSphericalTrapezium geoBox = [mapView latitudeLongitudeBoundingBoxForScreen];
    
    dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
    
    RMSphericalTrapezium geoBox = [mapView latitudeLongitudeBoundingBoxForScreen];
    if (mapView.contents.zoom > MINZOOM) {
        [self removeZoomWarning];
        dispatch_async(q, ^{
            [osmData getDataWithSW:geoBox.southwest NE:geoBox.northeast];
        });
        dispatch_release(q);
    }
    else {
        [self showZoomWarning];
    }
        
    
    
    
}

- (void) addMarkers:(NSNotification*)notification 
{
    NSDictionary * newNodes = notification.userInfo;
    //[mapView removeAllAnnotations];
    for(id key in newNodes)
    {
        OPENode* node = [osmData.allNodes objectForKey:key];
        [self addMarkerAt:node.coordinate withNode:node];
        
    }
}


- (CLLocationCoordinate2D) centerOfMap
{
    RMSphericalTrapezium geoBox = [mapView latitudeLongitudeBoundingBoxForScreen];
    
    double left = geoBox.southwest.longitude; 
    double bottom = geoBox.southwest.latitude;
    double right = geoBox.northeast.longitude;
    double top = geoBox.northeast.latitude;
    
    CLLocationDegrees lat = (bottom + top)/2.0;
    CLLocationDegrees lon = (left + right)/2.0;
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake(lat, lon);
    return center;
    
    
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
        
        [mapView.markerManager addMarker:currentLocationMarker AtLatLong:newLocation.coordinate];
    }
    else {
        [mapView.markerManager moveMarker:currentLocationMarker AtLatLon:newLocation.coordinate];
    }
}

#pragma - NodeViewDelegate

-(void) updatedNode:(OPENode *)newNode
{
    [mapView.markerManager removeMarker:nodeInfo];
    [self addMarkerAt:newNode.coordinate withNode:newNode];
    [self.osmData.allNodes setObject:newNode forKey:[NSNumber numberWithInt:newNode.ident]];
}
-(void) createdNode:(OPENode *)newNode
{
    NSLog(@"Created New Node: %d",newNode.ident);
    [mapView.markerManager removeMarker:nodeInfo];
    [self addMarkerAt:newNode.coordinate withNode:newNode];
    [self.osmData.allNodes setObject:newNode forKey:[NSNumber numberWithInt:newNode.ident]];
    theNewMarker = nil;
    
}
-(void) deletedNode:(OPENode *)newNode
{
    [mapView.markerManager removeMarker:nodeInfo];
    [self.osmData.allNodes removeObjectForKey:[NSNumber numberWithInt:newNode.ident]];
    [self.osmData.ignoreNodes setObject:newNode forKey:[NSNumber numberWithInt:newNode.ident]];
}

#pragma - InfoViewDelegate

-(void)setTileSource:(id)tileSource at:(int)number
{
    if (tileSource) {
        currentTile = number;
        [mapView.contents removeAllCachedImages];
        [mapView.contents setTileSource:tileSource];
    }
    NSLog(@"TileSource: %@",((id<RMTileSource>)tileSource));
    
}

#pragma - Actions

- (IBAction)addPointButtonPressed:(id)sender
{
    CLLocationCoordinate2D center = [self centerOfMap];
    if (mapView.contents.zoom > MINZOOM) {
        if(openMarker) 
        {
            [openMarker hideLabel];
            openMarker = nil;
        }
        if(theNewMarker)
        {
            [mapView.contents.markerManager moveMarker: theNewMarker AtLatLon:center];
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
    
    //[mapView setCenterCoordinate: currentLocation animated:YES];
    [mapView moveToLatLong:currentLocation];
}

- (IBAction)infoButtonPressed:(id)sender
{
    NSLog(@"info button pressed");
    OPEInfoViewController * viewer = [[OPEInfoViewController alloc] initWithNibName:@"OPEInfoViewController" bundle:nil];
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
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    [self.navigationController setNavigationBarHidden:NO animated:YES];
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
