//
//  CMLBAManager.h
//  LBAApp
//
//  Created by Dmytro Golub on 1/5/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "RMLatLong.h"
#import "CMLBAConstants.h"
#import "CMBannerView.h"

@class RMMapView;
@class TokenManager;

//! The CMLBAManagerDelegate protocol defines methods which can be implemented to change the behavior when banner requested,appears, disappears, is tapped by user 
@protocol CMLBAManagerDelegate
@optional
/**
 *  Notifies the receiver just before the banner will be requested. 		
 */
  -(void) bannerWillBeRequested; 
/**
 *  Notifies the receiver just before the banner will be displayed. 		
 */
-(void) bannerWillAppear;
/**
 *  Notifies the receiver just after the banner appeared. 		
 */
  -(void) bannerDidAppear;
/**
 *  Notifies the receiver that the banner is about to disappear. 		
 */
-(void) bannerWillDisappear;
/**
 *  Notifies the receiver when user's taped the banner. 		
 */
-(void) bannerDidTap;
/**
 *   Notifies the receiver that ad's response is empty.
 *
 */
-(void) bannerDidFailToLoad;
/**
 *   Returns title for the ad's browser.
 *
 \code
 -(NSString*) titleForAdBrowser
 {
    return @"Ads Browser";
 }
 \endcode
 */
-(NSString*) titleForAdBrowser;
@end

//! The CMLBAManager class provides an access to location based advertising 
@interface CMLBAManager : NSObject <CMLBABannerDelegate>
{
	TokenManager* _tokenManager;
	RMMapView* _mapView;	
	UIViewController* _mapViewController;
	NSDictionary* _adSize;
	CMAdsAlighment _adsAlighment;
	CMAdsBehavior  _adsBehavior; 
	CMBannerView* _bannerView;	
	NSString* _keywords;
	id<CMLBAManagerDelegate> delegate;
	BOOL _disabledForCurrentSession;
	BOOL _testingMode;
	NSString* _userAgent; 
	CLLocationCoordinate2D _location;
	NSString* _query;
}

///---------------------------------------------------------------------------------------
/// @name Properties
///---------------------------------------------------------------------------------------

//! parent view controller is used by BrowserViewController as the parent view controller \sa  BrowserViewController
@property (nonatomic,assign) UIViewController* mapViewController;
//! banner alighment \sa CMAdsAlighment
@property (readwrite) CMAdsAlighment alighment;
//! banner behavior \sa CMAdsBehavior
@property (readwrite) CMAdsBehavior behavior;
//! keywords string which will be added to ads request to make ads search more relevant
@property (nonatomic,retain) NSString* keywords;
//! delegate \sa CMLBAManagerDelegate
@property (nonatomic,retain) id<CMLBAManagerDelegate> delegate;
//! enables testing mode. If testing mode is enabled you get test ads which has to be used for testing purposes only 
@property (readwrite) BOOL testingMode;
//! location parameter for ads \sa http://developers.cloudmade.com/wiki/lba/Documentation
@property (readwrite) CLLocationCoordinate2D location;
//! query parameter for ads \sa http://developers.cloudmade.com/wiki/lba/Documentation
@property (nonatomic,retain) NSString* query;

///---------------------------------------------------------------------------------------
/// @name Creating and Initializing
///---------------------------------------------------------------------------------------

/**
 *  initialize the class 		
 *  @param tokenManager token manager \sa TokenManager
 *  @param mapView map view 
 */
-(id) initWithTokenManager:(TokenManager*) tokenManager inView:(RMMapView*) mapView;

///---------------------------------------------------------------------------------------
/// @name Ads request methods
///---------------------------------------------------------------------------------------
/**
 *  Requests an ads with the given properties 
 *  @param bbox bounding box for which advertising should be search
 *  @param sizes banner size, can be more that one size eg. ADSize_125x125|ADSize_300x250 etc \sa CMAdsSize
 */
-(void) adForBBox:(RMSphericalTrapezium) bbox withSizes:(NSUInteger) sizes;

/**
 *  Requests an ads with the given properties 
 *  @param bbox bounding box for which advertising should be search
 *  @param size banner size, which defines max width and max height for a banner  
 *  @discussion Using of this method is strongly recommended since it provides the highest fill rate for the ads
 *  more details can be found <a href="http://developers.cloudmade.com/wiki/lba/Documentation#Recommendations ">here</a>   
 */
-(void) adForBBox:(RMSphericalTrapezium)bbox  boundBySize:(CGSize) size;


#ifdef _UNIT_TESTS_
-(NSString*) urlForAdWithBBox:(RMSphericalTrapezium) bbox withSize:(CMAdsSize) size;
#endif

@end
