// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferenceOptionalCategory.m instead.

#import "_OPEManagedReferenceOptionalCategory.h"

const struct OPEManagedReferenceOptionalCategoryAttributes OPEManagedReferenceOptionalCategoryAttributes = {
	.displayName = @"displayName",
	.sortOrder = @"sortOrder",
};

const struct OPEManagedReferenceOptionalCategoryRelationships OPEManagedReferenceOptionalCategoryRelationships = {
	.referenceOptionals = @"referenceOptionals",
};

const struct OPEManagedReferenceOptionalCategoryFetchedProperties OPEManagedReferenceOptionalCategoryFetchedProperties = {
};

@implementation OPEManagedReferenceOptionalCategoryID
@end

@implementation _OPEManagedReferenceOptionalCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedReferenceOptionalCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedReferenceOptionalCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedReferenceOptionalCategory" inManagedObjectContext:moc_];
}

- (OPEManagedReferenceOptionalCategoryID*)objectID {
	return (OPEManagedReferenceOptionalCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"sortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic displayName;






@dynamic sortOrder;



- (int16_t)sortOrderValue {
	NSNumber *result = [self sortOrder];
	return [result shortValue];
}

- (void)setSortOrderValue:(int16_t)value_ {
	[self setSortOrder:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSortOrderValue {
	NSNumber *result = [self primitiveSortOrder];
	return [result shortValue];
}

- (void)setPrimitiveSortOrderValue:(int16_t)value_ {
	[self setPrimitiveSortOrder:[NSNumber numberWithShort:value_]];
}





@dynamic referenceOptionals;

	
- (NSMutableSet*)referenceOptionalsSet {
	[self willAccessValueForKey:@"referenceOptionals"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"referenceOptionals"];
  
	[self didAccessValueForKey:@"referenceOptionals"];
	return result;
}
	






@end
