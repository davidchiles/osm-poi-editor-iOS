//
//  OPEManagedOsmWay.h
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"

@class OPEManagedOsmNode;

@interface OPEManagedOsmWay : OPEManagedOsmElement

@property (nonatomic, retain) NSNumber * isArea;
@property (nonatomic, retain) NSSet *nodes;
@end

@interface OPEManagedOsmWay (CoreDataGeneratedAccessors)

- (void)addNodesObject:(OPEManagedOsmNode *)value;
- (void)removeNodesObject:(OPEManagedOsmNode *)value;
- (void)addNodes:(NSSet *)values;
- (void)removeNodes:(NSSet *)values;

@end
