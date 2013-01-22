//
//  OPECoreDataImporter.h
//  OSM POI Editor
//
//  Created by David on 12/18/12.
//
//

#import <Foundation/Foundation.h>
#import "OSMTAG.h"
#import "OPTIONAL.h"
#import "POI.h"

@interface OPECoreDataImporter : NSObject

@property (nonatomic, strong) NSManagedObjectContext *managedObjectContext;

-(void)importTagsPlist;
-(void)importOptionalTags;
-(void)addPOIWithName:(NSString *)name category:(NSString *)category imageString:(NSString *)imageString legacy:(BOOL )isLegacy optional:(NSArray *)optionalTags tags:(NSDictionary *) tags;
-(OPTIONAL *)addOptionalWithName:(NSString *)name displayName:(NSString *)displayName section:(NSString *)section sectionSortOrder:(NSNumber *)sectionSortOrder osmkey:(NSString *)osmKey values:(NSDictionary *)tagValues;
-(OSMTAG *)osmKey:(NSString *)key value:(NSString *)value name:(NSString *)name;

@end
