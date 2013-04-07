// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmNodeReference.m instead.

#import "_OPEManagedOsmNodeReference.h"

const struct OPEManagedOsmNodeReferenceAttributes OPEManagedOsmNodeReferenceAttributes = {
};

const struct OPEManagedOsmNodeReferenceRelationships OPEManagedOsmNodeReferenceRelationships = {
	.node = @"node",
	.way = @"way",
};

const struct OPEManagedOsmNodeReferenceFetchedProperties OPEManagedOsmNodeReferenceFetchedProperties = {
};

@implementation OPEManagedOsmNodeReferenceID
@end

@implementation _OPEManagedOsmNodeReference

+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription insertNewObjectForEntityForName:@"OPEManagedOsmNodeReference" inManagedObjectContext:moc_];
}

+ (NSString*)entityName {
	return @"OPEManagedOsmNodeReference";
}

+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_ {
	NSParameterAssert(moc_);
	return [NSEntityDescription entityForName:@"OPEManagedOsmNodeReference" inManagedObjectContext:moc_];
}

- (OPEManagedOsmNodeReferenceID*)objectID {
	return (OPEManagedOsmNodeReferenceID*)[super objectID];
}

+ (NSSet*)keyPathsForValuesAffectingValueForKey:(NSString*)key {
	NSSet *keyPaths = [super keyPathsForValuesAffectingValueForKey:key];
	

	return keyPaths;
}




@dynamic node;

	

@dynamic way;

	






@end
