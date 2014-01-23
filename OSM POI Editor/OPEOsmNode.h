#import "CoreLocation/CoreLocation.h"
#import "OPEOsmElement.h"
#import "Node.h"

@interface OPEOsmNode : OPEOsmElement {}
@property (nonatomic,strong) Node * element;

+(OPEOsmNode *)newNode;


@end
