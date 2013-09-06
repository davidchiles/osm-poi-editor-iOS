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
#import "OPEStrings.h"
#import "Note.h"
#import "RMPointAnnotation.h"
#import "OPENoteViewController.h"

#import "OPEManagedOsmElement.h"
#import "OPEManagedReferencePoi.h"
#import "OPEMRUtility.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmRelation.h"
#import "OpeManagedOsmRelationMember.h"
#import "OPEGeo.h"
#import "OPEGeoCentroid.h"
#import "OPENewNodeSelectViewController.h"


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
    
    UIToolbar * toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, 320, 44)];
    toolBar.delegate = self;
    [toolBar setItems:@[locationBarButton,flexibleSpaceBarItem,addBarButton,flexibleSpaceBarItem,settingsBarButton]];
    [self.view addSubview:toolBar];

    //self.toolbarItems = [    //self.navigationItem.rightBarButtonItem = settingsBarButton;
    //self.navigationItem.leftBarButtonItem = locationBarButton;
    //self.navigationItem.titleView = [UIButton buttonWithType:UIButtonTypeContactAdd];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //[self setupButtons];
    firstDownload = NO;
    
    [self.navigationController setNavigationBarHidden:YES animated:NO];
    [self.navigationController setToolbarHidden:YES animated:NO];
    //Check OAuth
    
    id <RMTileSource> newTileSource = [OPEUtility currentTileSource];
    
    mapView = [[RMMapView alloc] initWithFrame:self.view.bounds andTilesource:newTileSource];
    mapView.clusteringEnabled = NO;
    mapView.clusterAreaSize = CGSizeMake(10.0, 10.0);
    mapView.clusterMarkerSize = CGSizeMake(10.0, 10.0);
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
    
    message = [[OPEMessageView alloc] initWithMessage:ZOOM_ERROR_STRING];
    message.alpha = 0.0;
    message.userInteractionEnabled = NO;
    
    imagesDic = [[NSMutableDictionary alloc] init];
    
    downloadedNoNameHighways = [NSMutableDictionary dictionary];
    searchManager = [[OPEOSMSearchManager alloc] init];
}

-(UIBarPosition)positionForBar:(id<UIBarPositioning>)bar
{
    return UIBarPositionTopAttached;
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

-(RMMarker *)markerWithManagedObject:(OPEManagedOsmElement *)managedOsmElement
{
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
    newMarker.userInfo = managedOsmElement;
    newMarker.zPosition = 0.2;
    return newMarker;
}

-(RMShape *) shapeForNoNameStreet:(OPEManagedOsmWay *)osmWay
{
    RMShape * line = [[RMShape alloc]initWithView:mapView];
    NSArray * points = [self.osmData pointsForWay:osmWay];
    
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
    if (!annotation.isClusterAnnotation && [annotation.userInfo isKindOfClass:[OPEManagedOsmElement class]]) {
        OPEManagedOsmElement * managedOsmElement = (OPEManagedOsmElement *)annotation.userInfo;;
        if ([managedOsmElement isKindOfClass:[OPEManagedOsmWay class]]) {
            if (((OPEManagedOsmWay *)managedOsmElement).isNoNameStreet) {
                annotation.clusteringEnabled = NO;
                return [self shapeForNoNameStreet:(OPEManagedOsmWay *)managedOsmElement];
            }
        }
        
        
        RMMarker * marker = [self markerWithManagedObject:managedOsmElement];
        marker.canShowCallout = YES;
        marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        
        return marker;
    }
    RMMarker * marker = [[RMMarker alloc] initWithMapBoxMarkerImage];
    marker.canShowCallout = YES;
    return marker;
}

-(RMAnnotation *)annotationWithNote:(Note *)note
{
    RMPointAnnotation * annotation = [RMPointAnnotation annotationWithMapView:mapView coordinate:note.coordinate andTitle:@"Note"];
    annotation.userInfo = note;
    annotation.layer = [[RMMarker alloc] initWithMapBoxMarkerImage];
    annotation.layer.canShowCallout = NO;
    return annotation;
}

-(NSArray *)annotationWithOsmElement:(OPEManagedOsmElement *)managedOsmElement
{
    //NSLog(@"center: %@",[managedOsmElement center]);
    [self.osmData getTypeFor:managedOsmElement];
    
    RMAnnotation * annotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:[self.osmData centerForElement:managedOsmElement] andTitle:[self.osmData nameForElement:managedOsmElement]];
    
    NSMutableString * subtitleString = [NSMutableString stringWithFormat:@"%@",managedOsmElement.type.categoryName];
    
    if ([[managedOsmElement valueForOsmKey:@"name"] length]) {
        [subtitleString appendFormat:@" - %@",managedOsmElement.type.name];
    }
    annotation.subtitle = subtitleString;
    
    
    annotation.userInfo = managedOsmElement;
    
    if ([managedOsmElement isKindOfClass:[OPEManagedOsmRelation class]]) {
        OPEManagedOsmRelation * managedRelation = (OPEManagedOsmRelation *)managedOsmElement;
        
        NSArray * outerPolygonArray = [self.osmData outerPolygonsForRelation:managedRelation];
        
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
    NSArray * outerPoints = [self.osmData outerPolygonsForRelation:relation];
    NSArray * innerPoints = [self.osmData innerPolygonsForRelation:relation];
    
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
    
    NSArray * points = [self.osmData pointsForWay:way];
    BOOL isArea = [self.osmData isArea:way];
    
    RMAnnotation * newAnnotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:((CLLocation *)[points objectAtIndex:0]).coordinate andTitle:nil];
    
    
    
    RMShape * shape = [[RMShape alloc]initWithView:mapView];
    [shape performBatchOperations:^(RMShape *aShape) {
        [aShape moveToCoordinate:((CLLocation *)[points objectAtIndex:0]).coordinate];
        
        for (CLLocation *point in points)
            [aShape addLineToCoordinate:point.coordinate];
        
        if (isArea) {
            [aShape closePath];
        }
     
        
        
    }];
    shape.lineColor = [UIColor blackColor];
    shape.lineWidth +=1;
    if (isArea) {
        shape.fillColor = [UIColor colorWithWhite:.5 alpha:.6];
    }
    else
    {
        shape.fillColor = [UIColor clearColor];
    }
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
    
    id osmElement = annotation.userInfo;
    
    if ([osmElement isKindOfClass:[OPEManagedOsmWay class]]) {
        OPEManagedOsmWay * osmWay = (OPEManagedOsmWay *)osmElement;
        if (osmWay.isNoNameStreet) {
            
            self.selectedNoNameHighway = annotation;
            [self centerOnOsmWay:osmWay];
            [self showNoNameViewWithType:[NSString stringWithFormat:@"%@ - missing name",[self.osmData highwayTypeForOsmWay:osmWay]]];
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
    else if ([osmElement isKindOfClass:[Note class]])
    {
        OPENoteViewController * viewController = [[OPENoteViewController alloc] initWithNote:osmElement];
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        //[self.navigationController presentModalViewController:navController animated:YES];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
    else if(annotation.isClusterAnnotation)
    {
        NSLog(@"cluster: %@",annotation);
        //NSArray * annonations = [annotation clusteredAnnotations];
    }
}




- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    [self presentNodeInfoViewControllerWithElement:annotation.userInfo];
}

-(void)centerOnOsmWay:(OPEManagedOsmWay *)way
{
    NSArray * points = [self.osmData pointsForWay:way];
    NSInteger centerPoint = floor([points count]/2.0);
    mapView.centerCoordinate = ((CLLocation *)[points objectAtIndex:centerPoint]).coordinate;
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
    //[nameView.textField becomeFirstResponder];
    
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
    if (![self.apiManager canAuth]) {
        [self showAuthError];
    }
    else
    {
        [self.view endEditing:YES];
        [self startSave];
        
        OPEManagedOsmElement * managedElement = (OPEManagedOsmElement*)self.selectedNoNameHighway.userInfo;
        [self.osmData setOsmKey:@"name" andValue:value forElement:managedElement];
        managedElement.action = kActionTypeModify;
        
        //[self.osmData uploadElement:managedElement];
        [self.apiManager uploadElement:managedElement withChangesetComment:[self.osmData changesetCommentfor:managedElement] openedChangeset:^(int64_t changesetID) {
            self.HUD.mode = MBProgressHUDModeIndeterminate;
            self.HUD.labelText = [NSString stringWithFormat:@"%@...",UPLOADING_STRING];
        } updatedElements:^(NSArray *updatedElements) {
            [self.osmData updateElements:updatedElements];
            [self updateAnnotationForOsmElements:updatedElements];
        } closedChangeSet:^(int64_t changesetID) {
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"checkmark.png"]];
            HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText = @"Complete";
            [self.HUD hide:YES afterDelay:1.0];
        } failure:^(NSError *response) {
            self.HUD.customView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"x.png"]];
            HUD.mode = MBProgressHUDModeCustomView;
            self.HUD.labelText =ERROR_STRING;
            [self.HUD hide:YES afterDelay:2.0];
        }];
        
    }
}

- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{   
    return NO;
}

-(void) showZoomWarning
{
    self.message.textLabel.text = ZOOM_ERROR_STRING;
    
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
        node.element.elementID = [self.osmData newElementId];
        node.element.latitude = center.latitude;
        node.element.longitude = center.longitude;
        
        OPENewNodeSelectViewController * newNodeController = [[OPENewNodeSelectViewController alloc] initWithNewElement:node];
        newNodeController.location = center;
        newNodeController.nodeViewDelegate = self;
        
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:newNodeController];
        
        //[self.navigationController presentModalViewController:navController animated:YES];
        [self.navigationController presentViewController:navController animated:YES completion:nil];
        
        //[self presentNodeInfoViewControllerWithElement:node];
    }
    else {
        UIAlertView * zoomAlert = [[UIAlertView alloc]
                                   initWithTitle: ZOOM_ALERT_TITLE_STRING
                                   message: ZOOM_ALERT_STRING
                                   delegate: nil
                                   cancelButtonTitle:OK_STRING
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
    viewer.title = SETTINGS_TITLE_STRING;
    [[self navigationController] pushViewController:viewer animated:YES];
}

-(void)presentNodeInfoViewControllerWithElement:(OPEManagedOsmElement *)element
{
    OPENodeViewController * nodeViewController = [[OPENodeViewController alloc] initWithOsmElement:element delegate:self];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:nodeViewController];
    
    //[self.navigationController presentModalViewController:navController animated:YES];
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
    [locationManager stopUpdatingLocation];
}

-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    //[self.navigationController setNavigationBarHidden:YES animated:YES];
    //[self.navigationController setToolbarHidden:NO animated:YES];
    //[self updateAllAnnotations];
    [self setupButtons];
    userPressedLocatoinButton = NO;
    
    [self removeAllNoNameStreets];
    if ([[OPEUtility currentValueForSettingKey:kShowNoNameStreetsKey] boolValue]) {
        [self addAllNoNameStreets];
    }
    
    
}

-(UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
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

-(void)updateAnnotationForOsmElements:(NSArray *)elementsArray {
    for (OPEManagedOsmElement * element in elementsArray)
    {
        [self removeAnnotationWithOsmElementIDKey:element.idKey];
        if (![element.action isEqualToString:kActionTypeDelete]) {
            NSArray * annotationsArray = [self annotationWithOsmElement:element];
            for(RMAnnotation * annotation in annotationsArray)
                [mapView addAnnotation:annotation];
        }
    }
}

-(void)removeAnnotationWithOsmElementIDKey:(NSString *)idKey
{
    NSSet * annotationSet = [self annotationsForOsmElementIDKey:idKey];
    if ([annotationSet count])
    {
        [mapView removeAnnotations:[annotationSet allObjects]];
    }
}

-(NSSet *)noNameHighwayAnnotaitons
{
    NSIndexSet * indexSet = [self indexesOfNoNameHighways];
    NSMutableSet * annotationSet = [NSMutableSet set];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [annotationSet addObject:[mapView.annotations objectAtIndex:idx]];
    }];
    
    return annotationSet;
}

-(NSSet *)annotationsForOsmElementIDKey:(NSString *)idKey;
{
    NSIndexSet * indexSet = [self indexesOfOsmElementIDKey:idKey];
    NSMutableSet * annotationSet = [NSMutableSet set];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [annotationSet addObject:[mapView.annotations objectAtIndex:idx]];
    }];
    
    return annotationSet;
}

-(NSIndexSet *)indexesOfOsmElementIDKey:(NSString *)idKey;
{
    NSIndexSet * set = [mapView.annotations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RMAnnotation * annotation = (RMAnnotation *)obj;
        if ([annotation.userInfo isKindOfClass:[OPEManagedObject class]]) {
            OPEManagedOsmElement * element = annotation.userInfo;
            return [element.idKey isEqualToString:idKey];
        }
        return NO;
    }];
    return set;
}
-(NSIndexSet *)indexesOfNoNameHighways
{
    NSIndexSet * set = [mapView.annotations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RMAnnotation * annotation = (RMAnnotation *)obj;
        if ([annotation.userInfo isKindOfClass:[OPEManagedOsmWay class]]) {
            OPEManagedOsmWay * element = annotation.userInfo;
            if (element.isNoNameStreet) {
                return YES;
            }

        }
        return NO;
    }];
    return set;
}

-(void)removeAllNoNameStreets
{
    NSSet * annotationSet = [self noNameHighwayAnnotaitons];
    if ([annotationSet count])
    {
        [mapView removeAnnotations:[annotationSet allObjects]];
    }
    
}
-(void)addAllNoNameStreets
{
    NSArray * allNoNameHighways =[searchManager noNameHighways];
    for (OPEManagedOsmWay * way in allNoNameHighways)
    {
        NSArray * annotationsArray = [self annotationWithOsmElement:way];
        for (RMAnnotation * annotation in annotationsArray)
        {
             [mapView addAnnotation:annotation];
        }
    }
}

#pragma OPEOsmDataDelegate

-(void)didFindNewElements:(NSArray *)newElementsArray updatedElements:(NSArray *)updatedElementsArray
{
    for(OPEManagedOsmElement * element in newElementsArray)
    {
        NSArray * annotationsArray = [self annotationWithOsmElement:element];
        for (RMAnnotation * annotation in annotationsArray)
        {
            [mapView addAnnotation:annotation];
        }
        
    }
    
    [self updateAnnotationForOsmElements:updatedElementsArray];
}

-(void)didFindNewNotes:(NSArray *)newNotes
{
    [newNotes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RMAnnotation * annotation = [self annotationWithNote:(Note *)obj];
        [mapView addAnnotation:annotation];
    }];
}

-(void)didCloseChangeset:(int64_t)changesetNumber
{
    [super didCloseChangeset:changesetNumber];
    [mapView removeAnnotation:self.selectedNoNameHighway];
    [self removeNonameView];
    
}
-(void)willStartParsing:(NSString *)typeString
{
    NSString * elementTypeString = @"";
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
        CGRect frame = CGRectMake(0, 0, 130, 40);
        frame.origin.y = self.view.frame.size.height -frame.size.height-self.navigationController.toolbar.frame.size.height-10;
        frame.origin.x = (self.view.frame.size.width -frame.size.width)/2;
        
        
        
        self.parsingMessageView = [[OPEMessageView alloc] initWithIndicator:YES frame:frame];
        //self.parsingMessageView.textLabel.text = [NSString stringWithFormat:@"Finding %@ ...",elementTypeString];
        [self.view addSubview:self.parsingMessageView];
    }
    self.parsingMessageView.textLabel.text = [NSString stringWithFormat:@"%@ %@ ...",@"Parsing",elementTypeString];
    
    
    
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

-(void)didEndParsing
{
    self.numberOfOngoingParses -=1;
    if (self.numberOfOngoingParses < 1) {
        [self.parsingMessageView removeFromSuperview];
        self.parsingMessageView = nil;
    }
}

-(void)downloadFailed:(NSError *)error
{
    message.textLabel.text = DOWNLOAD_ERROR_STRING;
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
