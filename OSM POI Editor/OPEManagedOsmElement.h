//
//  OPEManagedOsmElement.h
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>
#import "CoreLocation/CoreLocation.h"

@class OPEManagedOsmTag, POI;

@interface OPEManagedOsmElement : NSManagedObject

@property (nonatomic, retain) NSNumber * osmID;
@property (nonatomic, retain) NSNumber * version;
@property (nonatomic, retain) NSSet *tags;
@property (nonatomic, retain) POI *type;
@end

@interface OPEManagedOsmElement (CoreDataGeneratedAccessors)

- (void)addTagsObject:(OPEManagedOsmTag *)value;
- (void)removeTagsObject:(OPEManagedOsmTag *)value;
- (void)addTags:(NSSet *)values;
- (void)removeTags:(NSSet *)values;

- (CLLocationCoordinate2D)center;

@end
