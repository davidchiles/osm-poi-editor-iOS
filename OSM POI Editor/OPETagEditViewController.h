//
//  OPETagEditViewController.h
//  OSM POI Editor
//
//  Created by David on 3/25/13.
//
//

#import <UIKit/UIKit.h>
#import "OPEMRUtility.h"
#import "OPEManagedReferenceOptional.h"
#import "OPEConstants.h"

@protocol OPETagEditViewControllerDelegate <NSObject>
@required
- (void) newOsmKey:(NSString *)key value:(NSString *)value;
@end

@interface OPETagEditViewController : UIViewController

@property (nonatomic,weak) id<OPETagEditViewControllerDelegate> delegate;

@property (nonatomic, strong) NSString * osmKey;
@property (nonatomic, strong) NSString * currentOsmValue;
@property (nonatomic, strong) NSManagedObjectID * managedObjectID;
@property (nonatomic, strong) NSManagedObjectID * manageedOptionalObjectID;

-(id)initWithOsmKey:(NSString *)osmKey delegate:(id<OPETagEditViewControllerDelegate>)delegate;
-(id)initWithOsmKey:(NSString *)osmKey currentValue:(NSString *)currentValue delegate:(id<OPETagEditViewControllerDelegate>)delegate;

+(OPETagEditViewController *)viewControllerWithOsmKey:(NSString *)osmKey andType:(NSString *)type delegate:(id<OPETagEditViewControllerDelegate>)delegate;
+(NSString *)sectionFootnoteForOsmKey:(NSString *)osmKey;

@end
