#import "_OPEManagedOsmNode.h"
#import "CoreLocation/CoreLocation.h"

@interface OPEManagedOsmNode : _OPEManagedOsmNode {}


- (NSData *) createXMLforChangset: (int64_t) changesetNumber;
- (NSData *) deleteXMLforChangset: (int64_t) changesetNumber;


+(OPEManagedOsmNode *)fetchOrCreateNodeWithOsmID:(int64_t)nodeId;
+(OPEManagedOsmNode *)newNode;

@end
