// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmRelation.h instead.

#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"

extern const struct OPEManagedOsmRelationAttributes {
} OPEManagedOsmRelationAttributes;

extern const struct OPEManagedOsmRelationRelationships {
	__unsafe_unretained NSString *members;
} OPEManagedOsmRelationRelationships;

extern const struct OPEManagedOsmRelationFetchedProperties {
} OPEManagedOsmRelationFetchedProperties;

@class OpeManagedOsmRelationMember;


@interface OPEManagedOsmRelationID : NSManagedObjectID {}
@end

@interface _OPEManagedOsmRelation : OPEManagedOsmElement {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedOsmRelationID*)objectID;





@property (nonatomic, strong) NSOrderedSet *members;

- (NSMutableOrderedSet*)membersSet;





@end

@interface _OPEManagedOsmRelation (CoreDataGeneratedAccessors)

- (void)addMembers:(NSOrderedSet*)value_;
- (void)removeMembers:(NSOrderedSet*)value_;
- (void)addMembersObject:(OpeManagedOsmRelationMember*)value_;
- (void)removeMembersObject:(OpeManagedOsmRelationMember*)value_;

@end

@interface _OPEManagedOsmRelation (CoreDataGeneratedPrimitiveAccessors)



- (NSMutableOrderedSet*)primitiveMembers;
- (void)setPrimitiveMembers:(NSMutableOrderedSet*)value;


@end
