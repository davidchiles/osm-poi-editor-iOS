//
//  UserRegistration.h
//  CloudMadeApi
//
//  Created by Dmytro Golub on 11/5/09.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HelperConstant.h"

//! Protocol which has to be adopted to get authorization messages
@protocol AuthorizationResponse
/**
 *  Server response 
 *  @param caller UserRegistration class instance  	
*/
-(void) authorizationServerResponse:(id) caller; 
@optional 
/**
 * Server error response
 * @param error error message
*/
-(void) authorizationRequestError:(NSError*) error;
@end

//! Class for user registration
@interface UserRegistration : NSObject 
{
	NSMutableData* receivedData;
	NSString* currentParsedElement;
	id<AuthorizationResponse> delegate;
	BOOL errorStatus;
//#ifdef IPHONE_API_SAMPLES    
	NSString* userToken;
	NSDate* expiringTime;	
//#endif //IPHONE_API_SAMPLES        
}
//! server response status 
@property (nonatomic,readwrite)	BOOL errorStatus;
//! Delegate which is called after server response
@property (nonatomic,retain) id<AuthorizationResponse> delegate;
//#ifdef IPHONE_API_SAMPLES    
@property (nonatomic,retain) NSString* userToken;
@property (nonatomic,retain) NSDate* expiringTime;
//#endif //IPHONE_API_SAMPLES
/**
 * Authorizes user 
 * @param userName user's name
 * @param pass user's password
 * @param apikey APIKEY
*/        
-(void) authorizeUser:(NSString*)userName withPassword:(NSString*)pass withAPIKEY:(NSString*)apikey;
@end
