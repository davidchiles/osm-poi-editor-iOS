// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmNodeReference.h instead.

#import <CoreData/CoreData.h>


extern const struct OPEManagedOsmNodeReferenceAttributes {
} OPEManagedOsmNodeReferenceAttributes;

extern const struct OPEManagedOsmNodeReferenceRelationships {
	__unsafe_unretained NSString *node;
	__unsafe_unretained NSString *way;
} OPEManagedOsmNodeReferenceRelationships;

extern const struct OPEManagedOsmNodeReferenceFetchedProperties {
} OPEManagedOsmNodeReferenceFetchedProperties;

@class OPEManagedOsmNode;
@class OPEManagedOsmWay;


@interface OPEManagedOsmNodeReferenceID : NSManagedObjectID {}
@end

@interface _OPEManagedOsmNodeReference : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedOsmNodeReferenceID*)objectID;





@property (nonatomic, strong) OPEManagedOsmNode *node;

//- (BOOL)validateNode:(id*)value_ error:(NSError**)error_;




@property (nonatomic, strong) OPEManagedOsmWay *way;

//- (BOOL)validateWay:(id*)value_ error:(NSError**)error_;





@end

@interface _OPEManagedOsmNodeReference (CoreDataGeneratedAccessors)

@end

@interface _OPEManagedOsmNodeReference (CoreDataGeneratedPrimitiveAccessors)



- (OPEManagedOsmNode*)primitiveNode;
- (void)setPrimitiveNode:(OPEManagedOsmNode*)value;



- (OPEManagedOsmWay*)primitiveWay;
- (void)setPrimitiveWay:(OPEManagedOsmWay*)value;


@end
