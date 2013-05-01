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
#import "RMShape.h"
#import "OPEBingTileSource.h"
#import "OPEAPIConstants.h"
#import "OPEUtility.h"

#import "OPEManagedOsmElement.h"
#import "OPEManagedReferencePoi.h"
#import "OPEMRUtility.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmRelation.h"
#import "OpeManagedOsmRelationMember.h"
#import "OPEGeo.h"
#import "OPEGeoCentroid.h"

#define noNameTag 100


@implementation OPEViewController

@synthesize locationManager;
@synthesize infoButton,location, addOPEPoint;
@synthesize openMarker,theNewMarker, label, calloutLabel;
@synthesize addedNode,nodeInfo,currentLocationMarker;
@synthesize message;
@synthesize imagesDic;
@synthesize currentSquare;
@synthesize firstDownload;
@synthesize selectedNoNameHighway = _selectedNoNameHighway;
@synthesize HUD;
@synthesize parsingMessageView;

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
    
    id <RMTileSource> newTileSource = [OPEUtility currentTileSource];
    
    mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:newTileSource];
    mapView.showLogoBug = NO;
    mapView.hideAttribution = YES;
    mapView.userTrackingMode = RMUserTrackingModeFollow;
    
    HUD = [[MBProgressHUD alloc] initWithView:self.navigationController.view];
    
    
    /*
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(addMarkers:)
     name:@"DownloadComplete"
     object:nil ];
     */
    
   
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
    
    currentSquare = [mapView latitudeLongitudeBoundingBox];
    
    message = [[OPEMessageView alloc] initWithMessage:@"Zoom in to load data"];
    message.alpha = 0.0;
    message.userInteractionEnabled = NO;
    
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
    UIImage * icon = nil;
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
    return newMarker;
}

-(RMShape *) shapeForNoNameStreet:(OPEManagedOsmWay *)osmWay
{
    RMShape * line = [[RMShape alloc]initWithView:mapView];
    NSArray * points = osmWay.points;
    
    [line performBatchOperations:^(RMShape *aShape) {
            [aShape moveToCoordinate:((CLLocation *)[points objectAtIndex:0]).coordinate];
            
            for (CLLocation *point in points)
                [aShape addLineToCoordinate:point.coordinate];
            
    }];
     
    line.lineColor = [UIColor redColor];
    line.lineWidth +=10;
    line.lineCap = kCALineCapRound;
    line.lineJoin = kCALineJoinRound;
    line.canShowCallout = NO;
    
    return line;
}

-(RMMapLayer *) mapView:(RMMapView *)mView layerForAnnotation:(RMAnnotation *)annotation
{
    NSManagedObjectID * managedObjectID = annotation.userInfo;
    
    OPEManagedOsmElement * managedOsmElement = (OPEManagedOsmElement *)[OPEMRUtility managedObjectWithID:managedObjectID];
    if ([managedOsmElement isKindOfClass:[OPEManagedOsmWay class]]) {
        if (((OPEManagedOsmWay *)managedOsmElement).isNoNameStreet) {
            return [self shapeForNoNameStreet:(OPEManagedOsmWay *)managedOsmElement];
        }
    }
    
    
    RMMarker * marker = [self markerWithManagedObjectID:managedObjectID];
    marker.canShowCallout = YES;
    marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    
    return marker;
}

-(NSArray *)annotationWithOsmElement:(OPEManagedOsmElement *)managedOsmElement
{
    //NSLog(@"center: %@",[managedOsmElement center]);
    RMAnnotation * annotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:[managedOsmElement center] andTitle:[managedOsmElement name]];
    NSMutableString * subtitleString = [NSMutableString stringWithFormat:@"%@",managedOsmElement.type.categoryName];
    
    if ([[managedOsmElement valueForOsmKey:@"name"] length]) {
        [subtitleString appendFormat:@" - %@",managedOsmElement.type.name];
    }
    annotation.subtitle = subtitleString;
    
    
    //FIXME annotation.userInfo = [managedOsmElement objectID];
    
    if ([managedOsmElement isKindOfClass:[OPEManagedOsmRelation class]]) {
        OPEManagedOsmRelation * managedRelation = (OPEManagedOsmRelation *)managedOsmElement;
        
        NSArray * outerPolygonArray = [managedRelation outerPolygons];
        
        NSMutableArray * annotationsArray = [NSMutableArray array];
        for (NSArray * pointsArray in outerPolygonArray)
        {
            
            CLLocationCoordinate2D center = [[[OPEGeoCentroid alloc] init] centroidOfPolygon:pointsArray];
            RMAnnotation * newAnnoation = [RMAnnotation annotationWithMapView:mapView coordinate:center andTitle:annotation.title];
            newAnnoation.subtitle = annotation.subtitle;
            newAnnoation.userInfo = annotation.userInfo;
            //set center for each outer;
            [annotationsArray addObject:newAnnoation];
        }
        if ([annotationsArray count]) {
            return annotationsArray;
        }
        
    }
    
    
    return @[annotation];
}

-(void)setSelectedNoNameHighway:(RMAnnotation *)newSelectedNoNameHighway
{
    if (_selectedNoNameHighway) {
        ((RMShape *)_selectedNoNameHighway.layer).lineColor = [UIColor redColor];
    }
    
    _selectedNoNameHighway = newSelectedNoNameHighway;
    
    if (_selectedNoNameHighway) {
        ((RMShape *)_selectedNoNameHighway.layer).lineColor = [UIColor greenColor];
    }
    
}

-(RMAnnotation *)shapeForRelation:(OPEManagedOsmRelation *)relation
{
    NSArray * outerPoints = [relation outerPolygons];
    NSArray * innerPoints = [relation innerPolygons];
    
    if (![outerPoints count]) {
        return nil;
    }
    RMAnnotation * newAnnotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:((CLLocation *)[[outerPoints objectAtIndex:0] objectAtIndex:0]).coordinate andTitle:nil];
    
    RMShape *shape = [[RMShape alloc] initWithView:mapView];
    
    [shape performBatchOperations:^(RMShape *aShape)
     {
         
         
         for (NSArray * points in outerPoints)
         {
             [aShape moveToCoordinate:((CLLocation *)[points objectAtIndex:0]).coordinate];
             for (CLLocation *point in points)
             {
                 [aShape addLineToCoordinate:point.coordinate];
             }
             //[aShape closePath];
             
         }
         
         
         
         
         if ([innerPoints count])
         {
             [aShape moveToCoordinate:((CLLocation *)[[innerPoints objectAtIndex:0] objectAtIndex:0]).coordinate];
             for (NSArray * points in innerPoints)
             {
                 [aShape moveToCoordinate:((CLLocation *)[points objectAtIndex:0]).coordinate];
                 for (CLLocation *point in points)
                 {
                     [aShape addLineToCoordinate:point.coordinate];
                 }
                 //[aShape closePath];
                 
             }
                 
             
             
         }
         aShape.lineColor = [UIColor blackColor];
         aShape.lineWidth +=1;
         aShape.fillColor = [UIColor colorWithWhite:.5 alpha:.6];
         aShape.fillRule  = kCAFillRuleEvenOdd;
     }];
    
    newAnnotation.layer = shape;
    return newAnnotation;
    
}

-(RMAnnotation *)shapeForWay:(OPEManagedOsmWay *)way
{
    
    NSArray * points = [way points];
    
    RMAnnotation * newAnnotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:((CLLocation *)[points objectAtIndex:0]).coordinate andTitle:nil];
    
    
    
    RMShape * shape = [[RMShape alloc]initWithView:mapView];
    [shape performBatchOperations:^(RMShape *aShape) {
        [aShape moveToCoordinate:((CLLocation *)[points objectAtIndex:0]).coordinate];
        
        for (CLLocation *point in points)
            [aShape addLineToCoordinate:point.coordinate];
        
        [aShape closePath];
        
        
    }];
    shape.lineColor = [UIColor blackColor];
    shape.lineWidth +=1;
    shape.fillColor = [UIColor colorWithWhite:.5 alpha:.6];
    newAnnotation.layer = shape;
    return newAnnotation;
    
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    if (wayAnnotation) {
        [map removeAnnotation:wayAnnotation];
        wayAnnotation = nil;
    }
    
    
    [self removeNonameView];
    
    id osmElement = [OPEMRUtility managedObjectWithID:annotation.userInfo];
    
    if ([osmElement isKindOfClass:[OPEManagedOsmWay class]]) {
        OPEManagedOsmWay * osmWay = (OPEManagedOsmWay *)osmElement;
        if (osmWay.isNoNameStreet) {
            
            self.selectedNoNameHighway = annotation;
            [self showNoNameViewWithType:[NSString stringWithFormat:@"%@ - missing name",[osmWay highwayType]]];
            return;
        }
        
        
        wayAnnotation = [self shapeForWay:osmWay];
        wayAnnotation.userInfo = annotation.userInfo;
        [mapView addAnnotation:wayAnnotation];
    }
    else if ([osmElement isKindOfClass:[OPEManagedOsmRelation  class]])
    {
        OPEManagedOsmRelation * osmRelation = (OPEManagedOsmRelation *)osmElement;
        wayAnnotation = [self shapeForRelation:osmRelation];
        wayAnnotation.userInfo = annotation.userInfo;
        [mapView addAnnotation:wayAnnotation];
    }
    
    
}




- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    [self presentNodeInfoViewControllerWithElement:annotation.userInfo];
}

-(void)showNoNameViewWithType:(NSString *)type;
{
    CGFloat height = 50.0;
    OPENameEditView * nameView = [[OPENameEditView alloc] initWithFrame:CGRectMake(0, -height, self.view.frame.size.width, height) andType:type];
    nameView.tag = noNameTag;
    nameView.delegate = self;
    
    [self.view addSubview:nameView];
    
    [UIView beginAnimations:nil context:NULL];
    {
        [UIView setAnimationCurve:UIViewAnimationCurveEaseIn];
        [UIView setAnimationDuration:.3];
        CGRect frame = nameView.frame;
        CGRect mapFrame = mapView.frame;
        mapFrame.origin.y = frame.size.height;
        frame.origin.y = 0;
        nameView.frame = frame;
        mapView.frame = mapFrame;
        
    }
    [UIView commitAnimations];
    [nameView.textField becomeFirstResponder];
    
}

-(void)removeNonameView
{
    UIView * nameView = [self.view viewWithTag:noNameTag];
    
    if (nameView) {
        self.selectedNoNameHighway = nil;
        [UIView beginAnimations:nil context:NULL];
        {
            [UIView setAnimationCurve:UIViewAnimationCurveEaseOut];
            [UIView setAnimationDuration:.3];
            CGRect frame = nameView.frame;
            CGRect mapFrame = mapView.frame;
            mapFrame.origin.y = 0;
            frame.origin.y = -frame.size.height;
            nameView.frame = frame;
            mapView.frame = mapFrame;
            
        }
        [UIView commitAnimations];
        [nameView removeFromSuperview];
        nameView = nil;
    }
}
-(void)saveValue:(NSString *)value
{
    if (![self.osmData canAuth]) {
        [self showAuthError];
    }
    else
    {
        [self.view endEditing:YES];
        [self startSave];
        
        OPEManagedOsmTag * tag = [OPEManagedOsmTag fetchOrCreateWithKey:@"name" value:value];
        OPEManagedOsmElement * managedElement = (OPEManagedOsmElement*)[OPEMRUtility managedObjectWithID:self.selectedNoNameHighway.userInfo];
        //FIXME [managedElement addTagsObject:tag];
        managedElement.action = kActionTypeModify;
        NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
        
        [self.osmData uploadElement:managedElement];
    }
}

- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{   
    return NO;
}

-(void) showZoomWarning
{
    self.message.textLabel.text = @"Zoom in to load data";
    
    if (![message.superview isEqual:self.view]) {
        self.message.alpha = 0.0;
        [self.view addSubview:message];
    }
    
    [UIView animateWithDuration:1.0 animations:^{
        self.message.alpha = .8;
    }];
    
}
-(void) removeZoomWarning
{
    if (![self.message.layer.animationKeys count]) {
        [UIView animateWithDuration:0.8 delay:0.0 options:UIViewAnimationCurveEaseOut animations:^{
            self.message.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.message removeFromSuperview];
            }
        }];
    }    
}

-(void)downloadNewArea:(RMMapView *)map
{
    //dispatch_queue_t q = dispatch_queue_create("queue", NULL);
    
    
    RMSphericalTrapezium geoBox = [map latitudeLongitudeBoundingBox];
    if (map.zoom > MINZOOM) {
        [self removeZoomWarning];
        //dispatch_async(q, ^{
        [self.osmData getDataWithSW:geoBox.southWest NE:geoBox.northEast];
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


#pragma - InfoViewDelegate

-(void)setTileSource:(id)tileSource
{
    if (tileSource) {
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
        node.element.latitude = center.latitude;
        node.element.longitude = center.longitude;
        
        [OPEMRUtility saveAll];
        
        //FIXME [self presentNodeInfoViewControllerWithElement:node.objectID];
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

-(BOOL)showNoNameStreets
{
    NSNumber * number = [OPEUtility currentValueForSettingKey:kShowNoNameStreetsKey];
    BOOL boolValue = [number boolValue];
    return boolValue;
    //[[OPEUtility currentValueForSettingKey:kShowNoNameStreetsKey]boolValue];
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

-(void)presentNodeInfoViewControllerWithElement:(NSManagedObjectID *)elementID
{
    OPENodeViewController * nodeViewController = [[OPENodeViewController alloc] initWithOsmElementObjectID:elementID delegate:self];
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
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:NO animated:YES];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[self.navigationController setToolbarHidden:NO animated:YES];
    [self updateAllAnnotations];
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

-(void)updateAllAnnotations
{
    [mapView removeAllAnnotations];
    for (OPEManagedOsmElement * element in [self.osmElementFetchedResultsController fetchedObjects])
    {
        //FIXME [self updateOsmElementWithID:element.objectID];
    }
    
    if ([self showNoNameStreets]) {
        for (OPEManagedOsmElement * element in [self.noNameStreetsFetchedResultsController fetchedObjects])
        {
            //FIXME [self updateOsmElementWithID:element.objectID];
        }
    }
    else
    {
        _noNameStreetsFetchedResultsController.delegate = nil;
        _noNameStreetsFetchedResultsController = nil;
    }
}

#pragma FetchedResultsController

-(void)updateOsmElementWithID:(NSManagedObjectID *)objectID
{
    [self removeAnnotationWithOsmElementID:objectID];
    OPEManagedOsmElement * element = (OPEManagedOsmElement *)[OPEMRUtility managedObjectWithID:objectID];
    if (![element.action isEqualToString:kActionTypeDelete]) {
        NSArray * annotationsArray = [self annotationWithOsmElement:element];
        for(RMAnnotation * annotation in annotationsArray)
        [mapView addAnnotation:annotation];
    }
    
    
}

-(void)removeAnnotationWithOsmElementID:(NSManagedObjectID *)objectID
{
    NSSet * annotationSet = [self annotationsForOsmElementID:objectID];
    if ([annotationSet count])
    {
        [mapView removeAnnotations:[annotationSet allObjects]];
    }
}

-(NSSet *)annotationsForOsmElementID:(NSManagedObjectID *)objectID
{
    NSIndexSet * indexSet = [self indexesOfOsmElementID:objectID];
    NSMutableSet * annotationSet = [NSMutableSet set];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [annotationSet addObject:[mapView.annotations objectAtIndex:idx]];
    }];
    
    return annotationSet;
}

-(NSIndexSet *)indexesOfOsmElementID:(NSManagedObjectID *)objectID
{
    NSIndexSet * set = [mapView.annotations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RMAnnotation * annotation = (RMAnnotation *)obj;
        return [annotation.userInfo isEqual:objectID];
    }];
    return set;
}

-(NSFetchedResultsController *)osmElementFetchedResultsController
{
    if(_osmElementFetchedResultsController)
        return _osmElementFetchedResultsController;
    
    NSPredicate * osmElementFilter = [NSPredicate predicateWithFormat:@"type != nil AND isVisible == YES AND action!=%@",kActionTypeDelete];
    
    //_osmElementFetchedResultsController = [OPEManagedOsmElement MR_fetchAllGroupedBy:nil withPredicate:osmElementFilter sortedBy:OPEManagedOsmElementAttributes.osmID ascending:NO delegate:self];
    
    return nil;
}

-(NSFetchedResultsController *)noNameStreetsFetchedResultsController
{
    /*
    if(_noNameStreetsFetchedResultsController)
        return _noNameStreetsFetchedResultsController;
    
    NSPredicate * noNameFilter = [NSPredicate predicateWithFormat:@"%K == YES",OPEManagedOsmWayAttributes.isNoNameStreet];
    
    _noNameStreetsFetchedResultsController = [OPEManagedOsmWay MR_fetchAllGroupedBy:nil withPredicate:noNameFilter sortedBy:OPEManagedOsmElementAttributes.osmID ascending:NO delegate:self];
    
    return _noNameStreetsFetchedResultsController;
     */
    
}

-(void)controller:(NSFetchedResultsController *)controller didChangeObject:(id)anObject atIndexPath:(NSIndexPath *)indexPath forChangeType:(NSFetchedResultsChangeType)type newIndexPath:(NSIndexPath *)newIndexPath
{
    /*
    switch (type) {
        case NSFetchedResultsChangeInsert:
        {
            OPEManagedOsmElement * managedOsmElement = [controller objectAtIndexPath:newIndexPath];
            [self updateOsmElementWithID:managedOsmElement.objectID];
        }
            break;
        case NSFetchedResultsChangeMove:
            break;
        case NSFetchedResultsChangeUpdate:
        {
            OPEManagedOsmElement * managedOsmElement = [controller objectAtIndexPath:indexPath];
            [self updateOsmElementWithID:managedOsmElement.objectID];
        }
            break;
        case NSFetchedResultsChangeDelete:
            break;
            
        default:
            break;
    }
     */
}

#pragma OPEOsmDataDelegate

-(void)didCloseChangeset:(int64_t)changesetNumber
{
    [super didCloseChangeset:changesetNumber];
    [self removeNonameView];
    
}
-(void)willStartParsing:(NSString *)typeString
{
    NSString * elementTypeString = nil;
    if ([typeString isEqualToString:kOPEOsmElementNode]) {
        elementTypeString = @"Nodes";
    }
    else if ([typeString isEqualToString:kOPEOsmElementWay]) {
        elementTypeString = @"Ways";
    }
    else if ([typeString isEqualToString:kOPEOsmElementRelation]) {
        elementTypeString = @"Relations";
    }
    
    
    if (self.numberOfOngoingParses < 1) {
        CGRect frame = CGRectMake(0, 0, 200, 40);
        frame.origin.y = self.view.frame.size.height -frame.size.height-10;
        frame.origin.x = (self.view.frame.size.width -frame.size.width)/2;
        
        
        
        self.parsingMessageView = [[OPEMessageView alloc] initWithIndicator:YES frame:frame];
        //self.parsingMessageView.textLabel.text = [NSString stringWithFormat:@"Finding %@ ...",elementTypeString];
        [self.view addSubview:self.parsingMessageView];
    }
    self.parsingMessageView.textLabel.text = [NSString stringWithFormat:@"Finding %@ ...",elementTypeString];
    
    
    
    self.numberOfOngoingParses += 1;

}
-(void)didEndParsing:(NSString *)typeString
{
    self.numberOfOngoingParses -=1;
    if (self.numberOfOngoingParses < 1) {
        [self.parsingMessageView removeFromSuperview];
        self.parsingMessageView = nil;
    }
}

-(void)downloadFailed:(NSError *)error
{
    message.textLabel.text = @"Download Error";
    if (![message.superview isEqual:self.view]) {
        message.alpha = 0.0;
        [self.view addSubview:self.message];
    }
    
    [UIView animateWithDuration:1.0 animations:^{
        message.alpha =.8;
        
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:1.0 delay:1.0 options:UIViewAnimationCurveEaseOut animations:^{
            self.message.alpha = 0.0;
        } completion:^(BOOL finished) {
            if (finished) {
                [self.message removeFromSuperview];
            }
        }];
    }];
    
}

@end
