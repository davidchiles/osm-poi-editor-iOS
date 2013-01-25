// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferenceOptionalCategory.h instead.

#import <CoreData/CoreData.h>


extern const struct OPEManagedReferenceOptionalCategoryAttributes {
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *sortOrder;
} OPEManagedReferenceOptionalCategoryAttributes;

extern const struct OPEManagedReferenceOptionalCategoryRelationships {
	__unsafe_unretained NSString *referenceOptionals;
} OPEManagedReferenceOptionalCategoryRelationships;

extern const struct OPEManagedReferenceOptionalCategoryFetchedProperties {
} OPEManagedReferenceOptionalCategoryFetchedProperties;

@class OPEManagedReferenceOptional;




@interface OPEManagedReferenceOptionalCategoryID : NSManagedObjectID {}
@end

@interface _OPEManagedReferenceOptionalCategory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedReferenceOptionalCategoryID*)objectID;





@property (nonatomic, strong) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sortOrder;



@property int16_t sortOrderValue;
- (int16_t)sortOrderValue;
- (void)setSortOrderValue:(int16_t)value_;

//- (BOOL)validateSortOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *referenceOptionals;

- (NSMutableSet*)referenceOptionalsSet;





@end

@interface _OPEManagedReferenceOptionalCategory (CoreDataGeneratedAccessors)

- (void)addReferenceOptionals:(NSSet*)value_;
- (void)removeReferenceOptionals:(NSSet*)value_;
- (void)addReferenceOptionalsObject:(OPEManagedReferenceOptional*)value_;
- (void)removeReferenceOptionalsObject:(OPEManagedReferenceOptional*)value_;

@end

@interface _OPEManagedReferenceOptionalCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSNumber*)primitiveSortOrder;
- (void)setPrimitiveSortOrder:(NSNumber*)value;

- (int16_t)primitiveSortOrderValue;
- (void)setPrimitiveSortOrderValue:(int16_t)value_;





- (NSMutableSet*)primitiveReferenceOptionals;
- (void)setPrimitiveReferenceOptionals:(NSMutableSet*)value;


@end
