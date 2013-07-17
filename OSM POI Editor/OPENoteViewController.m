//
//  OPENoteViewController.m
//  OSM POI Editor
//
//  Created by David on 7/16/13.
//
//

#import "OPENoteViewController.h"
#import "Comment.h"
#import "OPECommentCell.h"

@interface OPENoteViewController ()

@end

@implementation OPENoteViewController

@synthesize note;

-(id)initWithNote:(Note *)newNote;
{
    if(self = [self init])
    {
        self.note = newNote;
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.navigationController setNavigationBarHidden:NO animated:YES];
    [self.navigationController setToolbarHidden:YES animated:YES];
    
    self.title = @"Note";
    
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    [self.view addSubview:tableView];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.note.commentsArray count];
}
-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return [OPECommentCell heightForComment:[self.note.commentsArray objectAtIndex:indexPath.row]];
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    NSString * tableViewCellIdentifier = @"tableViewCellIdentifier";
    OPECommentCell * cell = [tableView dequeueReusableCellWithIdentifier:tableViewCellIdentifier];
    if (!cell) {
        cell = [[OPECommentCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:tableViewCellIdentifier];
    }
    Comment * comment = [self.note.commentsArray objectAtIndex:indexPath.row];
    cell.comment = comment;
    
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    return cell;
}

@end
