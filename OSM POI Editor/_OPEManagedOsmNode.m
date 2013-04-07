// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmNode.m instead.

#import "_OPEManagedOsmNode.h"

const struct OPEManagedOsmNodeAttributes OPEManagedOsmNodeAttributes = {
	.latitude = @"latitude",
	.longitude = @"longitude",
};

const struct OPEManagedOsmNodeRelationships OPEManagedOsmNodeRelationships = {
	.ways = @"ways",
	.waysReference = @"waysReference",
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
	
	if ([key isEqualToString:@"latitudeValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"latitude"];
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




@dynamic latitude;



- (double)latitudeValue {
	NSNumber *result = [self latitude];
	return [result doubleValue];
}

- (void)setLatitudeValue:(double)value_ {
	[self setLatitude:[NSNumber numberWithDouble:value_]];
}

- (double)primitiveLatitudeValue {
	NSNumber *result = [self primitiveLatitude];
	return [result doubleValue];
}

- (void)setPrimitiveLatitudeValue:(double)value_ {
	[self setPrimitiveLatitude:[NSNumber numberWithDouble:value_]];
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
	

@dynamic waysReference;

	
- (NSMutableSet*)waysReferenceSet {
	[self willAccessValueForKey:@"waysReference"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"waysReference"];
  
	[self didAccessValueForKey:@"waysReference"];
	return result;
}
	






@end
