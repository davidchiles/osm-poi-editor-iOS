#import "_OPEManagedOsmNode.h"
#import "CoreLocation/CoreLocation.h"

@interface OPEManagedOsmNode : _OPEManagedOsmNode {}

+(OPEManagedOsmNode *)fetchOrCreateNodeWithOsmID:(int64_t)nodeId;
+(OPEManagedOsmNode *)newNode;

@end
