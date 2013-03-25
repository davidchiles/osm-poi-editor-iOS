//
//  OPEnearbyViewController.h
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import <UIKit/UIKit.h>
#import "OPETextEdit.h"

@interface OPEnearbyViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>
{
    NSDictionary * nearbyDictionary;
    NSArray * distances;
}

- (id)initWithManagedObjectID:(NSManagedObjectID *)objectID;

@property (nonatomic,strong) NSString * osmKey;
@property (nonatomic, weak) id<editTagDelegate> delegate;

@end
