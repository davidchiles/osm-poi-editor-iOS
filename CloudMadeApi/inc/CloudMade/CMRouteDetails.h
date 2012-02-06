//
//  untitled.h
//  Routing
//
//  Created by Dmytro Golub on 12/14/09.
//  Copyright 2009 CloudMade. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>


//! Route bounding box
@interface CMRouteDetails : NSObject {
	CLLocationCoordinate2D _ne;
	CLLocationCoordinate2D _sw;
}
//! north latitude east longitude  
@property (readwrite) CLLocationCoordinate2D ne;
//! south latitude west longitude  
@property (readwrite) CLLocationCoordinate2D sw;




@end
