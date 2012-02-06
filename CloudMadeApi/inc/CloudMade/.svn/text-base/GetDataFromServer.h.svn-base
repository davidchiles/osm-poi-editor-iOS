//
//  GetDataFromServer.h
//  NavigationView
//
//  Created by Dmytro Golub on 2/11/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILocationsBase.h"



@protocol FindLocationsDelegate
-(void) locationsFound:(NSArray*) locations	;
-(void) locationRequestError:(NSError*) error;
@end


//! Class which gets data from server. 
@interface GetDataFromServer : ILocationsBase 
{
	NSString* _token;
	id<FindLocationsDelegate> delegate;
}

@property(nonatomic,retain) id<FindLocationsDelegate> delegate;



-(id) initWithToken:(NSString*) token;

-(void) findLocations:(NSString*) request;

/**
 *  Makes HTTP GET request to server 
 * @param strURL URL of the server
 * @param target callback's function owner
 * @param action callback function
 * @deprecated use findLocations instead \sa findLocations
 */
-(void) getData:(NSString*) strURL target:(id)target action:(SEL) action;
/**
 * Returns locations' array 
 * @remarks MUST be called from callback function \sa getData
*/
-(NSArray*) getLocationsArray;
/**
 * Returns icons which are accessible on server 
 * @return icons array 
 */
-(NSArray*) getIcons;
/**
 * Extracts image name from image URL (e.g  http://www.server.com/foo/image.png will return image.png)
 */
/**
 * Extracts image's file name from URL
 * @return  image file name
*/
+(NSString*) getImageUrl:(int) nIdx;


@end
