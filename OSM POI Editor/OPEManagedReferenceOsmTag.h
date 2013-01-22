//
//  OPEManagedReferenceOsmTag.h
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OPEManagedOsmTag;

@interface OPEManagedReferenceOsmTag : NSManagedObject

@property (nonatomic, retain) NSString * name;
@property (nonatomic, retain) OPEManagedOsmTag *tag;

@end
