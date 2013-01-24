// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmNode.h instead.

#import <CoreData/CoreData.h>
#import "OPEManagedOsmElement.h"

extern const struct OPEManagedOsmNodeAttributes {
	__unsafe_unretained NSString *lattitude;
	__unsafe_unretained NSString *longitude;
} OPEManagedOsmNodeAttributes;

extern const struct OPEManagedOsmNodeRelationships {
	__unsafe_unretained NSString *ways;
} OPEManagedOsmNodeRelationships;

extern const struct OPEManagedOsmNodeFetchedProperties {
} OPEManagedOsmNodeFetchedProperties;

@class OPEManagedOsmWay;




@interface OPEManagedOsmNodeID : NSManagedObjectID {}
@end

@interface _OPEManagedOsmNode : OPEManagedOsmElement {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedOsmNodeID*)objectID;





@property (nonatomic, strong) NSNumber* lattitude;



@property double lattitudeValue;
- (double)lattitudeValue;
- (void)setLattitudeValue:(double)value_;

//- (BOOL)validateLattitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* longitude;



@property double longitudeValue;
- (double)longitudeValue;
- (void)setLongitudeValue:(double)value_;

//- (BOOL)validateLongitude:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *ways;

- (NSMutableSet*)waysSet;





@end

@interface _OPEManagedOsmNode (CoreDataGeneratedAccessors)

- (void)addWays:(NSSet*)value_;
- (void)removeWays:(NSSet*)value_;
- (void)addWaysObject:(OPEManagedOsmWay*)value_;
- (void)removeWaysObject:(OPEManagedOsmWay*)value_;

@end

@interface _OPEManagedOsmNode (CoreDataGeneratedPrimitiveAccessors)


- (NSNumber*)primitiveLattitude;
- (void)setPrimitiveLattitude:(NSNumber*)value;

- (double)primitiveLattitudeValue;
- (void)setPrimitiveLattitudeValue:(double)value_;




- (NSNumber*)primitiveLongitude;
- (void)setPrimitiveLongitude:(NSNumber*)value;

- (double)primitiveLongitudeValue;
- (void)setPrimitiveLongitudeValue:(double)value_;





- (NSMutableSet*)primitiveWays;
- (void)setPrimitiveWays:(NSMutableSet*)value;


@end
