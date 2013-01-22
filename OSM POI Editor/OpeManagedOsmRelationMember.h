//
//  OpeManagedOsmRelationMember.h
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OPEManagedOsmElement;

@interface OpeManagedOsmRelationMember : NSManagedObject

@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) NSSet *member;
@end

@interface OpeManagedOsmRelationMember (CoreDataGeneratedAccessors)

- (void)addMemberObject:(OPEManagedOsmElement *)value;
- (void)removeMemberObject:(OPEManagedOsmElement *)value;
- (void)addMember:(NSSet *)values;
- (void)removeMember:(NSSet *)values;

@end
