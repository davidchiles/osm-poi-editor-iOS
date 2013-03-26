//
//  OPEOsmValueTextField.h
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import <UIKit/UIKit.h>

@interface OPEOsmValueTextField : UITextField <UITextFieldDelegate>


-(id)initWithFrame:(CGRect)frame withOsmKey:(NSString *)osmKey andValue:(NSString *)value;

@end
