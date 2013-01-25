// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferenceOptional.m instead.

#import "_OPEManagedReferenceOptional.h"

const struct OPEManagedReferenceOptionalAttributes OPEManagedReferenceOptionalAttributes = {
	.displayName = @"displayName",
	.name = @"name",
	.osmKey = @"osmKey",
	.sectionSortOrder = @"sectionSortOrder",
};

const struct OPEManagedReferenceOptionalRelationships OPEManagedReferenceOptionalRelationships = {
	.referencePois = @"referencePois",
	.referenceSection = @"referenceSection",
	.tags = @"tags",
};

const struct OPEManagedReferenceOptionalFetchedProperties OPEManagedReferenceOptionalFetchedProperties = {
};

@implementation OPEManagedReferenceOptionalID
@end

@implementation _OPEManagedReferenceOptional

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedReferenceOptional" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedReferenceOptional";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedReferenceOptional" inManagedObjectContext:moc_];
}

- (OPEManagedReferenceOptionalID*)objectID {
	return (OPEManagedReferenceOptionalID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	
	if ([key isEqualToString:@"sectionSortOrderValue"]) {
		NSSet *affectingKey = [NSSet setWithObject:@"sectionSortOrder"];
		keyPaths = [keyPaths setByAddingObjectsFromSet:affectingKey];
		return keyPaths;
	}

	return keyPaths;
}




@dynamic displayName;






@dynamic name;






@dynamic osmKey;






@dynamic sectionSortOrder;



- (int16_t)sectionSortOrderValue {
	NSNumber *result = [self sectionSortOrder];
	return [result shortValue];
}

- (void)setSectionSortOrderValue:(int16_t)value_ {
	[self setSectionSortOrder:[NSNumber numberWithShort:value_]];
}

- (int16_t)primitiveSectionSortOrderValue {
	NSNumber *result = [self primitiveSectionSortOrder];
	return [result shortValue];
}

- (void)setPrimitiveSectionSortOrderValue:(int16_t)value_ {
	[self setPrimitiveSectionSortOrder:[NSNumber numberWithShort:value_]];
}





@dynamic referencePois;

	
- (NSMutableSet*)referencePoisSet {
	[self willAccessValueForKey:@"referencePois"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"referencePois"];
  
	[self didAccessValueForKey:@"referencePois"];
	return result;
}
	

@dynamic referenceSection;

	

@dynamic tags;

	
- (NSMutableSet*)tagsSet {
	[self willAccessValueForKey:@"tags"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"tags"];
  
	[self didAccessValueForKey:@"tags"];
	return result;
}
	






@end
