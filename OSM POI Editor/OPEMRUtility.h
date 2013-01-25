//
//  OPEMRUtility.h
//  OSM POI Editor
//
//  Created by David on 1/23/13.
//
//

#import <Foundation/Foundation.h>

@interface OPEMRUtility : NSObject

+(void)deleteDownloaded;
+(void)saveAll;
+(NSManagedObject *)managedObjectWithID:(NSManagedObjectID *)managedObjectID;
@end
