// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpeManagedOsmRelationMember.h instead.

#import <CoreData/CoreData.h>


extern const struct OpeManagedOsmRelationMemberAttributes {
	__unsafe_unretained NSString *role;
} OpeManagedOsmRelationMemberAttributes;

extern const struct OpeManagedOsmRelationMemberRelationships {
	__unsafe_unretained NSString *member;
	__unsafe_unretained NSString *osmRelation;
} OpeManagedOsmRelationMemberRelationships;

extern const struct OpeManagedOsmRelationMemberFetchedProperties {
} OpeManagedOsmRelationMemberFetchedProperties;

@class OPEManagedOsmElement;
@class OPEManagedOsmRelation;



@interface OpeManagedOsmRelationMemberID : NSManagedObjectID {}
@end

@interface _OpeManagedOsmRelationMember : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OpeManagedOsmRelationMemberID*)objectID;





@property (nonatomic, strong) NSString* role;



//- (BOOL)validateRole:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) OPEManagedOsmElement *member;

//- (BOOL)validateMember:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) OPEManagedOsmRelation *osmRelation;

//- (BOOL)validateOsmRelation:(id*)value_ error:(NSError**)error_;





@end

@interface _OpeManagedOsmRelationMember (CoreDataGeneratedAccessors)

@end

@interface _OpeManagedOsmRelationMember (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveRole;
- (void)setPrimitiveRole:(NSString*)value;





- (OPEManagedOsmElement*)primitiveMember;
- (void)setPrimitiveMember:(OPEManagedOsmElement*)value;



- (OPEManagedOsmRelation*)primitiveOsmRelation;
- (void)setPrimitiveOsmRelation:(OPEManagedOsmRelation*)value;


@end
