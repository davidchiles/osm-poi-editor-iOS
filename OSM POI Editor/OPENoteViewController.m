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
#import <QuartzCore/QuartzCore.h>
#import "DAKeyboardControl.h"

#define kChatBarHeight1                      40
#define kTableViewTag 101

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
    
    CGRect tableViewRect = self.view.bounds;
    tableViewRect.size.height = tableViewRect.size.height - kChatBarHeight1;
    UITableView * tableView = [[UITableView alloc] initWithFrame:self.view.bounds style:UITableViewStylePlain];
    tableView.tag = kTableViewTag;
    UIEdgeInsets tableViewInsets = tableView.contentInset;
    tableViewInsets.bottom = tableViewInsets.bottom + kChatBarHeight1;
    tableView.contentInset = tableViewInsets;
    tableView.scrollIndicatorInsets = tableViewInsets;
    tableView.separatorColor = [UIColor clearColor];
    tableView.delegate = self;
    tableView.dataSource = self;
    tableView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    
    UIView * commentInputBar = [[UIView alloc] initWithFrame:CGRectMake(0, self.view.frame.size.height-kChatBarHeight1, self.view.frame.size.width, kChatBarHeight1)];
    commentInputBar.backgroundColor = [UIColor lightGrayColor];
    commentInputBar.layer.borderWidth = 1.0;
    commentInputBar.layer.borderColor = [UIColor darkGrayColor].CGColor;
    commentInputBar.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    
    UIButton * commentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    commentButton.frame = CGRectMake(commentInputBar.frame.size.width - 70, 5, 70, kChatBarHeight1-10);
    [commentButton setTitle:@"Comment" forState:UIControlStateNormal];
    [commentButton addTarget:self action:@selector(commentButtonPressed:) forControlEvents:UIControlEventTouchUpInside];
    commentButton.autoresizingMask = UIViewAutoresizingFlexibleHeight | UIViewAutoresizingFlexibleWidth;
    
    [commentInputBar addSubview:commentButton];
    
    UITextView * textView = [[UITextView alloc] initWithFrame:CGRectMake(5, 5, commentInputBar.frame.size.width-10-commentButton.frame.size.width, kChatBarHeight1 -10)];
    textView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    textView.delegate = self;
    textView.layer.borderColor = [UIColor darkGrayColor].CGColor;
    [commentInputBar addSubview:textView];
    
    
    [self.view addSubview:tableView];
    [self.view addSubview:commentInputBar];
    
    self.view.keyboardTriggerOffset = commentInputBar.frame.size.height;
    
    __weak OPENoteViewController * viewController = self;
    
    [self.view addKeyboardPanningWithActionHandler:^(CGRect keyboardFrameInView) {
        CGRect messageInputBarFrame = commentInputBar.frame;
        messageInputBarFrame.origin.y = keyboardFrameInView.origin.y - messageInputBarFrame.size.height;
        commentInputBar.frame = messageInputBarFrame;
        
        UIEdgeInsets insets = tableView.contentInset;
        
        
        insets.bottom = viewController.view.frame.size.height - commentInputBar.frame.origin.y;
        tableView.contentInset = insets;
        tableView.scrollIndicatorInsets = insets;
    }];
    
    
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

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    [self scrollToBottomAnimated:YES];
}

- (void)scrollToBottomAnimated:(BOOL)animated {
    UITableView * tableView = (UITableView *)[self.view viewWithTag:kTableViewTag];
    NSInteger numberOfRows = [tableView numberOfRowsInSection:0];
    if (numberOfRows) {
        [tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:numberOfRows-1 inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:animated];
    }
}

-(void)commentButtonPressed:(id)sender
{
    
}

@end
