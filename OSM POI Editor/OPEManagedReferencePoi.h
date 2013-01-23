//
//  OPEManagedReferencePoi.h
//  OSM POI Editor
//
//  Created by David on 1/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OPEManagedOsmTag, OPEManagedReferenceOptional, OPEManagedReferencePoi;

@interface OPEManagedReferencePoi : NSManagedObject

@property (nonatomic, retain) NSNumber * canAdd;
@property (nonatomic, retain) NSString * category;
@property (nonatomic, retain) NSString * imageString;
@property (nonatomic, retain) NSNumber * isLegacy;
@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) OPEManagedReferencePoi *newTagMethod;
@property (nonatomic, retain) NSSet *optional;
@property (nonatomic, retain) NSSet *tags;
@end

@interface OPEManagedReferencePoi (CoreDataGeneratedAccessors)

- (void)addOptionalObject:(OPEManagedReferenceOptional *)value;
- (void)removeOptionalObject:(OPEManagedReferenceOptional *)value;
- (void)addOptional:(NSSet *)values;
- (void)removeOptional:(NSSet *)values;

- (void)addTagsObject:(OPEManagedOsmTag *)value;
- (void)removeTagsObject:(OPEManagedOsmTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;


+(OPEManagedReferencePoi *) fetchOrCreateWithName:(NSString *)name category:(NSString *)category didCreate:(BOOL *)didCreate;

@end
