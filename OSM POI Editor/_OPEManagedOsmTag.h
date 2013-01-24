// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmTag.h instead.

#import <CoreData/CoreData.h>


extern const struct OPEManagedOsmTagAttributes {
	__unsafe_unretained NSString *key;
	__unsafe_unretained NSString *value;
} OPEManagedOsmTagAttributes;

extern const struct OPEManagedOsmTagRelationships {
	__unsafe_unretained NSString *osmElements;
	__unsafe_unretained NSString *referenceOsmTag;
	__unsafe_unretained NSString *referencePois;
} OPEManagedOsmTagRelationships;

extern const struct OPEManagedOsmTagFetchedProperties {
} OPEManagedOsmTagFetchedProperties;

@class OPEManagedOsmElement;
@class OPEManagedReferenceOsmTag;
@class OPEManagedReferencePoi;




@interface OPEManagedOsmTagID : NSManagedObjectID {}
@end

@interface _OPEManagedOsmTag : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedOsmTagID*)objectID;





@property (nonatomic, strong) NSString* key;



//- (BOOL)validateKey:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* value;



//- (BOOL)validateValue:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *osmElements;

- (NSMutableSet*)osmElementsSet;




@property (nonatomic, strong) NSSet *referenceOsmTag;

- (NSMutableSet*)referenceOsmTagSet;




@property (nonatomic, strong) NSSet *referencePois;

- (NSMutableSet*)referencePoisSet;





@end

@interface _OPEManagedOsmTag (CoreDataGeneratedAccessors)

- (void)addOsmElements:(NSSet*)value_;
- (void)removeOsmElements:(NSSet*)value_;
- (void)addOsmElementsObject:(OPEManagedOsmElement*)value_;
- (void)removeOsmElementsObject:(OPEManagedOsmElement*)value_;

- (void)addReferenceOsmTag:(NSSet*)value_;
- (void)removeReferenceOsmTag:(NSSet*)value_;
- (void)addReferenceOsmTagObject:(OPEManagedReferenceOsmTag*)value_;
- (void)removeReferenceOsmTagObject:(OPEManagedReferenceOsmTag*)value_;

- (void)addReferencePois:(NSSet*)value_;
- (void)removeReferencePois:(NSSet*)value_;
- (void)addReferencePoisObject:(OPEManagedReferencePoi*)value_;
- (void)removeReferencePoisObject:(OPEManagedReferencePoi*)value_;

@end

@interface _OPEManagedOsmTag (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveKey;
- (void)setPrimitiveKey:(NSString*)value;




- (NSString*)primitiveValue;
- (void)setPrimitiveValue:(NSString*)value;





- (NSMutableSet*)primitiveOsmElements;
- (void)setPrimitiveOsmElements:(NSMutableSet*)value;



- (NSMutableSet*)primitiveReferenceOsmTag;
- (void)setPrimitiveReferenceOsmTag:(NSMutableSet*)value;



- (NSMutableSet*)primitiveReferencePois;
- (void)setPrimitiveReferencePois:(NSMutableSet*)value;


@end
