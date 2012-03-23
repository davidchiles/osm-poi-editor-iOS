//
//  OPEViewController.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/2/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEViewController.h" 
#import "OPENodeViewController.h"
#import "GTMOAuthViewControllerTouch.h"
#import "RMFoundation.h"
#import "RMMarker.h"
#import "RMMarkerManager.h"

@implementation OPEViewController

@synthesize osmData;
@synthesize locationManager;
@synthesize interpreter;
@synthesize infoButton,location, addOPEPoint;
@synthesize openMarker,theNewMarker, label, calloutLabel;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //Check OAuth
    
    
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(addMarkers:)
     name:@"DownloadComplete"
     object:nil ];
    
    interpreter = [[OPETagInterpreter alloc] init];
    [interpreter readPlist];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
   
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
    
    [mapView moveToLatLong: initLocation];
    
    [mapView.contents setZoom: 18];
    [self addMarkerAt:initLocation withNode:nil];
    
    RMSphericalTrapezium geoBox = [mapView latitudeLongitudeBoundingBoxForScreen];
    
    osmData = [[OPEOSMData alloc] init];
    
    [osmData getDataWithSW:geoBox.southwest NE:geoBox.northeast];
    
    //[mapView moveToLatLong: initLocation];
    //[mapView.contents setZoom: 16];
    
    //[self addMarkerAt: initLocation];

    [mapView setDelegate:self];
    /*
    RMAnnotation * annotation = [RMAnnotation annotationWithMapView:mapView coordinate: initLocation andTitle:@"Hello"];
    annotation.anchorPoint = CGPointMake(0.5, 1.0);
    annotation.annotationIcon = [UIImage imageNamed:@"taxi.png"]; 
     */
    
    //[mapView addAnnotation:annotation];
}

- (UIImage*)imageWithBorderFromImage:(UIImage*)source  //Draw box around centered image
{
    CGSize size = [source size];
    //size = CGSizeMake(size.width+6, size.width+6);
    double squareSize = 22;
    size = CGSizeMake(squareSize, squareSize);
    CGSize sourceSize = [source size];
    //NSLog(@"size: %f %f",sourceSize.height,sourceSize.width);
    UIGraphicsBeginImageContext(size);
    
    double x = squareSize-sourceSize.width;
    double y = squareSize-sourceSize.height;
    
    CGRect rect = CGRectMake(x/2, y/2, sourceSize.width, sourceSize.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    [[UIColor whiteColor] setFill];
    CGRect wrect = CGRectMake(1, 1, size.width-2, size.height-2);
    CGContextFillRect(context, wrect);
    [source drawInRect:rect blendMode:kCGBlendModeNormal alpha:1.0];
    
    
    CGContextSetRGBStrokeColor(context, 0, 0, 0, 1.0); 
    
    CGContextStrokeRect(context, wrect);
    UIImage *testImg =  UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return testImg;
}


-(void) addMarkerAt:(CLLocationCoordinate2D) position withNode: (OPENode *) node
{
    NSLog(@"start addMarkerAt %@",node.image);
    UIImage *icon = [UIImage imageNamed:node.image];   //Get image from stored value in node
    icon = [self imageWithBorderFromImage:icon]; //center image inside box
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:icon anchorPoint:CGPointMake(0.5, 1.0)];
    
    newMarker.data = node;
    [mapView.markerManager addMarker:newMarker AtLatLong:node.coordinate];

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
    
    NSString * titulo = [((OPENode *)annotation.userInfo) getName];
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
    [buttongo addTarget:self action:@selector(testItOut) forControlEvents:UIControlEventTouchUpInside];
    buttongo.frame=CGRectMake(left_width2*2-3, 8, 30, 30); 
    buttongo.userInteractionEnabled=YES; 
    buttongo.enabled=YES;
    [label addSubview:buttongo];
    [label bringSubviewToFront:buttongo];
    
    [annotation.layer setDelegate:self];
    [((RMMarker *)annotation.layer) setDelegate:self];
    
    [((RMMarker *)annotation.layer) setLabel:label];
    
    [label bringSubviewToFront:buttongo];
    [mapView bringSubviewToFront:label];
    [mapView bringSubviewToFront:buttongo];
}
*/

-(void) tapOnMarker:(RMMarker *)marker onMap:(RMMapView *)map
{
    NSString * titulo = [((OPENode *)marker.data) getName];
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
    [buttongo addTarget:self action:@selector(testItOut) forControlEvents:UIControlEventTouchUpInside];
    buttongo.frame=CGRectMake(left_width2*2-3, 8, 30, 30); 
    buttongo.userInteractionEnabled=YES; 
    buttongo.enabled=YES;
    [label addSubview:buttongo];
    [label bringSubviewToFront:buttongo];
    [marker setDelegate:self];
    [marker setLabel:label];
}

- (void) testItOut {
    NSLog(@"COOL");
}


-(void) tapOnLabelForMarker:(RMMarker *)marker onMap:(RMMapView *)map onLayer:(CALayer *)layer
{
    NSLog(@"hello %@",layer.name);
    OPENodeViewController * viewer = [[OPENodeViewController alloc] initWithNibName:@"OPENodeViewController" bundle:nil];
    
    viewer.title = @"Node Info";
    viewer.node = (OPENode *)marker.data;
    
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
        }
    }
}



- (RMMarker *) addNewMarkerAt:(CLLocationCoordinate2D) markerPosition withNode: (OPENode *) node
{
    UIImage *blueMarkerImage = [UIImage imageNamed:@"bar.png"];
    blueMarkerImage = [self imageWithBorderFromImage:blueMarkerImage];
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:blueMarkerImage anchorPoint:CGPointMake(0.5, 1.0)];
    newMarker.data = node;
    [mapView.contents.markerManager addMarker:newMarker AtLatLong:markerPosition];
    return newMarker;
}

- (void) setText: (NSString*) text forMarker: (RMMarker*) marker
{
    CGSize textSize = [text sizeWithFont: [RMMarker defaultFont]]; 
    
    CGPoint position = CGPointMake(  -(textSize.width/2 - marker.bounds.size.width/2), -textSize.height );
    
    [marker changeLabelUsingText: text position: position ];    
}

/*
- (void) tapOnMarker: (RMMarker*) marker onMap: (RMMapView*) map
{
    NSLog(@"name?: %@",[map.contents.layer name]);
    
    //OPENode * tempNode = (OPENode *)marker.data; //Center map
    //[mapView moveToLatLong: tempNode.coordinate];
    if(openMarker) 
    {
        [openMarker hideLabel];
    }
    
    if(openMarker == marker) 
    {
        [openMarker hideLabel];
        self.openMarker = nil;
    } 
    else 
    {
        self.openMarker = marker;
        OPENode * node = (OPENode *)openMarker.data;
        [marker addAnnotationViewWithTitle:[interpreter getName:node]];
        
    }    
}

- (void)pushMapAnnotationDetailedViewControllerDelegate:(id) sender
{
    NSLog(@"Arrow Pressed");
    OPENodeViewController * viewer = [[OPENodeViewController alloc] initWithNibName:@"OPENodeViewController" bundle:nil];
    
    viewer.title = @"Node Info";
    viewer.node = (OPENode *)openMarker.data;
    
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Map" style: UIBarButtonItemStyleBordered target: nil action: nil];
    
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    [self.navigationController pushViewController:viewer animated:YES];
    
}

- (void) tapOnLabelForMarker: (RMMarker*) marker onMap: (RMMapView*) map 
{
    NSLog(@"Label Pressed");
    OPENodeViewController * viewer = [[OPENodeViewController alloc] initWithNibName:@"OPENodeViewController" bundle:nil];
    
    viewer.title = @"Node Info";
    viewer.node = (OPENode *)openMarker.data;
    
    
    UIBarButtonItem *newBackButton = [[UIBarButtonItem alloc] initWithTitle: @"Map" style: UIBarButtonItemStyleBordered target: nil action: nil];
    
    [[self navigationItem] setBackBarButtonItem: newBackButton];
    
    [self.navigationController pushViewController:viewer animated:YES];
}




*/
-(void) afterMapTouch:(RMMapView *)map
{
    NSLog(@"afterMapMove");
    RMSphericalTrapezium geoBox = [mapView latitudeLongitudeBoundingBoxForScreen];
    
    [osmData getDataWithSW:geoBox.southwest NE:geoBox.northeast];
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
    return CLLocationCoordinate2DMake(0, 0);
}

/*
- (IBAction)addPointButtonPressed:(id)sender
{
    if(openMarker) 
    {
        [openMarker hideLabel];
    }
    CLLocationCoordinate2D center = [self centerOfMap];
    if(theNewMarker)
    {
        [mapView.contents.markerManager moveMarker: theNewMarker AtLatLon:center];
    }
    else
    {
        OPENode * node = [[OPENode alloc] initWithId:-1 latitude:center.latitude longitude:center.longitude version:1];
        theNewMarker = [self addNewMarkerAt:center withNode:node];
    }
}
                      
  */                    

-(IBAction)locationButtonPressed:(id)sender
{
    CLLocationCoordinate2D currentLocation = [[locationManager location] coordinate];
    
    //[mapView setCenterCoordinate: currentLocation animated:YES];
}

- (IBAction)infoButtonPressed:(id)sender
{
    NSLog(@"info button pressed");
    OPEInfoViewController * viewer = [[OPEInfoViewController alloc] initWithNibName:@"OPEInfoViewController" bundle:nil];
    viewer.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewer.title = @"Info";
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
    // Return YES for supported orientations
    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
    } else {
        return YES;
    }
}

@end
