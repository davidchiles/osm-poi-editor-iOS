//
//  OPEPhoneEditViewController.h
//  OSM POI Editor
//
//  Created by David on 3/26/13.
//
//

#import "OPETagEditViewController.h"
#import "OPEOSMTagConverter.h"
#import "OPEPhoneCell.h"

@interface OPEPhoneEditViewController : OPETagEditViewController <OPEPhoneCellDelegate,UITableViewDataSource,UITableViewDelegate>
{
    CGFloat maxLabelLength;
    UITableView * phoneTableView;
}

@property (nonatomic) phoneNumber phoneNumber;

@end
