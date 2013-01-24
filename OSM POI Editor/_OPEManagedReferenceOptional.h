// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferenceOptional.h instead.

#import <CoreData/CoreData.h>


extern const struct OPEManagedReferenceOptionalAttributes {
	__unsafe_unretained NSString *displayName;
	__unsafe_unretained NSString *name;
	__unsafe_unretained NSString *section;
	__unsafe_unretained NSString *sectionSortOrder;
} OPEManagedReferenceOptionalAttributes;

extern const struct OPEManagedReferenceOptionalRelationships {
	__unsafe_unretained NSString *referencePois;
	__unsafe_unretained NSString *tags;
} OPEManagedReferenceOptionalRelationships;

extern const struct OPEManagedReferenceOptionalFetchedProperties {
} OPEManagedReferenceOptionalFetchedProperties;

@class OPEManagedReferencePoi;
@class OPEManagedReferenceOsmTag;






@interface OPEManagedReferenceOptionalID : NSManagedObjectID {}
@end

@interface _OPEManagedReferenceOptional : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedReferenceOptionalID*)objectID;





@property (nonatomic, strong) NSString* displayName;



//- (BOOL)validateDisplayName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* section;



//- (BOOL)validateSection:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* sectionSortOrder;



@property int16_t sectionSortOrderValue;
- (int16_t)sectionSortOrderValue;
- (void)setSectionSortOrderValue:(int16_t)value_;

//- (BOOL)validateSectionSortOrder:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *referencePois;

- (NSMutableSet*)referencePoisSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _OPEManagedReferenceOptional (CoreDataGeneratedAccessors)

- (void)addReferencePois:(NSSet*)value_;
- (void)removeReferencePois:(NSSet*)value_;
- (void)addReferencePoisObject:(OPEManagedReferencePoi*)value_;
- (void)removeReferencePoisObject:(OPEManagedReferencePoi*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(OPEManagedReferenceOsmTag*)value_;
- (void)removeTagsObject:(OPEManagedReferenceOsmTag*)value_;

@end

@interface _OPEManagedReferenceOptional (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveDisplayName;
- (void)setPrimitiveDisplayName:(NSString*)value;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;




- (NSString*)primitiveSection;
- (void)setPrimitiveSection:(NSString*)value;




- (NSNumber*)primitiveSectionSortOrder;
- (void)setPrimitiveSectionSortOrder:(NSNumber*)value;

- (int16_t)primitiveSectionSortOrderValue;
- (void)setPrimitiveSectionSortOrderValue:(int16_t)value_;





- (NSMutableSet*)primitiveReferencePois;
- (void)setPrimitiveReferencePois:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end
