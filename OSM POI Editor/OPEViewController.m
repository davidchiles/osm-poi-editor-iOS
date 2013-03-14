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
#import "RMUserLocation.h"
#import "RMAnnotation.h"
#import "OPEPoint.h"
#import "OPEBingTileSource.h"
#import "OPEAPIConstants.h"

#import "OPEManagedOsmElement.h"
#import "OPEManagedReferencePoi.h"
#import "OPEMRUtility.h"
#import "OPEManagedOsmNode.h"


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
@synthesize firstDownload;

@synthesize userPressedLocatoinButton;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

#define MINZOOM 17.0

-(void)setupButtons
{
    //mapView.frame = self.view.bounds;
    
    UIBarButtonItem * locationBarButton;
    UIBarButtonItem * addBarButton;
    UIBarButtonItem * settingsBarButton;
    
    locationBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"]style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonPressed:)];
    
    
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
    firstDownload = NO;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:NO animated:NO];
    //Check OAuth
    
    mapView = [[RMMapView alloc] initWithFrame:self.view.bounds];
    mapView.showLogoBug = NO;
    mapView.hideAttribution = YES;
    mapView.userTrackingMode = RMUserTrackingModeFollow;
    
    
    /*
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(addMarkers:)
     name:@"DownloadComplete"
     object:nil ];
     */
    [self osmElementFetchedResultsController];
    
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
    //[mapView setCenterCoordinate:initLocation animated:YES];
    
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
        newTileSource = [[OPEBingTileSource alloc] initWithMapsKey:bingMapsKey];
        currentTile = 0;
    }
    
    
    [self setTileSource:newTileSource at:num];
    
    currentSquare = [mapView latitudeLongitudeBoundingBox];
    
    osmData = [[OPEOSMData alloc] init];
    
    message = [[OPEMessage alloc] init];
    message.alpha = 0.0;
    
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

-(RMMarker *)markerWithManagedObjectID:(NSManagedObjectID *)managedObjectID
{
    OPEManagedOsmElement * managedOsmElement = (OPEManagedOsmElement *)[OPEMRUtility managedObjectWithID:managedObjectID];
    UIImage * icon;
    if (managedOsmElement.type) {
        if ([imagesDic objectForKey:managedOsmElement.type.imageString]) {
            icon = [imagesDic objectForKey:managedOsmElement.type.imageString];
        }
        else {
            NSString * imageString = managedOsmElement.type.imageString;
            if(![UIImage imageNamed:imageString])
                imageString = @"none.png";
            
            icon = [self imageWithBorderFromImage:[UIImage imageNamed:imageString]]; //center image inside box
            [imagesDic setObject:icon forKey:managedOsmElement.type.imageString];
        }
    }
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:icon anchorPoint:CGPointMake(0.5, 0.5)];
    newMarker.userInfo = managedObjectID;
    newMarker.zPosition = 0.2;
    [managedOsmElement setIsVisibleValue:YES];
    return newMarker;
}

-(RMMapLayer *) mapView:(RMMapView *)mapView layerForAnnotation:(RMAnnotation *)annotation
{
    NSManagedObjectID * managedObjectID = annotation.userInfo;
    
    RMMarker * marker = [self markerWithManagedObjectID:managedObjectID];
    marker.canShowCallout = YES;
    marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return marker;
}

-(RMAnnotation *)annotationWithOsmElement:(OPEManagedOsmElement *)managedOsmElement
{
    RMAnnotation * annotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:[managedOsmElement center] andTitle:[managedOsmElement name]];
    annotation.userInfo = [managedOsmElement objectID];
    
    
    return annotation;
}


- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    [self presentNodeInfoViewControllerWithElement:annotation.userInfo withAnnotation:annotation];
}

- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{   
    return NO;
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

-(void)downloadNewArea:(RMMapView *)map
{
    //dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
    
    RMSphericalTrapezium geoBox = [map latitudeLongitudeBoundingBox];
    if (map.zoom > MINZOOM) {
        [self removeZoomWarning];
        //dispatch_async(q, ^{
        [osmData getDataWithSW:geoBox.southWest NE:geoBox.northEast];
        //});
        //dispatch_release(q);
    }
    else {
        [self showZoomWarning];
    }
}

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    if (wasUserAction || userPressedLocatoinButton) {
        [self downloadNewArea:map];
    }
    
}

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    if (wasUserAction || userPressedLocatoinButton) {
        [self downloadNewArea:map];
    }
}

#pragma - LocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    NSLog(@"Denied Location: %@",error.userInfo);
}

-(void)locationManager:(CLLocationManager *)manager didUpdateToLocation:(CLLocation *)newLocation fromLocation:(CLLocation *)oldLocation
{
    if(newLocation.horizontalAccuracy < 50 && newLocation.horizontalAccuracy >0 )
    {
        userPressedLocatoinButton = YES;
        if(!firstDownload)
        {
            [self downloadNewArea:mapView];
            firstDownload = YES;
        }
        
    }
}

#pragma - NodeViewDelegate

-(void)removeAnnotation:(RMAnnotation *)annotation
{
    [mapView removeAnnotation:annotation];
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
    
    
    
    
    //center = [mapView pixelToCoordinate:plusImageView.center];
    if (mapView.zoom > MINZOOM) {
        
        OPEManagedOsmNode * node = [OPEManagedOsmNode newNode];
        node.lattitudeValue = center.latitude;
        node.longitudeValue = center.longitude;
        
        [OPEMRUtility saveAll];
        
        [self presentNodeInfoViewControllerWithElement:node.objectID withAnnotation:nil];
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
    userPressedLocatoinButton = YES;
    [mapView setCenterCoordinate: mapView.userLocation.coordinate animated:YES];
}

- (IBAction)infoButtonPressed:(id)sender
{
    NSMutableString *attribution = [NSMutableString string];
    
    for (id <RMTileSource>tileSource in mapView.tileSources)
    {
        if ([tileSource respondsToSelector:@selector(shortAttribution)])
        {
            if ([attribution length])
                [attribution appendString:@" "];
            
            if ([tileSource shortAttribution])
                [attribution appendString:[tileSource shortAttribution]];
        }
    }
    //NSLog(@"info button pressed");
    OPEInfoViewController * viewer = [[OPEInfoViewController alloc] init];
    [viewer setDelegate:self];
    viewer.attributionString = attribution;
    //[viewer setCurrentNumber:currentTile];
    viewer.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewer.title = @"Settings";
    [[self navigationController] pushViewController:viewer animated:YES];
}

-(void)presentNodeInfoViewControllerWithElement:(NSManagedObjectID *)elementID withAnnotation:(RMAnnotation *)annotation
{
    OPENodeViewController * nodeViewController = [[OPENodeViewController alloc] initWithOsmElementObjectID:elementID delegate:self];
    nodeViewController.annotation = annotation;
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:nodeViewController];
    
    [self.navigationController presentModalViewController:navController animated:YES];
    
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
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[self.navigationController setToolbarHidden:NO animated:YES];
    
    [self setupButtons];
    userPressedLocatoinButton = NO;
    
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
    //[self.navigationController setNavigationBarHidden:NO animated:YES];
    //[self.navigationController setToolbarHidden:YES animated:YES];
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

#pragma FetchedResultsController

-(void)removeAnnotationWithOsmElementID:(NSManagedObjectID *)objectID
{
    RMAnnotation * annotation = [self annotationForOsmElementID:objectID];
    if (annotation) {
        [mapView removeAnnotation:annotation];
    }

}

-(void)updateAnnotationWithOsmElementID:(NSManagedObjectID *)objectID
{
    RMAnnotation * annotation = [self annotationForOsmElementID:objectID];
    if (annotation) {
        
    }
}

-(RMAnnotation *)annotationForOsmElementID:(NSManagedObjectID *)objectID
{
    RMAnnotation* annotation = nil;
    NSInteger index = [self indexOfOsmElementID:objectID];
    if (index != NSNotFound) {
        annotation = [mapView.annotations objectAtIndex:index];
    }
    return annotation;
}

-(NSInteger)indexOfOsmElementID:(NSManagedObjectID *)objectID
{
    return [mapView.annotations indexOfObjectPassingTest:^BOOL (id obj, NSUInteger idx, BOOL *stop) {
        RMAnnotation * annotation = (RMAnnotation *)obj;
        return [annotation.userInfo isEqual:objectID];
    }];
    
}

-(NSFetchedResultsController *)osmElementFetchedResultsController
{
    if(_osmElementFetchedResultsController)
        return _osmElementFetchedResultsController;
    
    NSPredicate * osmElementFilter = [NSPredicate predicateWithFormat:@"type != nil AND isVisible == NO"];
    
    _osmElementFetchedResultsController = [OPEManagedOsmElement MR_fetchAllGroupedBy:nil withPredicate:osmElementFilter sortedBy:OPEManagedOsmElementAttributes.osmID ascending:NO delegate:self];
    
    return _osmElementFetchedResultsController;
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            OPEManagedOsmElement * managedOsmElement = [controller objectAtIndexPath:newIndexPath];
            [mapView addAnnotation:[self annotationWithOsmElement:managedOsmElement]];
        }
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
        {
            OPEManagedOsmElement * managedOsmElement = [controller objectAtIndexPath:indexPath];
            [self removeAnnotationWithOsmElementID:managedOsmElement.objectID];
            managedOsmElement = [controller objectAtIndexPath:newIndexPath];
            [mapView addAnnotation:[self annotationWithOsmElement:managedOsmElement]];
        }
            break;
        case NSFetchedResultsChangeDelete:
            break;
            
        default:
            break;
    }
}
             
             

@end
