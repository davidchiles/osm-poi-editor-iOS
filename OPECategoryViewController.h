//
//  OPECategoryViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/13/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OPETypeViewController.h"

@interface OPECategoryViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UISearchDisplayDelegate, UISearchBarDelegate>

@property (nonatomic,strong) IBOutlet UITableView * mainTableView;
@property (nonatomic,strong) UISearchDisplayController * searchDisplayController;
@property (nonatomic,strong) IBOutlet UISearchBar * searchBar;
//@property (nonatomic,strong) NSDictionary * categoriesAndTypes;
@property (nonatomic,strong) NSArray * categoriesArray;
@property (nonatomic,strong) NSDictionary * typesDictionary;

@property (nonatomic, strong) id <PassCategoryAndType> delegate;

@property (nonatomic, retain) NSMutableArray *searchResults;

@end
