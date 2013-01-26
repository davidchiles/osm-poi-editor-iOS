// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferencePoiCategory.h instead.

#import <CoreData/CoreData.h>


extern const struct OPEManagedReferencePoiCategoryAttributes {
	__unsafe_unretained NSString *name;
} OPEManagedReferencePoiCategoryAttributes;

extern const struct OPEManagedReferencePoiCategoryRelationships {
	__unsafe_unretained NSString *referencePois;
} OPEManagedReferencePoiCategoryRelationships;

extern const struct OPEManagedReferencePoiCategoryFetchedProperties {
} OPEManagedReferencePoiCategoryFetchedProperties;

@class OPEManagedReferencePoi;



@interface OPEManagedReferencePoiCategoryID : NSManagedObjectID {}
@end

@interface _OPEManagedReferencePoiCategory : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedReferencePoiCategoryID*)objectID;





@property (nonatomic, strong) NSString* name;



//- (BOOL)validateName:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *referencePois;

- (NSMutableSet*)referencePoisSet;





@end

@interface _OPEManagedReferencePoiCategory (CoreDataGeneratedAccessors)

- (void)addReferencePois:(NSSet*)value_;
- (void)removeReferencePois:(NSSet*)value_;
- (void)addReferencePoisObject:(OPEManagedReferencePoi*)value_;
- (void)removeReferencePoisObject:(OPEManagedReferencePoi*)value_;

@end

@interface _OPEManagedReferencePoiCategory (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveName;
- (void)setPrimitiveName:(NSString*)value;





- (NSMutableSet*)primitiveReferencePois;
- (void)setPrimitiveReferencePois:(NSMutableSet*)value;


@end
