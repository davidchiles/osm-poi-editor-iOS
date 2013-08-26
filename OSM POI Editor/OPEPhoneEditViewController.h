//
//  OPEPhoneEditViewController.h
//  OSM POI Editor
//
//  Created by David on 3/26/13.
//
//

#import "OPERecentlyUsedViewController.h"
#import "OPEOSMTagConverter.h"
#import "OPEPhoneCell.h"

@interface OPEPhoneEditViewController : OPERecentlyUsedViewController <OPEPhoneCellDelegate>
{
    CGFloat maxLabelLength;
}

@property (nonatomic) phoneNumber phoneNumber;

@end
