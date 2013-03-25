//
//  OPEnearbyViewController.m
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPEnearbyViewController.h"
#import "OPEManagedOsmElement.h"
#import "OPEMRUtility.h"

@interface OPEnearbyViewController ()

@end

@implementation OPEnearbyViewController

- (id)initWithManagedObjectID:(NSManagedObjectID *)objectID
{
    self = [super init];
    if (self) {
        OPEManagedOsmElement * element = (OPEManagedOsmElement *)[OPEMRUtility managedObjectWithID:objectID];
        
        nearbyDictionary = [element nearbyHighwayNames];
        
        NSMutableArray * array = [NSMutableArray array];
        for (NSString * key in nearbyDictionary)
        {
            [array addObject:@{@"name": key,@"distance":[nearbyDictionary objectForKey:key]}];
        }
        
        NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"distance"  ascending:YES];
        
        distances = [array sortedArrayUsingDescriptors:@[descriptor]];
        
        
        
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
	
    UITableView * tableview = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableview.dataSource = self;
    tableview.delegate = self;
    
    
    [self.view addSubview:tableview];
    
    
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [distances count];
}
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * cellIdentifier = @"cell";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:cellIdentifier];
    }
    cell.textLabel.text = [[distances objectAtIndex:indexPath.row] objectForKey:@"name"];
    NSString * distanceString = [NSString stringWithFormat:@"%f",[[[distances objectAtIndex:indexPath.row] objectForKey:@"distance"]doubleValue]];
    cell.detailTextLabel.text = distanceString;
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
