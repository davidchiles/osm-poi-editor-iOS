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
#import "OPETextEdit.h"
#import "OPETypeViewController.h"
#import "MBProgressHUD.h"
#import "OPETagValueList.h"
#import "RMAnnotation.h"
#import "OPEOsmElement.h"
#import "OPETagEditViewController.h"
#import "OPEBaseViewController.h"

@protocol OPENodeViewDelegate
@required
-(void)updateAnnotationForOsmElements:(NSArray *)elementsArray;
@end


@interface OPENodeViewController : OPEBaseViewController <UITableViewDelegate, UITableViewDataSource, OPETypeViewControllerDelegate>
{
    NSDictionary * osmKeyValue;
    float optionalTagWidth;
    NSManagedObjectContext * editContext;
    NSDictionary * originalTags;
    int originalTypeID;
    BOOL showDeleteButton;
    BOOL showMoveButton;
    CLLocationCoordinate2D originalLocation;
}

@property (nonatomic, strong) UITableView * nodeInfoTableView;
@property (nonatomic, strong) UIButton * deleteButton;
@property (nonatomic, strong) UIButton * moveButton;
@property (nonatomic, strong) UIBarButtonItem * saveButton;
@property (nonatomic, strong) id <OPENodeViewDelegate> delegate;
@property (nonatomic, strong) NSMutableArray * tableSections;
@property (nonatomic, strong) OPEOsmElement * managedOsmElement;
@property (nonatomic) BOOL newElement;
@property (nonatomic, strong) NSArray * optionalSectionsArray;

@property (nonatomic,copy) newTagBlock newTagBlock;

- (id)initWithOsmElement:(OPEOsmElement *)element delegate:(id<OPENodeViewDelegate>)delegate;

- (void) saveButtonPressed;
- (void) checkSaveButton;



@end
