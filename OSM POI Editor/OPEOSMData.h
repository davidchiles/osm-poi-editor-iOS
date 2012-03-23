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

@property (strong) NSMutableDictionary * allNodes;

-(void) getDataWithSW:(CLLocationCoordinate2D)southWest NE: (CLLocationCoordinate2D) northEast;
- (NSInteger) openChangesetWithMessage: (NSString *) message;
- (void) createXmlNode: (OPENode *) node withChangeset: (NSInteger) changesetNumber;
- (void) updateXmlNode: (OPENode *) node withChangeset: (NSInteger) changesetNumber;
- (void) deleteXmlNode: (OPENode *) node withChangeset: (NSInteger) changesetNumber;
- (void) closeChangeset: (NSInteger) changesetNumber;

- (void) createNode: (OPENode *) node;
- (void) updateNode: (OPENode *) node;
- (void) deleteNode: (OPENode *) node;



@end
