// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmRelation.m instead.

#import "_OPEManagedOsmRelation.h"

const struct OPEManagedOsmRelationAttributes OPEManagedOsmRelationAttributes = {
};

const struct OPEManagedOsmRelationRelationships OPEManagedOsmRelationRelationships = {
	.members = @"members",
};

const struct OPEManagedOsmRelationFetchedProperties OPEManagedOsmRelationFetchedProperties = {
};

@implementation OPEManagedOsmRelationID
@end

@implementation _OPEManagedOsmRelation

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedOsmRelation" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedOsmRelation";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedOsmRelation" inManagedObjectContext:moc_];
}

- (OPEManagedOsmRelationID*)objectID {
	return (OPEManagedOsmRelationID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic members;

	
- (NSMutableOrderedSet*)membersSet {
	[self willAccessValueForKey:@"members"];
  
	NSMutableOrderedSet *result = (NSMutableOrderedSet*)[self mutableOrderedSetValueForKey:@"members"];
  
	[self didAccessValueForKey:@"members"];
	return result;
}
	






@end
