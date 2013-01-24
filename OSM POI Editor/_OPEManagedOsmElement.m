// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmElement.m instead.

#import "_OPEManagedOsmElement.h"

const struct OPEManagedOsmElementAttributes OPEManagedOsmElementAttributes = {
	.osmID = @"osmID",
	.version = @"version",
};

const struct OPEManagedOsmElementRelationships OPEManagedOsmElementRelationships = {
	.parentRelations = @"parentRelations",
	.tags = @"tags",
	.type = @"type",
};

const struct OPEManagedOsmElementFetchedProperties OPEManagedOsmElementFetchedProperties = {
};

@implementation OPEManagedOsmElementID
@end

@implementation _OPEManagedOsmElement

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedOsmElement" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedOsmElement";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedOsmElement" inManagedObjectContext:moc_];
}

- (OPEManagedOsmElementID*)objectID {
	return (OPEManagedOsmElementID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"osmIDValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"osmID"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"versionValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"version"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic osmID;



- (int64_t)osmIDValue {
	NSNumber *result = [self osmID];
	return [result longLongValue];
}

- (void)setOsmIDValue:(int64_t)value_ {
	[self setOsmID:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveOsmIDValue {
	NSNumber *result = [self primitiveOsmID];
	return [result longLongValue];
}

- (void)setPrimitiveOsmIDValue:(int64_t)value_ {
	[self setPrimitiveOsmID:[NSNumber numberWithLongLong:value_]];
}





@dynamic version;



- (int64_t)versionValue {
	NSNumber *result = [self version];
	return [result longLongValue];
}

- (void)setVersionValue:(int64_t)value_ {
	[self setVersion:[NSNumber numberWithLongLong:value_]];
}

- (int64_t)primitiveVersionValue {
	NSNumber *result = [self primitiveVersion];
	return [result longLongValue];
}

- (void)setPrimitiveVersionValue:(int64_t)value_ {
	[self setPrimitiveVersion:[NSNumber numberWithLongLong:value_]];
}





@dynamic parentRelations;

	
- (NSMutableSet*)parentRelationsSet {
	[self willAccessValueForKey:@"parentRelations"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"parentRelations"];
  
	[self didAccessValueForKey:@"parentRelations"];
	return result;
}
	

@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	

@dynamic type;

	






@end
