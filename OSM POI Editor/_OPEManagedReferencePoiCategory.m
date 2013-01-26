// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferencePoiCategory.m instead.

#import "_OPEManagedReferencePoiCategory.h"

const struct OPEManagedReferencePoiCategoryAttributes OPEManagedReferencePoiCategoryAttributes = {
	.name = @"name",
};

const struct OPEManagedReferencePoiCategoryRelationships OPEManagedReferencePoiCategoryRelationships = {
	.referencePois = @"referencePois",
};

const struct OPEManagedReferencePoiCategoryFetchedProperties OPEManagedReferencePoiCategoryFetchedProperties = {
};

@implementation OPEManagedReferencePoiCategoryID
@end

@implementation _OPEManagedReferencePoiCategory

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedReferencePoiCategory" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedReferencePoiCategory";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedReferencePoiCategory" inManagedObjectContext:moc_];
}

- (OPEManagedReferencePoiCategoryID*)objectID {
	return (OPEManagedReferencePoiCategoryID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic referencePois;

	
- (NSMutableSet*)referencePoisSet {
	[self willAccessValueForKey:@"referencePois"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"referencePois"];
  
	[self didAccessValueForKey:@"referencePois"];
	return result;
}
	






@end
