// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OpeManagedOsmRelationMember.m instead.

#import "_OpeManagedOsmRelationMember.h"

const struct OpeManagedOsmRelationMemberAttributes OpeManagedOsmRelationMemberAttributes = {
	.role = @"role",
};

const struct OpeManagedOsmRelationMemberRelationships OpeManagedOsmRelationMemberRelationships = {
	.member = @"member",
	.osmRelation = @"osmRelation",
};

const struct OpeManagedOsmRelationMemberFetchedProperties OpeManagedOsmRelationMemberFetchedProperties = {
};

@implementation OpeManagedOsmRelationMemberID
@end

@implementation _OpeManagedOsmRelationMember

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OpeManagedOsmRelationMember" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OpeManagedOsmRelationMember";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OpeManagedOsmRelationMember" inManagedObjectContext:moc_];
}

- (OpeManagedOsmRelationMemberID*)objectID {
	return (OpeManagedOsmRelationMemberID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic role;






@dynamic member;

	

@dynamic osmRelation;

	






@end
