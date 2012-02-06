//
//  PostDataToServer.h
//  CloudMadeApi
//
//  Created by Dmytro Golub on 1/26/10.
//  Copyright 2010 CloudMade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ILocationsBase.h"

//! Class which is used for posting data to server
@interface PostDataToServer : ILocationsBase
{
	int elementIndex;
	NSString* _token; 
}

@property (nonatomic,readwrite) int elementIndex; 

-(id) initWithToken:(NSString*) token;
/**
 * Post data to server 
 * @param xml data which is going to be sent to the server
 * @param url server URL
 * @param target callback target
 * @param action callback action
 */
-(BOOL) postDataToServer:(NSString*) xml :(NSString*) url :(id) target :(SEL) action :(int) elementIdx;
/**
 * delete location 
 * @param itemID item's ID
 * @param url server URL
 */
-(BOOL) deleteItem:(NSString*) itemID withURL:(NSString*) url;
/**
 * Server response is returned for CRUD operations
 * @return server response \sa ServerResponse
*/
-(ServerResponse) getResponse;
/**
 * Server response is returned for image uploading
 * @return server response \sa ServerPhotoResponse
 */
-(ServerPhotoResponse) getPhotoResponse;
/**
 * Post image to server
 * @param image image
 * @param url server URL
 * @param target callback target
 * @param action callback action
 * @param quality quality of image range is from 0.0 to 1.0
 */
-(void) postImage:(NSString*) url :(UIImage*) image withQuality:(float) quality :(id) target :(SEL) action; 
-(void) deleteImage:(NSString*) imageName;

-(BOOL) deleteItem:(NSString*) itemID;
@end
