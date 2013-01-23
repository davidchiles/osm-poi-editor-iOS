//
//  OPEManagedOsmTag.h
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OPEManagedOsmTag : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * value;

+(OPEManagedOsmTag *)fetchOrCreateWithKey:(NSString *)key value:(NSString *)value;

@end
