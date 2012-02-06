//
//  CMLBABanner.h
//  LBAApp
//
//  Created by Dmytro Golub on 1/5/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CMLBAConstants.h"
#import <UIKit/UIKit.h>
#import <CoreGraphics/CoreGraphics.h>
//! The CMLBABanner class keeps a properties of the advertising banner.
@interface CMLBABanner : NSObject
{
	NSString* _imageUrl,*_validationUrl,*_webSiteUrl;
	CGSize _size;
	UIImage* _bannerImage;
    CMAdsBehavior  _bannerBehavior; 
	NSArray* _validationUrls;
	NSString* _userAgent;
}
///
@property (readonly) CMAdsBehavior  behavior;
@property (nonatomic,retain) UIImage* bannerImage;
@property (nonatomic,retain,readonly) NSArray* validationUrls;
@property (nonatomic,retain,readonly) NSString* webSiteUrl;



-(id) initWithProperties:(NSDictionary*) propertiesList withBehavior:(CMAdsBehavior) behaviour;
-(void) validateURLs;

@end
