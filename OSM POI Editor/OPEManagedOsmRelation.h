#import "CoreLocation/CoreLocation.h"
#import "Relation.h"
#import "OPEManagedOsmElement.h"

@interface OPEManagedOsmRelation : OPEManagedOsmElement {}


@property (nonatomic,strong) Relation * element;

-(NSArray *)outerPolygons;
-(NSArray *)innerPolygons;
-(NSIndexSet *)outerPolygonsIndexes;

@end
