// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferenceOsmTag.h instead.

#import <CoreData/CoreData.h>


extern const struct OPEManagedReferenceOsmTagAttributes {
	__unsafe_unretained NSString *name;
} OPEManagedReferenceOsmTagAttributes;

extern const struct OPEManagedReferenceOsmTagRelationships {
	__unsafe_unretained NSString *referenceOptionals;
	__unsafe_unretained NSString *tag;
} OPEManagedReferenceOsmTagRelationships;

extern const struct OPEManagedReferenceOsmTagFetchedProperties {
} OPEManagedReferenceOsmTagFetchedProperties;

@class OPEManagedReferenceOptional;
@class OPEManagedOsmTag;



@interface OPEManagedReferenceOsmTagID : NSManagedObjectID {}
@end

@interface _OPEManagedReferenceOsmTag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedReferenceOsmTagID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *referenceOptionals;

- (NSMutableSet*)referenceOptionalsSet;




@property (nonatomic, strong) OPEManagedOsmTag *tag;

//- (BOOL)validateTag:(id*)value_ error:(NSError**)error_;





@end

@interface _OPEManagedReferenceOsmTag (CoreDataGeneratedAccessors)

- (void)addReferenceOptionals:(NSSet*)value_;
- (void)removeReferenceOptionals:(NSSet*)value_;
- (void)addReferenceOptionalsObject:(OPEManagedReferenceOptional*)value_;
- (void)removeReferenceOptionalsObject:(OPEManagedReferenceOptional*)value_;

@end

@interface _OPEManagedReferenceOsmTag (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveReferenceOptionals;
- (void)setPrimitiveReferenceOptionals:(NSMutableSet*)value;



- (OPEManagedOsmTag*)primitiveTag;
- (void)setPrimitiveTag:(OPEManagedOsmTag*)value;


@end
