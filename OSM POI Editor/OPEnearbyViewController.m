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
#import "OPEUtility.h"

@interface OPEnearbyViewController ()

@end

@implementation OPEnearbyViewController

@synthesize osmKey;
@synthesize delegate;

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
	
    
}
-(void)viewWillAppear:(BOOL)animated
{
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
    cell.detailTextLabel.text = [OPEUtility formatDistanceMeters:[[[distances objectAtIndex:indexPath.row] objectForKey:@"distance"]doubleValue]];
    
    return cell;
}
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    NSString * value = [[distances objectAtIndex:indexPath.row] objectForKey:@"name"];
    
    [self saveNewOsmKey:osmKey andValue:value];
    [self backMultiple:2];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)saveNewOsmKey:(NSString *)osmKeay andValue:(NSString *)value
{
    OPEManagedOsmTag * tag = [OPEManagedOsmTag fetchOrCreateWithKey:osmKey value:value];
    NSManagedObjectContext * context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
    [self.delegate newTag:tag.objectID];
}

-(void)backMultiple:(int)data {
    int back = data; //Default to go back 2
    int count = [self.navigationController.viewControllers count];
    
    
    //If we want to go back more than those that actually exist, just go to the root
    if(back+1 > count) {
        [self.navigationController popToRootViewControllerAnimated:YES];
    }
    //Otherwise go back X ViewControllers
    else {
        [self.navigationController popToViewController:[self.navigationController.viewControllers objectAtIndex:count-(back+1)] animated:YES];
    }
}

@end
