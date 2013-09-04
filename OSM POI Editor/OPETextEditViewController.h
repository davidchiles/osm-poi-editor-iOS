//
//  OPETextEditViewController.h
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPETagEditViewController.h"
#import "OPEOsmValueTextField.h"

@interface OPETextEditViewController : OPETagEditViewController <UITextFieldDelegate>

@property (nonatomic,strong)OPEOsmValueTextField * textField;

@end
