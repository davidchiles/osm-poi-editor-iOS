//
//  OPENewNodeSelectViewController.h
//  OSM POI Editor
//
//  Created by David on 5/30/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>

@interface OPENewNodeSelectViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSArray * recentlyUsedPoisArray;
    NSArray * categoriesArray;
}

@property (nonatomic) CLLocationCoordinate2D location;

-(id)initWithLocation:(CLLocationCoordinate2D)location;

@end
