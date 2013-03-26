//
//  OPERecentlyUsedViewController.m
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPERecentlyUsedViewController.h"

@interface OPERecentlyUsedViewController ()

@end

@implementation OPERecentlyUsedViewController

@synthesize showRecent;

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    if (showRecent) {
        recentValues = [self recentlyUsedValues];
    }
    else
    {
        recentValues = nil;
    }
	
    
    
    self.textField = [[OPEOsmValueTextField alloc] initWithFrame:CGRectMake(0, 0, 300, 35) withOsmKey:self.osmKey andValue:self.currentOsmValue];
    
    
}
-(void)viewWillAppear:(BOOL)animated
{
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStyleGrouped];
    tableView.delegate = self;
    tableView.dataSource = self;
    
    [self.view addSubview:tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (recentValues) {
        return 2;
    }
    return 1;
}
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section{
    if (section == 1 && recentValues) {
        return @"Recently Used";
    }
    return @"";
}
-(NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section
{
    if (section == 0) {
        return [OPETagEditViewController sectionFootnoteForOsmKey:self.osmKey];
    }
    return @"";
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section == 0) {
        return 1;
    }
    else if(section == 2 && recentValues)
    {
        return [recentValues count];
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * recentCellIdentifier = @"recentCell";
    static NSString * textCellIdentifier = @"textCell";
    UITableViewCell * cell;
    if (indexPath.section == 0) {
        cell = [tableView dequeueReusableCellWithIdentifier:textCellIdentifier];
        if (cell == nil) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:textCellIdentifier];
        }
        self.textField.frame = CGRectMake(10, 9, cell.contentView.frame.size.width-10.0, cell.contentView.frame.size.height-9.0);
        self.textField.adjustsFontSizeToFitWidth = YES;
        self.textField.autoresizingMask = UIViewAutoresizingFlexibleWidth;
        [cell.contentView addSubview:self.textField];
    }
    else if (indexPath.section == 1 && recentValues)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:recentCellIdentifier];
        if (!cell) {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:recentCellIdentifier];
        }
        cell.textLabel.text = [recentValues objectAtIndex:indexPath.row];
        cell.detailTextLabel.text = nil;
        
    }
    return cell;
}


-(NSArray *)recentlyUsedValues
{
    NSArray * recentArray = nil;
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    //Recently used Tags
    if ([prefs objectForKey:self.osmKey]) {
        recentArray = [NSArray arrayWithArray:[prefs objectForKey:self.osmKey]];
        NSLog(@"Recently Used: %@",recentArray);
    }
    return recentArray;
}

-(void) saveToRecentlyUsed:(NSString *) newValue
{
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    if (![newValue isEqualToString:@""])
    {
        if ([prefs objectForKey:self.osmKey]) {
            NSMutableArray * recent = [NSMutableArray arrayWithArray:[prefs objectForKey:self.osmKey]];
            [recent removeObject:newValue];
            NSMutableArray * newRecentArray = [NSMutableArray arrayWithObjects:newValue, nil];
            int limit = 3;
            for (int i =0; i<[recent count] && i<limit-1; i++)
            {
                [newRecentArray addObject:[recent objectAtIndex:i]];
            }
            [prefs setObject:newRecentArray forKey:self.osmKey];
        }
        else {
            NSArray * newRecentArray = [NSArray arrayWithObjects:newValue, nil];
            [prefs setObject:newRecentArray forKey:self.osmKey];
        }
        [prefs synchronize];
    }
    
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
