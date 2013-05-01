#import "CoreLocation/CoreLocation.h"
#import "OPEManagedOsmElement.h"
#import "Node.h"

@interface OPEManagedOsmNode : OPEManagedOsmElement {}
@property (nonatomic,strong) Node * element;

+(OPEManagedOsmNode *)newNode;


@end
