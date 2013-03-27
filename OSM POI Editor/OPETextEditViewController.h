//
//  OPETextEditViewController.h
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import "OPETagEditViewController.h"
#import "OPEOsmValueTextField.h"

@interface OPETextEditViewController : OPETagEditViewController

@property (nonatomic,strong)OPEOsmValueTextField * textField;

-(NSString *)newOsmValue;
-(void)saveNewValue:(NSString *)value;
-(void)doneButtonPressed:(id)sender;

@end
