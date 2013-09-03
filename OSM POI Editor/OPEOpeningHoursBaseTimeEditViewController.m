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

@synthesize propertiesTableView,propertiesOrderedSet,doneBlock;

-(id)initWithOrderedSet:(NSOrderedSet *)orderedSet
{
    if (self = [self initShowCancel:YES showDone:YES]) {
        if ([orderedSet count]) {
            self.propertiesOrderedSet = [orderedSet mutableCopy];
        }
        else {
            self.propertiesOrderedSet = [NSMutableOrderedSet orderedSet];
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
        doneBlock(self.propertiesOrderedSet);
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
