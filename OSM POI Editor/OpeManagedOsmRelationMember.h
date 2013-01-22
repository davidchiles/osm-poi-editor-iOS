//
//  OpeManagedOsmRelationMember.h
//  OSM POI Editor
//
//  Created by David on 1/22/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class OPEManagedOsmElement;

@interface OpeManagedOsmRelationMember : NSManagedObject

@property (nonatomic, retain) NSString * role;
@property (nonatomic, retain) OPEManagedOsmElement *member;

@end
