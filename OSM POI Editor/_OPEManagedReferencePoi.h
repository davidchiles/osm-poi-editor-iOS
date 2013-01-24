// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferencePoi.h instead.

#import <CoreData/CoreData.h>


extern const struct OPEManagedReferencePoiAttributes {
	__unsafe_unretained NSString *canAdd;
	__unsafe_unretained NSString *category;
	__unsafe_unretained NSString *imageString;
	__unsafe_unretained NSString *isLegacy;
	__unsafe_unretained NSString *name;
} OPEManagedReferencePoiAttributes;

extern const struct OPEManagedReferencePoiRelationships {
	__unsafe_unretained NSString *newTagMethod;
	__unsafe_unretained NSString *oldTagMethods;
	__unsafe_unretained NSString *optional;
	__unsafe_unretained NSString *osmElements;
	__unsafe_unretained NSString *tags;
} OPEManagedReferencePoiRelationships;

extern const struct OPEManagedReferencePoiFetchedProperties {
} OPEManagedReferencePoiFetchedProperties;

@class OPEManagedReferencePoi;
@class OPEManagedReferencePoi;
@class OPEManagedReferenceOptional;
@class OPEManagedOsmElement;
@class OPEManagedOsmTag;







@interface OPEManagedReferencePoiID : NSManagedObjectID {}
@end

@interface _OPEManagedReferencePoi : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedReferencePoiID*)objectID;





@property (nonatomic, strong) NSNumber* canAdd;



@property BOOL canAddValue;
- (BOOL)canAddValue;
- (void)setCanAddValue:(BOOL)value_;

//- (BOOL)validateCanAdd:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* category;



//- (BOOL)validateCategory:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* imageString;



//- (BOOL)validateImageString:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isLegacy;



@property BOOL isLegacyValue;
- (BOOL)isLegacyValue;
- (void)setIsLegacyValue:(BOOL)value_;

//- (BOOL)validateIsLegacy:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) OPEManagedReferencePoi *newTagMethod;

//- (BOOL)validateNewTagMethod:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) NSSet *oldTagMethods;

- (NSMutableSet*)oldTagMethodsSet;




@property (nonatomic, strong) NSSet *optional;

- (NSMutableSet*)optionalSet;




@property (nonatomic, strong) NSSet *osmElements;

- (NSMutableSet*)osmElementsSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;





@end

@interface _OPEManagedReferencePoi (CoreDataGeneratedAccessors)

- (void)addOldTagMethods:(NSSet*)value_;
- (void)removeOldTagMethods:(NSSet*)value_;
- (void)addOldTagMethodsObject:(OPEManagedReferencePoi*)value_;
- (void)removeOldTagMethodsObject:(OPEManagedReferencePoi*)value_;

- (void)addOptional:(NSSet*)value_;
- (void)removeOptional:(NSSet*)value_;
- (void)addOptionalObject:(OPEManagedReferenceOptional*)value_;
- (void)removeOptionalObject:(OPEManagedReferenceOptional*)value_;

- (void)addOsmElements:(NSSet*)value_;
- (void)removeOsmElements:(NSSet*)value_;
- (void)addOsmElementsObject:(OPEManagedOsmElement*)value_;
- (void)removeOsmElementsObject:(OPEManagedOsmElement*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(OPEManagedOsmTag*)value_;
- (void)removeTagsObject:(OPEManagedOsmTag*)value_;

@end

@interface _OPEManagedReferencePoi (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveCanAdd;
- (void)setPrimitiveCanAdd:(NSNumber*)value;

- (BOOL)primitiveCanAddValue;
- (void)setPrimitiveCanAddValue:(BOOL)value_;




- (NSString*)primitiveCategory;
- (void)setPrimitiveCategory:(NSString*)value;




- (NSString*)primitiveImageString;
- (void)setPrimitiveImageString:(NSString*)value;




- (NSNumber*)primitiveIsLegacy;
- (void)setPrimitiveIsLegacy:(NSNumber*)value;

- (BOOL)primitiveIsLegacyValue;
- (void)setPrimitiveIsLegacyValue:(BOOL)value_;




- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (OPEManagedReferencePoi*)primitiveNewTagMethod;
- (void)setPrimitiveNewTagMethod:(OPEManagedReferencePoi*)value;



- (NSMutableSet*)primitiveOldTagMethods;
- (void)setPrimitiveOldTagMethods:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOptional;
- (void)setPrimitiveOptional:(NSMutableSet*)value;



- (NSMutableSet*)primitiveOsmElements;
- (void)setPrimitiveOsmElements:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;


@end
