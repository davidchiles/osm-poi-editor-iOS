#import "CoreLocation/CoreLocation.h"
#import "Way.h"
#import "OPEManagedOsmElement.h"

@interface OPEManagedOsmWay : OPEManagedOsmElement{}
// Custom logic goes here.

@property (nonatomic,strong) Way * element;
@property (nonatomic) BOOL isNoNameStreet;

-(NSString *)highwayType;

@end
