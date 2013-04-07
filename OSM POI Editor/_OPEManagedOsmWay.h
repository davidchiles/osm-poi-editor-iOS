// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmWay.h instead.

#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"

extern const struct OPEManagedOsmWayAttributes {
	__unsafe_unretained NSString *isArea;
	__unsafe_unretained NSString *isNoNameStreet;
} OPEManagedOsmWayAttributes;

extern const struct OPEManagedOsmWayRelationships {
	__unsafe_unretained NSString *nodes;
	__unsafe_unretained NSString *orderedNodes;
} OPEManagedOsmWayRelationships;

extern const struct OPEManagedOsmWayFetchedProperties {
} OPEManagedOsmWayFetchedProperties;

@class OPEManagedOsmNode;
@class OPEManagedOsmNodeReference;




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





@property (nonatomic, strong) NSNumber* isNoNameStreet;



@property BOOL isNoNameStreetValue;
- (BOOL)isNoNameStreetValue;
- (void)setIsNoNameStreetValue:(BOOL)value_;

//- (BOOL)validateIsNoNameStreet:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *nodes;

- (NSMutableSet*)nodesSet;




@property (nonatomic, strong) NSOrderedSet *orderedNodes;

- (NSMutableOrderedSet*)orderedNodesSet;





@end

@interface _OPEManagedOsmWay (CoreDataGeneratedAccessors)

- (void)addNodes:(NSSet*)value_;
- (void)removeNodes:(NSSet*)value_;
- (void)addNodesObject:(OPEManagedOsmNode*)value_;
- (void)removeNodesObject:(OPEManagedOsmNode*)value_;

- (void)addOrderedNodes:(NSOrderedSet*)value_;
- (void)removeOrderedNodes:(NSOrderedSet*)value_;
- (void)addOrderedNodesObject:(OPEManagedOsmNodeReference*)value_;
- (void)removeOrderedNodesObject:(OPEManagedOsmNodeReference*)value_;

@end

@interface _OPEManagedOsmWay (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveIsArea;
- (void)setPrimitiveIsArea:(NSNumber*)value;

- (BOOL)primitiveIsAreaValue;
- (void)setPrimitiveIsAreaValue:(BOOL)value_;




- (NSNumber*)primitiveIsNoNameStreet;
- (void)setPrimitiveIsNoNameStreet:(NSNumber*)value;

- (BOOL)primitiveIsNoNameStreetValue;
- (void)setPrimitiveIsNoNameStreetValue:(BOOL)value_;





- (NSMutableSet*)primitiveNodes;
- (void)setPrimitiveNodes:(NSMutableSet*)value;



- (NSMutableOrderedSet*)primitiveOrderedNodes;
- (void)setPrimitiveOrderedNodes:(NSMutableOrderedSet*)value;


@end
