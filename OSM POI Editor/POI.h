//
//  POI.h
//  OSM POI Editor
//
//  Created by David on 12/18/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OPTIONAL, OSMTAG;

@interface POI : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * imageString;
@property (nonatomic, retain) NSNumber * isLegacy;
@property (nonatomic, retain) NSNumber * canAdd;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) NSSet *optional;
@property (nonatomic, retain) POI * newTagMethod;
@end

@interface POI (CoreDataGeneratedAccessors)

- (void)addTagsObject:(OSMTAG *)value;
- (void)removeTagsObject:(OSMTAG *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (void)addOptionalObject:(OPTIONAL *)value;
- (void)removeOptionalObject:(OPTIONAL *)value;
- (void)addOptional:(NSSet *)values;
- (void)removeOptional:(NSSet *)values;

- (void)addNewTagMethod:(POI *)value;
- (void)removeNewTagMethod:(POI *)value;
@end
