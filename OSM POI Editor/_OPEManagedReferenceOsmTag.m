// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedReferenceOsmTag.m instead.

#import "_OPEManagedReferenceOsmTag.h"

const struct OPEManagedReferenceOsmTagAttributes OPEManagedReferenceOsmTagAttributes = {
	.name = @"name",
};

const struct OPEManagedReferenceOsmTagRelationships OPEManagedReferenceOsmTagRelationships = {
	.referenceOptionals = @"referenceOptionals",
	.tag = @"tag",
};

const struct OPEManagedReferenceOsmTagFetchedProperties OPEManagedReferenceOsmTagFetchedProperties = {
};

@implementation OPEManagedReferenceOsmTagID
@end

@implementation _OPEManagedReferenceOsmTag

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedReferenceOsmTag" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedReferenceOsmTag";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedReferenceOsmTag" inManagedObjectContext:moc_];
}

- (OPEManagedReferenceOsmTagID*)objectID {
	return (OPEManagedReferenceOsmTagID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic name;






@dynamic referenceOptionals;

	
- (NSMutableSet*)referenceOptionalsSet {
	[self willAccessValueForKey:@"referenceOptionals"];
  
	NSMutableSet *result = (NSMutableSet*)[self mutableSetValueForKey:@"referenceOptionals"];
  
	[self didAccessValueForKey:@"referenceOptionals"];
	return result;
}
	

@dynamic tag;

	






@end
