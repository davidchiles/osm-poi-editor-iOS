#import "_OPEManagedOsmRelation.h"
#import "CoreLocation/CoreLocation.h"

@interface OPEManagedOsmRelation : _OPEManagedOsmRelation {}

-(void)addInOrderElement:(OPEManagedOsmElement *)element withRole:(NSString *)role;

-(NSArray *)outerPolygons;
-(NSArray *)innerPolygons;
-(NSIndexSet *)outerPolygonsIndexes;

@end
