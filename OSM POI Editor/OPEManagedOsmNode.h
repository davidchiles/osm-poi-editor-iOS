//
//  OPEManagedOsmNode.h
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"


@interface OPEManagedOsmNode : OPEManagedOsmElement

@property (nonatomic, retain) NSNumber * lattitude;
@property (nonatomic, retain) NSNumber * longitude;

@end
