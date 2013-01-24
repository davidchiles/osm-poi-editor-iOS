// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmTag.m instead.

#import "_OPEManagedOsmTag.h"

const struct OPEManagedOsmTagAttributes OPEManagedOsmTagAttributes = {
	.key = @"key",
	.value = @"value",
};

const struct OPEManagedOsmTagRelationships OPEManagedOsmTagRelationships = {
	.osmElements = @"osmElements",
	.referenceOsmTag = @"referenceOsmTag",
	.referencePois = @"referencePois",
};

const struct OPEManagedOsmTagFetchedProperties OPEManagedOsmTagFetchedProperties = {
};

@implementation OPEManagedOsmTagID
@end

@implementation _OPEManagedOsmTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedOsmTag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedOsmTag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedOsmTag" inManagedObjectContext:moc_];
}

- (OPEManagedOsmTagID*)objectID {
	return (OPEManagedOsmTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic key;






@dynamic value;






@dynamic osmElements;

	
- (NSMutableSet*)osmElementsSet {
	[self willAccessValueForKey:@"osmElements"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"osmElements"];
  
	[self didAccessValueForKey:@"osmElements"];
	return result;
}
	

@dynamic referenceOsmTag;

	
- (NSMutableSet*)referenceOsmTagSet {
	[self willAccessValueForKey:@"referenceOsmTag"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"referenceOsmTag"];
  
	[self didAccessValueForKey:@"referenceOsmTag"];
	return result;
}
	

@dynamic referencePois;

	
- (NSMutableSet*)referencePoisSet {
	[self willAccessValueForKey:@"referencePois"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"referencePois"];
  
	[self didAccessValueForKey:@"referencePois"];
	return result;
}
	






@end
