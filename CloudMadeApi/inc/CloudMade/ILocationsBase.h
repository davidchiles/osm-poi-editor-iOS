//
//  ILocationsBase.h
//  NavigationView
//
//  Created by Dmytro Golub on 2/11/09.
//  Copyright 2009 Cloudmade. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Location.h"
#import "HelperConstant.h"



typedef enum _xmltags_
	{
		L_NONE,	
		L_ID,	
		L_NAME,
		L_DESC,
		L_TAGS,
		L_LAT,
		L_LNG,
		L_IMG,
		L_RESPONSE,
		L_RID,
		L_FILENAME
	} XMLTAGS;

//! Server response which is returned on POST/GET response
typedef struct _server_response_
{
		BOOL status; /**< server response status TRUE if everything is fine */
		int nID;     /**< inserted/updated item ID */
} ServerResponse;

//! Server response on upload photo POST request \sa postImage
typedef struct _server_photo_response_
{
	BOOL status; /**< result */
	NSString* filename; /**< uploaded file URL */
} ServerPhotoResponse;
		


@protocol ServerResponse
	-(void) handleServerResponse:(NSData*) data;  
@end

//! Base class for POST/GET request \sa GetDataFromServer
@interface ILocationsBase : NSObject <ServerResponse>
{
	NSMutableData* receivedData;	
	id ptrCalle;
	SEL ptrFunc;
	
	BOOL elementIsProcessing;   
	NSMutableArray* locationsArray; 
	XMLTAGS currentProcessingTag;
	
	NSString* strName;
	NSString* strDesc;
	NSString* strTag;
	NSString* strID;
        NSString* strURL;	
	float fLat;
	float fLng;
	ServerResponse serverResponse;
	ServerPhotoResponse serverPhotoResponse; 
	BOOL errorStatus;	
}

@property (nonatomic,readwrite)	BOOL errorStatus;
/**
 * Creates array of object from XML
 * @param data XML data received from server
 * @return array of location
*/
-(NSArray*) createObjectsFromXML:(NSData*) data;
/**
 * Transforms given locations' array to XML string
 * @param objects array of locations
 * @return string in XML format \sa postData
 */
-(NSString*) transformObjectsToXML:(NSArray*) objects;
/**
 * Adds user's token to the URL
 * @param url URL
 * @return modified URL
 */
+(NSString*) addTokenToUrl:(NSString*) url;

+(NSString*) addToken:(NSString*) token toUrl:(NSString*) url; 

/**
 * Extract image name from the URL
 * @param strUrl uploaded file URL
 * @return mane of the file
 */
+(NSString*) getImageName:(NSString*) strUrl withDelimiter:(NSString*) delimiter;
@end
