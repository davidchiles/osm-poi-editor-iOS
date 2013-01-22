//
//  OPEManagedOsmRelation.h
//  OSM POI Editor
//
//  Created by David on 1/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"

@class OpeManagedOsmRelationMember;

@interface OPEManagedOsmRelation : OPEManagedOsmElement

@property (nonatomic, retain) NSOrderedSet *members;
@end

@interface OPEManagedOsmRelation (CoreDataGeneratedAccessors)

- (void)insertObject:(OpeManagedOsmRelationMember *)value inMembersAtIndex:(NSUInteger)idx;
- (void)removeObjectFromMembersAtIndex:(NSUInteger)idx;
- (void)insertMembers:(NSArray *)value atIndexes:(NSIndexSet *)indexes;
- (void)removeMembersAtIndexes:(NSIndexSet *)indexes;
- (void)replaceObjectInMembersAtIndex:(NSUInteger)idx withObject:(OpeManagedOsmRelationMember *)value;
- (void)replaceMembersAtIndexes:(NSIndexSet *)indexes withMembers:(NSArray *)values;
- (void)addMembersObject:(OpeManagedOsmRelationMember *)value;
- (void)removeMembersObject:(OpeManagedOsmRelationMember *)value;
- (void)addMembers:(NSOrderedSet *)values;
- (void)removeMembers:(NSOrderedSet *)values;
@end
