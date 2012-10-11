//
//  OPENodeViewController.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/8/12.
//  Copyright (c) 2011 David Chiles. All rights reserved.
//
//  This file is part of POI+.
//
//  POI+ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  POI+ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with POI+.  If not, see <http://www.gnu.org/licenses/>.

#import <UIKit/UIKit.h>
#import "OPENode.h"
#import "OPETagInterpreter.h"
#import "OPETextEdit.h"
#import "OPETypeViewController.h"
#import "MBProgressHUD.h"
#import "OPETagValueList.h"
#import "OPEPoint.h"
#import "OPEType.h"

@protocol OPENodeViewDelegate
@optional
-(void)createdNode:(id <OPEPoint>) newPoint;
-(void)updatedNode:(id <OPEPoint>) newPoint;
-(void)deletedNode:(id <OPEPoint>) newPoint;
@end


@interface OPENodeViewController : UIViewController <UITableViewDelegate, UITableViewDataSource, UIAlertViewDelegate, editTagDelegate, PassCategoryAndType, MBProgressHUDDelegate, UIAlertViewDelegate>
{
    OPETagInterpreter * tagInterpreter;
    NSDictionary * osmKeyValue;
    float optionalTagWidth;
}

@property (nonatomic, strong) id<OPEPoint> point;
@property (nonatomic, strong) id<OPEPoint> theNewPoint;
@property (nonatomic, strong) UITableView * nodeInfoTableView;
@property (nonatomic, strong) OPEType * nodeType;
@property (nonatomic, strong) NSString * type;
@property (nonatomic, strong) UIButton * deleteButton;
@property (nonatomic, strong) UIBarButtonItem * saveButton;
@property (nonatomic, strong) id <OPENodeViewDelegate> delegate;
@property (nonatomic) BOOL nodeIsEdited;
@property (nonatomic, strong) MBProgressHUD * HUD;
@property (nonatomic, strong) NSMutableArray * tableSections;

- (void) saveButtonPressed;
- (void) deleteButtonPressed;
- (void) checkSaveButton;
- (void) uploadComplete:(NSNotification *)notification;



@end
