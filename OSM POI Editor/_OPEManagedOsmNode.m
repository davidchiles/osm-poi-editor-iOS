// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmNode.m instead.

#import "_OPEManagedOsmNode.h"

const struct OPEManagedOsmNodeAttributes OPEManagedOsmNodeAttributes = {
	.lattitude = @"lattitude",
	.longitude = @"longitude",
};

const struct OPEManagedOsmNodeRelationships OPEManagedOsmNodeRelationships = {
	.ways = @"ways",
};

const struct OPEManagedOsmNodeFetchedProperties OPEManagedOsmNodeFetchedProperties = {
};

@implementation OPEManagedOsmNodeID
@end

@implementation _OPEManagedOsmNode

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedOsmNode" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedOsmNode";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedOsmNode" inManagedObjectContext:moc_];
}

- (OPEManagedOsmNodeID*)objectID {
	return (OPEManagedOsmNodeID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"lattitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"lattitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"longitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"longitude"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic lattitude;



- (double)lattitudeValue {
	NSNumber *result = [self lattitude];
	return [result doubleValue];
}

- (void)setLattitudeValue:(double)value_ {
	[self setLattitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLattitudeValue {
	NSNumber *result = [self primitiveLattitude];
	return [result doubleValue];
}

- (void)setPrimitiveLattitudeValue:(double)value_ {
	[self setPrimitiveLattitude:[NSNumber numberWithDouble:value_]];
}





@dynamic longitude;



- (double)longitudeValue {
	NSNumber *result = [self longitude];
	return [result doubleValue];
}

- (void)setLongitudeValue:(double)value_ {
	[self setLongitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLongitudeValue {
	NSNumber *result = [self primitiveLongitude];
	return [result doubleValue];
}

- (void)setPrimitiveLongitudeValue:(double)value_ {
	[self setPrimitiveLongitude:[NSNumber numberWithDouble:value_]];
}





@dynamic ways;

	
- (NSMutableSet*)waysSet {
	[self willAccessValueForKey:@"ways"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"ways"];
  
	[self didAccessValueForKey:@"ways"];
	return result;
}
	






@end
