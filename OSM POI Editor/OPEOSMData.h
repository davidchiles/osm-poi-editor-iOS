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
    OPETagInterpreter * tagInterpreter;
    
}

@property (nonatomic, strong) NSMutableDictionary * allNodes;
@property (nonatomic, strong) NSMutableDictionary * ignoreNodes;
@property (nonatomic, strong) GTMOAuthAuthentication * auth;

- (void) getDataWithSW:(CLLocationCoordinate2D)southWest NE: (CLLocationCoordinate2D) northEast;
- (NSInteger) openChangesetWithMessage: (NSString *) message;
- (int) createXmlNode: (id<OPEPoint>) node withChangeset: (NSInteger) changesetNumber;
- (int) updateXmlNode: (id<OPEPoint>) node withChangeset: (NSInteger) changesetNumber;
- (int) deleteXmlNode: (id<OPEPoint>) node withChangeset: (NSInteger) changesetNumber;
- (void) closeChangeset: (NSInteger) changesetNumber;
- (BOOL) canAuth;

- (int) createNode: (id<OPEPoint>) node;
- (int) updateNode: (id<OPEPoint>) node;
- (int) deleteNode: (id<OPEPoint>) node;
- (void) uploadComplete;
+ (void) HTMLFix:(id<OPEPoint>)node;
+(void) backToHTML:(id<OPEPoint>)node;



@end
