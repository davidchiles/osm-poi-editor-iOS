//
//  OPEManagedOsmRelation.h
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"


@interface OPEManagedOsmRelation : OPEManagedOsmElement

@property (nonatomic, retain) NSSet *members;
@end

@interface OPEManagedOsmRelation (CoreDataGeneratedAccessors)

- (void)addMembersObject:(NSManagedObject *)value;
- (void)removeMembersObject:(NSManagedObject *)value;
- (void)addMembers:(NSSet *)values;
- (void)removeMembers:(NSSet *)values;

@end
