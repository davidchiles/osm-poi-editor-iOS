#import "_OPEManagedOsmNode.h"
#import "CoreLocation/CoreLocation.h"

@interface OPEManagedOsmNode : _OPEManagedOsmNode {}

+(OPEManagedOsmNode *)fetchNodeWithOsmId:(NSInteger)nodeId;
@end
