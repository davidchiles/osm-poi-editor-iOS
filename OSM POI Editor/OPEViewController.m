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
#import "RMTileCache.h"
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

#import "OPEOsmElement.h"
#import "OPEReferencePoi.h"
#import "OPEOsmNode.h"
#import "OPEOsmWay.h"
#import "OPEOsmRelation.h"
#import "OPEOsmRelationMember.h"
#import "OPEGeo.h"
#import "OPEGeoCentroid.h"
#import "OPENewNodeSelectViewController.h"

#import "OPEMapManager.h"

#import "OPECrosshairMapView.h"

#import "OPELog.h"


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
@synthesize downloadManger = _downloadManger;
@synthesize mapManager;

@synthesize userPressedLocatoinButton;

#pragma mark - View lifecycle

#define MINZOOM 17.0

-(void)setupButtons
{
    //mapView.frame = self.view.bounds;
    
    UIBarButtonItem * locationBarButton;
    UIBarButtonItem * settingsBarButton;
    
    
    
    locationBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"location.png"]style:UIBarButtonItemStylePlain target:self action:@selector(locationButtonPressed:)];
    
    
    addBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"50-plus.png"] style:UIBarButtonItemStylePlain target:self action:@selector(addPointButtonPressed:)];
    
    settingsBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"gear.png"] style:UIBarButtonItemStylePlain target:self action:@selector(infoButtonPressed:)];
    
    downloadBarButton = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"download.png"] style:UIBarButtonItemStylePlain target:self action:@selector(downloadButtonPressed:)];
    downloadOrSpinnerBarButton = downloadBarButton;
    
    
    
    UIBarButtonItem * flexibleSpaceBarItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:nil action:nil];
    
    
    
    
    plusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus.png"]];
    plusImageView.center = self.mapView.center;
    [self.view addSubview:plusImageView];
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, [UIApplication sharedApplication].statusBarFrame.size.height, self.view.bounds.size.width, 44)];
    toolBar.delegate = self;
    [toolBar setItems:@[locationBarButton,flexibleSpaceBarItem,downloadOrSpinnerBarButton,flexibleSpaceBarItem,addBarButton,flexibleSpaceBarItem,settingsBarButton]];
    [self.view addSubview:toolBar];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    mapManager = [[OPEMapManager alloc] init];
    
    id <RMTileSource> newTileSource = [OPEUtility currentTileSource];
    
    self.mapView = [[OPECrosshairMapView alloc] initWithFrame:self.view.bounds andTilesource:newTileSource];
    RMTileCache * tileCache = [[RMTileCache alloc] initWithExpiryPeriod:60*60*24*7]; // one week
    self.mapView.tileCache = tileCache;
    self.mapView.userTrackingMode = RMUserTrackingModeFollow;
    
    [self.mapView setDelegate:self];
    
    locationManager = [[CLLocationManager alloc] init];
    locationManager.delegate = self;
    locationManager.distanceFilter = kCLDistanceFilterNone;
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    
    [locationManager startUpdatingLocation];
    
    CLLocationCoordinate2D initLocation;
    
    initLocation.latitude  = 37.871667;
    initLocation.longitude =  -122.272778;
    
    initLocation = [[locationManager location] coordinate];
    
    if ([[UIScreen mainScreen] respondsToSelector:@selector(scale)] && [[UIScreen mainScreen] scale] == 2){
        self.mapView.contentScaleFactor = 2.0;
    }
    else {
        self.mapView.contentScaleFactor = 1.0;
    }
    
    [self.mapView setZoom: 18];
    
    self.mapView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:self.mapView];
    [self setupButtons];
    
    currentSquare = [self.mapView latitudeLongitudeBoundingBox];
    
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

-(OPEDownloadManager *)downloadManger{
    if (!_downloadManger) {
        _downloadManger = [[OPEDownloadManager alloc] init];
        __weak  OPEViewController * viewController =  self;
        _downloadManger.foundMatchingElementsBlock = ^void(NSArray * newElements, NSArray * updatedElements) {
            [viewController didFindNewElements:newElements updatedElements:updatedElements];
        };
    }
    return _downloadManger;
}

#pragma mark RMMapViewDelegate

- (RMMapLayer *)mapView:(RMMapView *)map layerForAnnotation:(RMAnnotation *)annotation
{
    return [mapManager mapView:map layerForAnnotation:annotation];
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    id osmElement = annotation.userInfo;
    
    if ([osmElement isKindOfClass:[Note class]])
    {
        OPENoteViewController * viewController = [[OPENoteViewController alloc] initWithNote:osmElement];
        UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:viewController];
        
        [self.navigationController presentViewController:navController animated:YES completion:nil];
    }
    else {
        [mapManager tapOnAnnotation:annotation onMap:map];
    }
}


- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)map
{
    [self presentNodeInfoViewControllerWithElement:annotation.userInfo];
}

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    [self checkZoomWithMapview:map];
    if (wasUserAction) {
        [self downloadNotes:map];
    }
    
}

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    [self checkZoomWithMapview:map];
    if (wasUserAction) {
        [self downloadNotes:map];
    }
}

- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{
    return NO;
}


- (void)startDownloading {
    UIActivityIndicatorView * spinnerView= [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    [spinnerView startAnimating];
    NSMutableArray * items = [toolBar.items mutableCopy];
    NSUInteger index = [items indexOfObject:downloadOrSpinnerBarButton];
    [items removeObjectAtIndex:index];
    downloadOrSpinnerBarButton = [[UIBarButtonItem alloc] initWithCustomView:spinnerView];
    [items insertObject:downloadOrSpinnerBarButton atIndex:index];
    toolBar.items = items;
}

- (void)endDownloading {
    NSMutableArray * items = [toolBar.items mutableCopy];
    NSUInteger index = [items indexOfObject:downloadOrSpinnerBarButton];
    [items removeObjectAtIndex:index];
    downloadOrSpinnerBarButton = downloadBarButton;
    [items insertObject:downloadOrSpinnerBarButton atIndex:index];
    toolBar.items = items;
    
}

-(void)checkZoomWithMapview:(RMMapView *)map
{
    if (map.zoom > MINZOOM) {
        //enablebuttons
        addBarButton.enabled = YES;
        downloadBarButton.enabled = YES;
    }
    else {
        addBarButton.enabled = NO;
        downloadBarButton.enabled = NO;
        //disable buttons
    }
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
    [self removeZoomWarning];
    
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
    RMSphericalTrapezium geoBox = [map latitudeLongitudeBoundingBox];
    if (map.zoom > MINZOOM) {
        [self startDownloading];
        [self.downloadManger downloadDataWithSW:geoBox.southWest forNE:geoBox.northEast didStartParsing:^{
            [self willStartParsing:nil];
        } didFinsihParsing:^{
            [self didEndParsing];
        } faiure:^(NSError *error) {
            [self endDownloading];
            [self didEndParsing];
        }];
    }
}

-(void)downloadNotes:(RMMapView * )map
{
    RMSphericalTrapezium geoBox = [map latitudeLongitudeBoundingBox];
    if (map.zoom > MINZOOM) {
        [self.downloadManger downloadNotesWithSW:geoBox.southWest forNE:geoBox.northEast didStartParsing:^{
            DDLogInfo(@"Start parsing Notes");
        } didFinsihParsing:^(NSArray *newNotes) {
            [self didFindNewNotes:newNotes];
        } faiure:^(NSError *error) {
            DDLogError(@"Error");
        }];
    }
}



#pragma - LocationManagerDelegate

-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    DDLogError(@"Denied Location: %@",error.userInfo);
}


#pragma - InfoViewDelegate

-(void)setTileSource:(id)tileSource
{
    if (tileSource) {
        [self.mapView removeAllCachedImages];
        [self.mapView setTileSource:tileSource];
    }
    DDLogInfo(@"TileSource: %@",((id<RMTileSource>)tileSource));
    
}

#pragma - Actions

- (void)addPointButtonPressed:(id)sender
{
    CLLocationCoordinate2D center = self.mapView.centerCoordinate;
    
    if ([self.downloadManger downloadedAreaContainsPoint:center] || YES) {
        DDLogInfo(@"Should be allowed to download");
        if (self.mapView.zoom > MINZOOM) {
            
            OPEOsmNode * node = [OPEOsmNode newNode];
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
    }
    else {
        DDLogError(@"Outside downloaded area");
        
        UIAlertView * zoomAlert = [[UIAlertView alloc]
                                   initWithTitle: ADD_ALERT_TITLE_STRING
                                   message: ADD_ALERT_MESSAGE_STRNG
                                   delegate: nil
                                   cancelButtonTitle:OK_STRING
                                   otherButtonTitles:nil];
        [zoomAlert show];
    }
}

-(void)locationButtonPressed:(id)sender
{
    userPressedLocatoinButton = YES;
    [self.mapView setCenterCoordinate: self.mapView.userLocation.coordinate animated:YES];
}

-(void)downloadButtonPressed:(id)sender
{
    [self downloadNewArea:self.mapView];
}
- (void)infoButtonPressed:(id)sender
{
    NSMutableString *attribution = [NSMutableString string];
    
    for (id <RMTileSource>tileSource in self.mapView.tileSources)
    {
        if ([tileSource respondsToSelector:@selector(shortAttribution)])
        {
            if ([attribution length])
                [attribution appendString:@" "];
            
            if ([tileSource shortAttribution])
                [attribution appendString:[tileSource shortAttribution]];
        }
    }
    OPEInfoViewController * viewer = [[OPEInfoViewController alloc] init];
    [viewer setDelegate:self];
    viewer.attributionString = attribution;
    //[viewer setCurrentNumber:currentTile];
    viewer.modalTransitionStyle = UIModalTransitionStyleFlipHorizontal;
    viewer.title = SETTINGS_TITLE_STRING;
    [[self navigationController] pushViewController:viewer animated:YES];
}

-(void)presentNodeInfoViewControllerWithElement:(OPEOsmElement *)element
{
    OPENodeViewController * nodeViewController = [[OPENodeViewController alloc] initWithOsmElement:element delegate:self];
    UINavigationController * navController = [[UINavigationController alloc] initWithRootViewController:nodeViewController];
    
    [self.navigationController presentViewController:navController animated:YES completion:nil];
    
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
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    userPressedLocatoinButton = NO;
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

#pragma mark OPENOdeViewDelegate
-(void)updateAnnotationForOsmElements:(NSArray *)elementsArray
{
    [self.mapManager updateAnnotationsForOsmElements:elementsArray withMapView:self.mapView];
}

#pragma OPEOsmDataDelegate

-(void)didFindNewElements:(NSArray *)newElementsArray updatedElements:(NSArray *)updatedElementsArray
{
    [self.mapManager addAnnotationsForOsmElements:newElementsArray withMapView:self.mapView];
    [self.mapManager updateAnnotationsForOsmElements:updatedElementsArray withMapView:self.mapView];
}

-(void)didFindNewNotes:(NSArray *)newNotes
{
    [self.mapManager addNotes:newNotes withMapView:self.mapView];
}

-(void)willStartParsing:(NSString *)typeString
{
    [self endDownloading];
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
    [self endDownloading];
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
