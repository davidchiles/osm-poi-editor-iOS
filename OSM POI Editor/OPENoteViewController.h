//
//  OPENoteViewController.h
//  OSM POI Editor
//
//  Created by David on 7/16/13.
//
//

#import <UIKit/UIKit.h>
#import "Note.h"

@interface OPENoteViewController : UIViewController <UITableViewDataSource,UITableViewDelegate>

@property (nonatomic,strong) Note * note;

-(id)initWithNote:(Note *)note;

@end
