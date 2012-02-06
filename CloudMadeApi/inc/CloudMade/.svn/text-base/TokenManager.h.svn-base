//
//  TokenManager.h
//  CloudMadeApi
//
//  Created by Dmytro Golub on 11/5/09.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>


/*! \mainpage CloudMade iPhone SDK
 * The CloudMade iPhone SDK makes it easy for developers to build rich, interactive mapping applications on the iPhone. With this SDK you can:
 * \li Build applications that give users a rich mapping experience on the iPhone
 * \li Benefit from our scalable tile servers which deliver mobile optimized maps to your users
 * \li Easily integrate with the iPhone's location SDK to show your user's position in real time
 *
 * Using this SDK you can integrate maps from our tile servers into your applications. Just like our other SDK, we don't want to restrict the uses of this SDK - you are free to create applications that use our maps in any way like, as long as they comply with the terms of the iPhone SDK agreement.
 */


//! Class provides interface for mobile users' authentication  \note { Token will be requested only once after that it will be saved on the disk and used next time }
@interface TokenManager : NSObject
{
	NSString* _accessToken;
	NSString* _apikey;
}

//! Token which is required for mobile devices. 
@property (nonatomic,readonly) NSString* accessToken;
//!! CloudMade apikey \warning { apikey must have 'Token Based Authentication' otherwise 403 HTTP code will be returned }
@property (nonatomic,readonly) NSString* accessKey;
/**
 *  Initializes class 
 *  @param apikey CloudMade apikey \sa http://www.cloudmade.com/faq#api_keys
 */
-(id) initWithApikey:(NSString*) apikey;
/**
 *   Requests token from authentication server. If server doesn't return HTTP 200 response <b>"RMCloudMadeAccessTokenRequestFailed"</b> notification will be sent   
 */
-(void) requestToken;
/**
 * Extend URL by token  
 * @param  URL which has to be extended by token
 */
-(NSString*) appendRequestWithToken:(NSString*) url;
+ (NSString*)pathForSavedAccessToken:(NSString*) apikey;

@end

