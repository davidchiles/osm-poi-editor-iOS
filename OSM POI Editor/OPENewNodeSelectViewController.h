//
//  OPENewNodeSelectViewController.h
//  OSM POI Editor
//
//  Created by David on 5/30/13.
//
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "OPECategoryViewController.h"
#import "OPEManagedOsmElement.h"
#import "OPENodeViewController.h"

@interface OPENewNodeSelectViewController : OPECategoryViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSArray * recentlyUsedPoisArray;
    NSArray * categoriesArray;
    OPEManagedOsmElement * newElement;
}

@property (nonatomic) CLLocationCoordinate2D location;
@property (nonatomic,strong) id <OPENodeViewDelegate> nodeViewDelegate;

-(id)initWithNewElement:(OPEManagedOsmElement *)element;

@end
