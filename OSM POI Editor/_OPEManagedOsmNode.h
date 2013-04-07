// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmNode.h instead.

#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"

extern const struct OPEManagedOsmNodeAttributes {
	__unsafe_unretained NSString *latitude;
	__unsafe_unretained NSString *longitude;
} OPEManagedOsmNodeAttributes;

extern const struct OPEManagedOsmNodeRelationships {
	__unsafe_unretained NSString *ways;
	__unsafe_unretained NSString *waysReference;
} OPEManagedOsmNodeRelationships;

extern const struct OPEManagedOsmNodeFetchedProperties {
} OPEManagedOsmNodeFetchedProperties;

@class OPEManagedOsmWay;
@class OPEManagedOsmNodeReference;




@interface OPEManagedOsmNodeID : NSManagedObjectID {}
@end

@interface _OPEManagedOsmNode : OPEManagedOsmElement {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedOsmNodeID*)objectID;





@property (nonatomic, strong) NSNumber* latitude;



@property double latitudeValue;
- (double)latitudeValue;
- (void)setLatitudeValue:(double)value_;

//- (BOOL)validateLatitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *ways;

- (NSMutableSet*)waysSet;




@property (nonatomic, strong) NSSet *waysReference;

- (NSMutableSet*)waysReferenceSet;





@end

@interface _OPEManagedOsmNode (CoreDataGeneratedAccessors)

- (void)addWays:(NSSet*)value_;
- (void)removeWays:(NSSet*)value_;
- (void)addWaysObject:(OPEManagedOsmWay*)value_;
- (void)removeWaysObject:(OPEManagedOsmWay*)value_;

- (void)addWaysReference:(NSSet*)value_;
- (void)removeWaysReference:(NSSet*)value_;
- (void)addWaysReferenceObject:(OPEManagedOsmNodeReference*)value_;
- (void)removeWaysReferenceObject:(OPEManagedOsmNodeReference*)value_;

@end

@interface _OPEManagedOsmNode (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveLatitude;
- (void)setPrimitiveLatitude:(NSNumber*)value;

- (double)primitiveLatitudeValue;
- (void)setPrimitiveLatitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;





- (NSMutableSet*)primitiveWays;
- (void)setPrimitiveWays:(NSMutableSet*)value;



- (NSMutableSet*)primitiveWaysReference;
- (void)setPrimitiveWaysReference:(NSMutableSet*)value;


@end
