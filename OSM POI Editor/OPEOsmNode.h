#import "CoreLocation/CoreLocation.h"
#import "OPEOsmElement.h"
#import "OSMNode.h"

@interface OPEOsmNode : OPEOsmElement {}
@property (nonatomic,strong) OSMNode * element;

+(OPEOsmNode *)newNode;


@end
