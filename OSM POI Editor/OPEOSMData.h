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

@class OPEManagedOsmNode;
@class OPEManagedOsmElement;

@interface OPEOSMData : NSObject 
{
    GTMOAuthAuthentication *auth;
    OPETagInterpreter * tagInterpreter;
    
}

@property (nonatomic, strong) GTMOAuthAuthentication * auth;

- (void) getDataWithSW:(CLLocationCoordinate2D)southWest NE: (CLLocationCoordinate2D) northEast;
- (int64_t) openChangesetWithMessage: (NSString *) message;
- (int64_t) createXmlNode: (OPEManagedOsmNode *) node withChangeset: (int64_t) changesetNumber;
- (int64_t) updateXmlNode: (OPEManagedOsmElement *) node withChangeset: (int64_t) changesetNumber;
- (int64_t) deleteXmlNode: (OPEManagedOsmNode *) node withChangeset: (int64_t) changesetNumber;
- (void) closeChangeset: (int64_t) changesetNumber;
- (BOOL) canAuth;

- (int64_t) createNode: (OPEManagedOsmNode *) node;
- (int64_t) updateNode: (OPEManagedOsmElement *) element;
- (int64_t) deleteNode: (OPEManagedOsmNode *) node;
- (void) uploadComplete;



@end
