//
//  OPEOpeningHoursTimeRangesViewController.m
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEOpeningHoursTimeRangesViewController.h"
#import "OPEOpeningHoursParser.h"


@interface OPEOpeningHoursTimeRangesViewController ()

@end

@implementation OPEOpeningHoursTimeRangesViewController

- (id)initWithTimeRanges:(NSOrderedSet *)timeRanges
{
    if (self = [self init]) {
        originalOrderedSet = timeRanges;
        self.timeRangesOrderedSet = [NSMutableOrderedSet orderedSet];
        if ([timeRanges count]) {
            self.timeRangesOrderedSet = [timeRanges mutableCopy];
        }
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.dataSource = self;
    tableView.delegate = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [self.view addSubview:tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.timeRangesOrderedSet count]+1;
}

@end
