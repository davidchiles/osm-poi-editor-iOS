// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmWay.m instead.

#import "_OPEManagedOsmWay.h"

const struct OPEManagedOsmWayAttributes OPEManagedOsmWayAttributes = {
	.isArea = @"isArea",
};

const struct OPEManagedOsmWayRelationships OPEManagedOsmWayRelationships = {
	.nodes = @"nodes",
};

const struct OPEManagedOsmWayFetchedProperties OPEManagedOsmWayFetchedProperties = {
};

@implementation OPEManagedOsmWayID
@end

@implementation _OPEManagedOsmWay

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedOsmWay" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedOsmWay";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedOsmWay" inManagedObjectContext:moc_];
}

- (OPEManagedOsmWayID*)objectID {
	return (OPEManagedOsmWayID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"isAreaValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isArea"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic isArea;



- (BOOL)isAreaValue {
	NSNumber *result = [self isArea];
	return [result boolValue];
}

- (void)setIsAreaValue:(BOOL)value_ {
	[self setIsArea:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsAreaValue {
	NSNumber *result = [self primitiveIsArea];
	return [result boolValue];
}

- (void)setPrimitiveIsAreaValue:(BOOL)value_ {
	[self setPrimitiveIsArea:[NSNumber numberWithBool:value_]];
}





@dynamic nodes;

	
- (NSMutableOrderedSet*)nodesSet {
	[self willAccessValueForKey:@"nodes"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"nodes"];
  
	[self didAccessValueForKey:@"nodes"];
	return result;
}
	






@end