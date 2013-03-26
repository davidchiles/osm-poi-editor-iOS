//
//  OPERecent+NearbyViewController.h
//  OSM POI Editor
//
//  Created by David on 3/26/13.
//
//

#import "OPERecentlyUsedViewController.h"

@interface OPERecent_NearbyViewController : OPERecentlyUsedViewController
{
    NSDictionary * nearbyDictionary;
    NSArray * distances;
}

@end
