// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferencePoi.m instead.

#import "_OPEManagedReferencePoi.h"

const struct OPEManagedReferencePoiAttributes OPEManagedReferencePoiAttributes = {
	.canAdd = @"canAdd",
	.category = @"category",
	.imageString = @"imageString",
	.isLegacy = @"isLegacy",
	.name = @"name",
};

const struct OPEManagedReferencePoiRelationships OPEManagedReferencePoiRelationships = {
	.newTagMethod = @"newTagMethod",
	.oldTagMethods = @"oldTagMethods",
	.optional = @"optional",
	.osmElements = @"osmElements",
	.tags = @"tags",
};

const struct OPEManagedReferencePoiFetchedProperties OPEManagedReferencePoiFetchedProperties = {
};

@implementation OPEManagedReferencePoiID
@end

@implementation _OPEManagedReferencePoi

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedReferencePoi" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedReferencePoi";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedReferencePoi" inManagedObjectContext:moc_];
}

- (OPEManagedReferencePoiID*)objectID {
	return (OPEManagedReferencePoiID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"canAddValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"canAdd"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}
	if ([key isEqualToString:@"isLegacyValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"isLegacy"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic canAdd;



- (BOOL)canAddValue {
	NSNumber *result = [self canAdd];
	return [result boolValue];
}

- (void)setCanAddValue:(BOOL)value_ {
	[self setCanAdd:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveCanAddValue {
	NSNumber *result = [self primitiveCanAdd];
	return [result boolValue];
}

- (void)setPrimitiveCanAddValue:(BOOL)value_ {
	[self setPrimitiveCanAdd:[NSNumber numberWithBool:value_]];
}





@dynamic category;






@dynamic imageString;






@dynamic isLegacy;



- (BOOL)isLegacyValue {
	NSNumber *result = [self isLegacy];
	return [result boolValue];
}

- (void)setIsLegacyValue:(BOOL)value_ {
	[self setIsLegacy:[NSNumber numberWithBool:value_]];
}

- (BOOL)primitiveIsLegacyValue {
	NSNumber *result = [self primitiveIsLegacy];
	return [result boolValue];
}

- (void)setPrimitiveIsLegacyValue:(BOOL)value_ {
	[self setPrimitiveIsLegacy:[NSNumber numberWithBool:value_]];
}





@dynamic name;






@dynamic newTagMethod;

	

@dynamic oldTagMethods;

	
- (NSMutableSet*)oldTagMethodsSet {
	[self willAccessValueForKey:@"oldTagMethods"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"oldTagMethods"];
  
	[self didAccessValueForKey:@"oldTagMethods"];
	return result;
}
	

@dynamic optional;

	
- (NSMutableSet*)optionalSet {
	[self willAccessValueForKey:@"optional"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"optional"];
  
	[self didAccessValueForKey:@"optional"];
	return result;
}
	

@dynamic osmElements;

	
- (NSMutableSet*)osmElementsSet {
	[self willAccessValueForKey:@"osmElements"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"osmElements"];
  
	[self didAccessValueForKey:@"osmElements"];
	return result;
}
	

@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	






@end
