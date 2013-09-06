//
//  OPEOpeningHoursBaseTimeEditViewController.m
//  OSM POI Editor
//
//  Created by David on 9/3/13.
//
//

#import "OPEOpeningHoursBaseTimeEditViewController.h"

@interface OPEOpeningHoursBaseTimeEditViewController ()

@end

@implementation OPEOpeningHoursBaseTimeEditViewController

@synthesize propertiesTableView,propertiesArray,doneBlock;

-(id)initWithOrderedSet:(NSOrderedSet *)orderedSet
{
    if (self = [self initShowCancel:YES showDone:YES]) {
        if ([orderedSet count]) {
            self.propertiesArray = [[orderedSet array] mutableCopy];
        }
        else {
            self.propertiesArray = [NSMutableArray array];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	propertiesTableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    propertiesTableView.dataSource = self;
    propertiesTableView.delegate = self;
    propertiesTableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:propertiesTableView];
}

-(void)doneButtonPressed:(id)sender
{
    if (doneBlock) {
        doneBlock([NSOrderedSet orderedSetWithArray:self.propertiesArray]);
    }
    [super doneButtonPressed:sender];
}


-(NSIndexPath *)lastIndexPathForTableView:(UITableView *)tableView
{
    NSInteger lastSectionIndex = [tableView numberOfSections] - 1;
    NSIndexPath *lastIndexPath = [NSIndexPath indexPathForRow:([tableView numberOfRowsInSection:lastSectionIndex] - 1) inSection:lastSectionIndex];
    
    return lastIndexPath;
}
@end
