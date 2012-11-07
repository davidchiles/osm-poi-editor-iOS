//
//  OSMData.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
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

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OPETagInterpreter.h"
#import "GTMOAuthViewControllerTouch.h"

@interface OPEOSMData : NSObject 
{
    GTMOAuthAuthentication *auth;
    OPETagInterpreter * tagInterpreter;
    
}

@property (nonatomic, strong) NSMutableDictionary * allNodes;
@property (nonatomic, strong) NSMutableDictionary * ignoreNodes;
@property (nonatomic, strong) GTMOAuthAuthentication * auth;

- (void) getDataWithSW:(CLLocationCoordinate2D)southWest NE: (CLLocationCoordinate2D) northEast;
- (NSInteger) openChangesetWithMessage: (NSString *) message;
- (int) createXmlNode: (OPEPoint *) node withChangeset: (NSInteger) changesetNumber;
- (int) updateXmlNode: (OPEPoint *) node withChangeset: (NSInteger) changesetNumber;
- (int) deleteXmlNode: (OPEPoint *) node withChangeset: (NSInteger) changesetNumber;
- (void) closeChangeset: (NSInteger) changesetNumber;
- (BOOL) canAuth;

- (int) createNode: (OPEPoint *) node;
- (int) updateNode: (OPEPoint *) node;
- (int) deleteNode: (OPEPoint *) node;
- (void) uploadComplete;
+ (void) HTMLFix:(OPEPoint *)node;
+(void) backToHTML:(OPEPoint *)node;



@end
