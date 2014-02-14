#import "CoreLocation/CoreLocation.h"
#import "OSMWay.h"
#import "OPEOsmElement.h"

@interface OPEOsmWay : OPEOsmElement{}
// Custom logic goes here.

@property (nonatomic,strong) OSMWay * element;
@property (nonatomic) BOOL isNoNameStreet;
@property (nonatomic,strong) NSArray * points;

@end
