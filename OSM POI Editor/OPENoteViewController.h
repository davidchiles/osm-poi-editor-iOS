//
//  OPENoteViewController.h
//  OSM POI Editor
//
//  Created by David on 7/16/13.
//
//

#import <UIKit/UIKit.h>
#import "Note.h"
@class OPEOSMAPIManager;
@class OPEOSMData;

@interface OPENoteViewController : UIViewController <UITableViewDataSource,UITableViewDelegate,UITextViewDelegate,UIActionSheetDelegate>

@property (nonatomic,strong) Note * note;
@property (nonatomic,strong) OPEOSMAPIManager * osmApiManager;
@property (nonatomic,strong) OPEOSMData * osmData;

-(id)initWithNote:(Note *)note;


@end
