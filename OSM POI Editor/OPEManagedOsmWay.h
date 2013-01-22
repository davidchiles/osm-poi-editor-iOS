//
//  OPEManagedOsmWay.h
//  OSM POI Editor
//
//  Created by David on 1/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"
#import "CoreLocation/CoreLocation.h"

@class OPEManagedOsmNode;

@interface OPEManagedOsmWay : OPEManagedOsmElement

@property (nonatomic, retain) NSNumber * isArea;
@property (nonatomic, retain) NSOrderedSet *nodes;
@end

@interface OPEManagedOsmWay (CoreDataGeneratedAccessors)

- (void)insertObject:(OPEManagedOsmNode *)value inNodesAtIndex:(NSUInteger)idx;
- (void)removeObjectFromNodesAtIndex:(NSUInteger)idx;
- (void)insertNodes:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeNodesAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInNodesAtIndex:(NSUInteger)idx withObject:(OPEManagedOsmNode *)value;
- (void)replaceNodesAtIndexes:(NSIndexSet *)indexes withNodes:(NSArray *)values;
- (void)addNodesObject:(OPEManagedOsmNode *)value;
- (void)removeNodesObject:(OPEManagedOsmNode *)value;
- (void)addNodes:(NSOrderedSet *)values;
- (void)removeNodes:(NSOrderedSet *)values;


@end
