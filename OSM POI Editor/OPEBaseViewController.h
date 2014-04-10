//
//  OPEBaseViewController.h
//  OSM POI Editor
//
//  Created by David on 3/27/13.
//
//

#import <UIKit/UIKit.h>
#import "OPEOSMData.h"
#import "MBProgressHUD.h"

@interface OPEBaseViewController : UIViewController <MBProgressHUDDelegate, UIAlertViewDelegate>

@property (nonatomic,strong)OPEOSMData * osmData;
@property (nonatomic,strong)OPEOSMAPIManager * apiManager;
@property (nonatomic,strong)MBProgressHUD * HUD;
@property (nonatomic) NSInteger numberOfOngoingParses;

-(void)startSave;
-(void)showAuthError;
-(void)signIntoOSM;

-(void)findishedAuthWithError:(NSError *)error;

-(void)didOpenChangeset:(int64_t)changesetNumber withMessage:(NSString *)message;
-(void)didCloseChangeset:(int64_t)changesetNumber;
-(void)uploadFailed:(NSError *)error;

@end
