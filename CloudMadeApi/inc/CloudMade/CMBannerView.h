//
//  CMBannerView.h
//  LBAApp
//
//  Created by Dmytro Golub on 1/21/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import <UIKit/UIKit.h>


@class CMLBABanner;
@class RMMapView;
//! The CMLBABannerDelegate protocol defines methods which can be implemented to change the behavior when banner requested,appears, disappears, is tapped by user 
@protocol CMLBABannerDelegate 
/**
 *  Sent to the receiver when banner was touched 		
 */
	-(void) bannerDidTap:(CMLBABanner*) banner; 
/**
 *  Sent to the receiver just after the banner was displayed. 		
 */
	-(void) bannerDidAppear:(CMLBABanner*) banner; 
/**
 *  Sent to the receiver just before the banner will disappear. 		
 */
    -(void) bannerWillDisappear:(CMLBABanner*) banner; 
/**
 *  Sent to the receiver when close button was pressed 		
 */
	-(void) closeButtonTapped:(CMLBABanner*) banner;
@end

//! The CMBannerView class implements a specialized view that manages the advertising banner. 
@interface CMBannerView : UIImageView
{
	//UIImageView* bannerView; 
	id<CMLBABannerDelegate> bannerDelegate;
	CMLBABanner* _banner; 
	int _adsAlighment;
	RMMapView* _parentView;
	UIImageView* _bannerImage;
	//UIButton* _button;
	NSTimer* bannerBehaviourTimer;	
}
//! The banner alighment \sa 
@property(readwrite) int adsAlighment;
//! The banner delegate \sa  CMLBABannerDelegate
@property(nonatomic,retain) id<CMLBABannerDelegate> bannerDelegate ;
/**
 *  Initializes and returns a newly created banner view. 	
 *  @param banner banner properties \sa CMLBABanner
 *  @param view map view
 */
-(id) initWithBanner:(CMLBABanner*) banner inView:(RMMapView*) view;

-(void) closeBanner;
-(void) closeButtonClicked:(NSTimer*) timer;
@end
