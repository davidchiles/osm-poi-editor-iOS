//
//  OSMData.h
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>
#import "OPETagInterpreter.h"
#import "GTMOAuthViewControllerTouch.h"

@interface OPEOSMData : NSObject 
{
    GTMOAuthAuthentication *auth;
}

@property double bboxleft;
@property double bboxbottom;
@property double bboxright;
@property double bboxtop;
@property (retain) NSMutableDictionary * allNodes;

- (id) initWithLeft:(double) lef bottom: (double) bot right: (double) rig top: (double) to;
- (void) getData;
- (NSInteger) openChangesetWithMessage: (NSString *) message;
- (void) createXmlNode: (OPENode *) node withChangeset: (NSInteger) changesetNumber;
- (void) updateXmlNode: (OPENode *) node withChangeset: (NSInteger) changesetNumber;
- (void) deleteXmlNode: (OPENode *) node withChangeset: (NSInteger) changesetNumber;
- (void) closeChangeset: (NSInteger) changesetNumber;

@end
