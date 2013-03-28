//
//  OPENameEditView.h
//  OSM POI Editor
//
//  Created by David on 3/27/13.
//
//

#import <UIKit/UIKit.h>

@protocol OPENameEditViewDelegate <NSObject>

-(void)saveValue:(NSString *)value;

@end

@interface OPENameEditView : UIView <UITextFieldDelegate>


@property (nonatomic, strong) UITextField * textField;
@property (nonatomic, strong) UIButton * saveButton;
@property (nonatomic, strong) UILabel * typeLabel;
@property (nonatomic, weak) id<OPENameEditViewDelegate> delegate;


-(id)initWithFrame:(CGRect)frame andType:(NSString *)typeString;

@end
