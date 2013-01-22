//
//  OPTIONAL.h
//  OSM POI Editor
//
//  Created by David on 12/18/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OSMTAG;

@interface OPTIONAL : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * displayName;
@property (nonatomic, retain) NSString * section;
@property (nonatomic, retain) NSNumber * sectionSortOrder;
@property (nonatomic, retain) NSSet *tags;
@end

@interface OPTIONAL (CoreDataGeneratedAccessors)

- (void)addTagsObject:(OSMTAG *)value;
- (void)removeTagsObject:(OSMTAG *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

@end
