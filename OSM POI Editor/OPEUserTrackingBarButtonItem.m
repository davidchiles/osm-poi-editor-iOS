//
//  OPEUserTrackingBarButtonItem.m
//  OSM POI Editor
//
//  Created by David on 11/1/12.
//
//

#import "OPEUserTrackingBarButtonItem.h"

#import <QuartzCore/QuartzCore.h>
#import "RMMapView.h"
#import "RMUserLocation.h"
#import "OPEUtility.h"

typedef enum {
    RMUserTrackingButtonStateActivity = 0,
    RMUserTrackingButtonStateLocation = 1,
    RMUserTrackingButtonStateHeading  = 2,
    RMUserTrackingButtonStateNone = 3
} RMUserTrackingButtonState;

@interface OPEUserTrackingBarButtonItem ()

@property (nonatomic, strong) UIImageView *buttonImageView;
@property (nonatomic, strong) UIActivityIndicatorView *activityView;
@property (nonatomic) RMUserTrackingButtonState state;

- (void)updateAppearance;
- (void)changeMode:(id)sender;

@end

#pragma mark -

@implementation OPEUserTrackingBarButtonItem

@synthesize mapView = _mapView;
@synthesize buttonImageView;
@synthesize activityView;
@synthesize state;

- (id)initWithMapView:(RMMapView *)mapView
{
    
    if ( ! (self = [super initWithCustomView:[[UIControl alloc] initWithFrame:CGRectMake(0, 0, 32, 32)]]))
        return nil;
    
    
    
    buttonImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"TrackingLocation.png"]];
    buttonImageView.contentMode = UIViewContentModeCenter;
    buttonImageView.frame = CGRectMake(0, 0, 32, 32);
    buttonImageView.center = self.customView.center;
    buttonImageView.userInteractionEnabled = NO;
    

    [self.customView addSubview:buttonImageView];
    
    activityView = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
    activityView.hidesWhenStopped = YES;
    activityView.center = self.customView.center;
    activityView.userInteractionEnabled = NO;
    
    [self.customView addSubview:activityView];
    
    [((UIControl *)self.customView) addTarget:self action:@selector(changeMode:) forControlEvents:UIControlEventTouchUpInside];
    
    _mapView = mapView;
    
    [_mapView addObserver:self forKeyPath:@"userTrackingMode"      options:NSKeyValueObservingOptionNew context:nil];
    [_mapView addObserver:self forKeyPath:@"userLocation.location" options:NSKeyValueObservingOptionNew context:nil];
    
    state = RMUserTrackingButtonStateLocation;
    
    [self updateAppearance];
    
    return self;

}

- (void)dealloc
{
    buttonImageView = nil;
    activityView = nil;
    [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
    [_mapView removeObserver:self forKeyPath:@"userLocation.location"];
    _mapView = nil;
    
}

#pragma mark -

- (void)setMapView:(RMMapView *)newMapView
{
    if ( ! [newMapView isEqual:_mapView])
    {
        [_mapView removeObserver:self forKeyPath:@"userTrackingMode"];
        [_mapView removeObserver:self forKeyPath:@"userLocation.location"];
        
        [_mapView addObserver:self forKeyPath:@"userTrackingMode"      options:NSKeyValueObservingOptionNew context:nil];
        [_mapView addObserver:self forKeyPath:@"userLocation.location" options:NSKeyValueObservingOptionNew context:nil];
        
        [self updateAppearance];
    }
}

- (void)setTintColor:(UIColor *)newTintColor
{
    [super setTintColor:newTintColor];
    
}

#pragma mark -

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    [self updateAppearance];
}

#pragma mark -

- (void)updateAppearance
{
    // "selection" state
    //
    //segmentedControl.selectedSegmentIndex = (_mapView.userTrackingMode == RMUserTrackingModeNone ? UISegmentedControlNoSegment : 0);
    
    // activity/image state
    //
    if (_mapView.userTrackingMode != RMUserTrackingModeNone && ( ! _mapView.userLocation || ! _mapView.userLocation.location || (_mapView.userLocation.location.coordinate.latitude == 0 && _mapView.userLocation.location.coordinate.longitude == 0)))
    {
        // if we should be tracking but don't yet have a location, show activity
        //
        [UIView animateWithDuration:0.25
                              delay:0.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^(void)
         {
             buttonImageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
             activityView.transform    = CGAffineTransformMakeScale(0.01, 0.01);
         }
                         completion:^(BOOL finished)
         {
             buttonImageView.hidden = YES;
             
             [activityView startAnimating];
             
             [UIView animateWithDuration:0.25 animations:^(void)
              {
                  buttonImageView.transform = CGAffineTransformIdentity;
                  activityView.transform    = CGAffineTransformIdentity;
              }];
         }];
        
        state = RMUserTrackingButtonStateActivity;
    }
    else
    {
   
            // if image state doesn't match mode, update it
            //
            NSTimeInterval animateTime= .25;
            UIImage * newImage;
            
            if(_mapView.userTrackingMode == RMUserTrackingModeFollow)
            {
                newImage = [OPEUtility imageNamed:(_mapView.userTrackingMode == RMUserTrackingModeFollowWithHeading ? @"TrackingHeading.png" : @"TrackingLocation.png") withColor:[UIColor blueColor]];
                animateTime = 0.0;
                state = RMUserTrackingButtonStateLocation;
            }
            else if(_mapView.userTrackingMode == RMUserTrackingModeNone && state == RMUserTrackingButtonStateLocation)
            {
                newImage = [UIImage imageNamed:@"TrackingLocation.png"];
                state = RMUserTrackingButtonStateNone;
                animateTime = 0.0;
            }
            else if (_mapView.userTrackingMode == RMUserTrackingModeFollowWithHeading && state == RMUserTrackingButtonStateLocation)
            {
                newImage = [OPEUtility imageNamed:(_mapView.userTrackingMode == RMUserTrackingModeFollowWithHeading ? @"TrackingHeading.png" : @"TrackingLocation.png") withColor:[UIColor blueColor]];
                state = RMUserTrackingButtonStateHeading;
            }
            else if (_mapView.userTrackingMode != RMUserTrackingModeFollowWithHeading && state == RMUserTrackingButtonStateHeading)
            {
                newImage = newImage = [UIImage imageNamed:@"TrackingLocation.png"];
                state = RMUserTrackingButtonStateNone;
                
            }
        
            if(state == RMUserTrackingButtonStateActivity)
                animateTime = .25;
            
            [UIView animateWithDuration:animateTime
                                  delay:0.0
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^(void)
             {
                 buttonImageView.transform = CGAffineTransformMakeScale(0.01, 0.01);
                 activityView.transform    = CGAffineTransformMakeScale(0.01, 0.01);
             }
                             completion:^(BOOL finished)
             {
                 buttonImageView.image = newImage;
                 
                 
                 buttonImageView.hidden = NO;
            
                
                 
                 [activityView stopAnimating];
                 
                 [UIView animateWithDuration:animateTime animations:^(void)
                  {
                      buttonImageView.transform = CGAffineTransformIdentity;
                      activityView.transform    = CGAffineTransformIdentity;
                  }];
             }];
            
            
        
        
    }
}

- (void)changeMode:(id)sender
{
    if (_mapView)
    {
        switch (_mapView.userTrackingMode)
        {
            case RMUserTrackingModeNone:
            default:
            {
                _mapView.userTrackingMode = RMUserTrackingModeFollow;
                
                break;
            }
            case RMUserTrackingModeFollow:
            {
                if ([CLLocationManager headingAvailable])
                    _mapView.userTrackingMode = RMUserTrackingModeFollowWithHeading;
                else
                    _mapView.userTrackingMode = RMUserTrackingModeNone;
                
                break;
            }
            case RMUserTrackingModeFollowWithHeading:
            {
                _mapView.userTrackingMode = RMUserTrackingModeNone;
                
                break;
            }
        }
    }
    
    [self updateAppearance];
}

@end
