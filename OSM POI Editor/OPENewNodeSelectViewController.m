//
//  OPENewNodeSelectViewController.m
//  OSM POI Editor
//
//  Created by David on 5/30/13.
//
//

#import "OPENewNodeSelectViewController.h"

@interface OPENewNodeSelectViewController ()

@end

@implementation OPENewNodeSelectViewController
@synthesize location;

-(id)initWithLocation:(CLLocationCoordinate2D)newLocation
{
    if (self = [super init]) {
        self.location = newLocation;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    tableView.delegate = self;
    tableView.dataSource = self;
    
    
    [self.view addSubview:tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    if ([recentlyUsedPoisArray count]) {
        return 2;
    }
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0 && [recentlyUsedPoisArray count]){
        return [recentlyUsedPoisArray count];
    }
    return [categoriesArray count];
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    if ([recentlyUsedPoisArray count]){
        if (section == 0) {
            return @"Recently Used";
        }
        else
        {
            return @"Categories";
        }
    }
    else
    {
        return @"";
    }
}



@end
