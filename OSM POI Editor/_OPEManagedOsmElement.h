// DO NOT EDIT. This file is machine-generated and constantly overwritten.
// Make changes to OPEManagedOsmElement.h instead.

#import <CoreData/CoreData.h>


extern const struct OPEManagedOsmElementAttributes {
	__unsafe_unretained NSString *action;
	__unsafe_unretained NSString *changesetID;
	__unsafe_unretained NSString *isVisible;
	__unsafe_unretained NSString *osmID;
	__unsafe_unretained NSString *timestamp;
	__unsafe_unretained NSString *user;
	__unsafe_unretained NSString *userID;
	__unsafe_unretained NSString *version;
} OPEManagedOsmElementAttributes;

extern const struct OPEManagedOsmElementRelationships {
	__unsafe_unretained NSString *parentRelations;
	__unsafe_unretained NSString *tags;
	__unsafe_unretained NSString *type;
} OPEManagedOsmElementRelationships;

extern const struct OPEManagedOsmElementFetchedProperties {
} OPEManagedOsmElementFetchedProperties;

@class OpeManagedOsmRelationMember;
@class OPEManagedOsmTag;
@class OPEManagedReferencePoi;










@interface OPEManagedOsmElementID : NSManagedObjectID {}
@end

@interface _OPEManagedOsmElement : NSManagedObject {}
+ (id)insertInManagedObjectContext:(NSManagedObjectContext*)moc_;
+ (NSString*)entityName;
+ (NSEntityDescription*)entityInManagedObjectContext:(NSManagedObjectContext*)moc_;
- (OPEManagedOsmElementID*)objectID;





@property (nonatomic, strong) NSString* action;



//- (BOOL)validateAction:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* changesetID;



@property int64_t changesetIDValue;
- (int64_t)changesetIDValue;
- (void)setChangesetIDValue:(int64_t)value_;

//- (BOOL)validateChangesetID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* isVisible;



@property BOOL isVisibleValue;
- (BOOL)isVisibleValue;
- (void)setIsVisibleValue:(BOOL)value_;

//- (BOOL)validateIsVisible:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* osmID;



@property int64_t osmIDValue;
- (int64_t)osmIDValue;
- (void)setOsmIDValue:(int64_t)value_;

//- (BOOL)validateOsmID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSDate* timestamp;



//- (BOOL)validateTimestamp:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSString* user;



//- (BOOL)validateUser:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* userID;



@property int64_t userIDValue;
- (int64_t)userIDValue;
- (void)setUserIDValue:(int64_t)value_;

//- (BOOL)validateUserID:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSNumber* version;



@property int64_t versionValue;
- (int64_t)versionValue;
- (void)setVersionValue:(int64_t)value_;

//- (BOOL)validateVersion:(id*)value_ error:(NSError**)error_;





@property (nonatomic, strong) NSSet *parentRelations;

- (NSMutableSet*)parentRelationsSet;




@property (nonatomic, strong) NSSet *tags;

- (NSMutableSet*)tagsSet;




@property (nonatomic, strong) OPEManagedReferencePoi *type;

//- (BOOL)validateType:(id*)value_ error:(NSError**)error_;





@end

@interface _OPEManagedOsmElement (CoreDataGeneratedAccessors)

- (void)addParentRelations:(NSSet*)value_;
- (void)removeParentRelations:(NSSet*)value_;
- (void)addParentRelationsObject:(OpeManagedOsmRelationMember*)value_;
- (void)removeParentRelationsObject:(OpeManagedOsmRelationMember*)value_;

- (void)addTags:(NSSet*)value_;
- (void)removeTags:(NSSet*)value_;
- (void)addTagsObject:(OPEManagedOsmTag*)value_;
- (void)removeTagsObject:(OPEManagedOsmTag*)value_;

@end

@interface _OPEManagedOsmElement (CoreDataGeneratedPrimitiveAccessors)


- (NSString*)primitiveAction;
- (void)setPrimitiveAction:(NSString*)value;




- (NSNumber*)primitiveChangesetID;
- (void)setPrimitiveChangesetID:(NSNumber*)value;

- (int64_t)primitiveChangesetIDValue;
- (void)setPrimitiveChangesetIDValue:(int64_t)value_;




- (NSNumber*)primitiveIsVisible;
- (void)setPrimitiveIsVisible:(NSNumber*)value;

- (BOOL)primitiveIsVisibleValue;
- (void)setPrimitiveIsVisibleValue:(BOOL)value_;




- (NSNumber*)primitiveOsmID;
- (void)setPrimitiveOsmID:(NSNumber*)value;

- (int64_t)primitiveOsmIDValue;
- (void)setPrimitiveOsmIDValue:(int64_t)value_;




- (NSDate*)primitiveTimestamp;
- (void)setPrimitiveTimestamp:(NSDate*)value;




- (NSString*)primitiveUser;
- (void)setPrimitiveUser:(NSString*)value;




- (NSNumber*)primitiveUserID;
- (void)setPrimitiveUserID:(NSNumber*)value;

- (int64_t)primitiveUserIDValue;
- (void)setPrimitiveUserIDValue:(int64_t)value_;




- (NSNumber*)primitiveVersion;
- (void)setPrimitiveVersion:(NSNumber*)value;

- (int64_t)primitiveVersionValue;
- (void)setPrimitiveVersionValue:(int64_t)value_;





- (NSMutableSet*)primitiveParentRelations;
- (void)setPrimitiveParentRelations:(NSMutableSet*)value;



- (NSMutableSet*)primitiveTags;
- (void)setPrimitiveTags:(NSMutableSet*)value;



- (OPEManagedReferencePoi*)primitiveType;
- (void)setPrimitiveType:(OPEManagedReferencePoi*)value;


@end
