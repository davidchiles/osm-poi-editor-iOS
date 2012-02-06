//
//  HelperConstant.h
//  NavigationView
//
//  Created by Dmytro Golub on 2/11/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//


//#define DEFAULT_LATITUDE  52.377538
//#define DEFAULT_LONGITUDE 4.895375


#define DEFAULT_LATITUDE 51.50757
#define DEFAULT_LONGITUDE -0.1078

#define ROUTING_VERSION @"0.3"

//#define DEFAULT_LATITUDE 50.4363
//#define DEFAULT_LONGITUDE 30.5396

#define APIKEY  "518f15c781b5484cb89f78925904b783"

#define DROPPED_TOUCH_MOVED_EVENTS_RATIO  (0.8)
#define ZOOM_IN_TOUCH_SPACING_RATIO       (0.75)
#define ZOOM_OUT_TOUCH_SPACING_RATIO      (1.5)



#define TERM_OF_USE_PORTRAIT  CGPointMake(160,388)
#define MAP_FRAME_PORTRAIT    CGRectMake(0,0 ,320,412)
#define TERM_OF_USE_LANDSCAPE  CGPointMake(240,259)
#define MAP_FRAME_LANDSCAPE    CGRectMake(0,0 ,480,320)
#define DEFAULT_IMAGE_NAME "000.png"
#define DEFAULT_PHOTO_NAME @"noimage.png"
#define DEFAULT_PHOTO_NAME_THUMB @"noimage.png_thumb"

#define SAVE_PASSWORD @"save_password"
#define USER_NAME @"user_name"
#define USER_PASSWORD @"user_password"
#define EXPIRING_TIME @"expiring_time"
#define USER_TOKEN    @"token"

#define __PRODUCTION__


//#define IPHONE_API_SAMPLES
//#define VOVA
//#define DEVELOPMENT
//#define QA

//#define IPHONE_SERVER
//#define PRESENTATION

//#define BASEURL "http://maps.qa01.cm.kyiv.Cloudmade.com/iphone_proxy"  

//#define GEOCODING_URL @"http://ec2-75-101-165-159.compute-1.amazonaws.com:5000/geocoding/find"
//#define GEOCODING_URL @"http://10.1.3.235:5000/geocoding/find"


#ifdef __PRODUCTION__
	#define BASEURL "http://maps.cloudmade.com/iphone_proxy"
    //#define BASEURL "http://maps.iphone01qa.cm.kyiv.cogniance.com/iphone_proxy"
    #define AUTHORIZATION_BASE_URL @"http://authorization.cloudmade.com/authorize"
	#define IMAGE_URL "http://cloudmade.com/images/iphone/markers/"
	#define PHOTO_URL "http://cloudmade.com/images/iphone/photos/"
	#define LOCATION_BASE_URL @"http://cloudmade.com/places/"
#endif



#ifdef DEVELOPMENT
  #define BASEURL "http://dgolub/iphone-test.html"
  #define AUTHORIZATION_BASE_URL @"http://authorization.dgolub.com:3000/authorize"
  #define IMAGE_URL "http://dgolub:3000/images/iphone/markers/"
  #define PHOTO_URL "http://dgolub:3000/images/iphone/photos/"
  #define LOCATION_BASE_URL @"http://dgolub:3000/places/"
#endif


#ifdef QA 
	#define BASEURL "http://iphone01qa.cm.kyiv.cogniance.com/iphone_proxy"
	#define AUTHORIZATION_BASE_URL @"http://iphone01qa.cm.kyiv.cogniance.com:90/account/authorization"
	#define IMAGE_URL "http://iphone01qa.cm.kyiv.cogniance.com/images/iphone/markers/"
	#define PHOTO_URL "http://qa01.cm.kyiv.Cloudmade.com/images/iphone/photos/"
	#define LOCATION_BASE_URL @"http://iphone01qa.cm.kyiv.cogniance.com/places/"
#endif



//http://maps.iphone01qa.cm.kyiv.Cloudmade.com/iphone_proxy

#ifdef IPHONE_SERVER 
	#define BASEURL "http://maps.iphone01qa.cm.kyiv.cogniance.com/iphone_proxy"
	//#define AUTHORIZATION_BASE_URL @"http://iphone01qa.cm.kyiv.cogniance.com:90/account/authorization"
	#define AUTHORIZATION_BASE_URL @"http://authorization.iphone01qa.cm.kyiv.cogniance.com/authorize"
	#define IMAGE_URL "http://iphone01qa.cm.kyiv.cogniance.com/images/iphone/markers/"
	#define PHOTO_URL "http://iphone01qa.cm.kyiv.cogniance.com/images/iphone/photos/"
	#define LOCATION_BASE_URL @"http://iphone01qa.cm.kyiv.cogniance.com/places/"
#endif


#ifdef PRESENTATION
	#define BASEURL "http://maps.iphone01qa.cloudmade.com/iphone_proxy"
	#define AUTHORIZATION_BASE_URL @"http://iphone01qa.cloudmade.com:90/account/authorization"
	#define IMAGE_URL "http://iphone01qa.cloudmade.com/images/iphone/markers/"
	#define PHOTO_URL "http://iphone01qa.cloudmade.com/images/iphone/photos/"
	#define LOCATION_BASE_URL @"http://iphone01qa.cloudmade.com/places/"
#endif
//http://maps.iphone01qa.cloudmade.com/iphone_proxy

//#define BASEURL "http://dgolub/debug/vector-debug.html"
#define TILESERVER  "tile.cloudmade.com"
#define SUBDOMAINS   "abc"
#define DEFAULT_TAG @"untagged"
#define DEFAULT_DESC @"no description"


//#define LOCATION_BASE_URL @"qa01.cm.kyiv.Cloudmade.com"
//#define IMAGE_URL "http://qa01.cm.kyiv.Cloudmade.com/images/iphone/markers/"

#define NUMBER_OF_ICONS 5
//! Struct which describes token's properties
typedef struct _USER_CREDENTIAL_
{
	NSString* userToken;     /**< user token */
	NSDate*   expiringDate;  /**< token's expiring time */   
} UserCredential;
//! Protocol which has to be adobted to get messages about marker changes
@protocol PlaceMarkerDelegate
/**
  * Is called when marker was tapped
  * @param caller instance of PlaceMarker 
 */
@optional
-(void) markerWasClicked:(id) caller;
/**
 * Is called when marker was moved
 * @param caller instance of PlaceMarker 
 */
-(void) markerWasMoved:(id) caller;
-(void) markerWasDbClicked:(id) caller;
@end

