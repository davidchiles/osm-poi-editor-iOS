//
//  OPEManagedReferenceOptional.h
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OPEManagedReferenceOsmTag;

@interface OPEManagedReferenceOptional : NSManagedObject

@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSNumber * sectionSortOrder;
@property (nonatomic, retain) NSSet *tags;
@end

@interface OPEManagedReferenceOptional (CoreDataGeneratedAccessors)

- (void)addTagsObject:(OPEManagedReferenceOsmTag *)value;
- (void)removeTagsObject:(OPEManagedReferenceOsmTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
