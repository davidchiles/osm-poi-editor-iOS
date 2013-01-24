// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmWay.h instead.

#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"

extern const struct OPEManagedOsmWayAttributes {
	__unsafe_unretained NSString *isArea;
} OPEManagedOsmWayAttributes;

extern const struct OPEManagedOsmWayRelationships {
	__unsafe_unretained NSString *nodes;
} OPEManagedOsmWayRelationships;

extern const struct OPEManagedOsmWayFetchedProperties {
} OPEManagedOsmWayFetchedProperties;

@class OPEManagedOsmNode;



@interface OPEManagedOsmWayID : NSManagedObjectID {}
@end

@interface _OPEManagedOsmWay : OPEManagedOsmElement {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedOsmWayID*)objectID;





@property (nonatomic, strong) NSNumber* isArea;



@property BOOL isAreaValue;
- (BOOL)isAreaValue;
- (void)setIsAreaValue:(BOOL)value_;

//- (BOOL)validateIsArea:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSOrderedSet *nodes;

- (NSMutableOrderedSet*)nodesSet;





@end

@interface _OPEManagedOsmWay (CoreDataGeneratedAccessors)

- (void)addNodes:(NSOrderedSet*)value_;
- (void)removeNodes:(NSOrderedSet*)value_;
- (void)addNodesObject:(OPEManagedOsmNode*)value_;
- (void)removeNodesObject:(OPEManagedOsmNode*)value_;

@end

@interface _OPEManagedOsmWay (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsArea;
- (void)setPrimitiveIsArea:(NSNumber*)value;

- (BOOL)primitiveIsAreaValue;
- (void)setPrimitiveIsAreaValue:(BOOL)value_;





- (NSMutableOrderedSet*)primitiveNodes;
- (void)setPrimitiveNodes:(NSMutableOrderedSet*)value;


@end
