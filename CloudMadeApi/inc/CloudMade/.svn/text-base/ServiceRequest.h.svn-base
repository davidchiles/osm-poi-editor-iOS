//
//  ServiceRequest.h
//  NavigationView
//
//  Created by Dmytro Golub on 2/9/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import <Foundation/Foundation.h>


//! Protocol has to be adopted to get geocoding results  
@protocol ServiceRequestResult
/**
 *  returns geocoding response
 *  @param jsonResponse geocoding response in json format
 */
-(void) serviceServerResponse:(NSString*) jsonResponse;
/**
 *  returns geocoding error response
 *  @param error error description
 */
@optional
-(void) serviceServerError:(NSString*) error; 
@end

//! Base class for the CloudMade services such as geosearch
@interface ServiceRequest : NSObject
{
	NSMutableData* receivedData;	
	id<ServiceRequestResult> delegate; 	
}

//! delegate \sa ServiceRequestResult
@property(nonatomic,retain)	id<ServiceRequestResult> delegate; 


@end
