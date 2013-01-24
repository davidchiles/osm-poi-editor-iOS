#import "_OPEManagedOsmElement.h"
#import "CoreLocation/CoreLocation.h"

@interface OPEManagedOsmElement : _OPEManagedOsmElement {}

-(CLLocationCoordinate2D) center;
-(BOOL) findType;

@end
