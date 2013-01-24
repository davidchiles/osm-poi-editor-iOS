#import "OPEManagedOsmNode.h"


@interface OPEManagedOsmNode ()

// Private interface goes here.

@end


@implementation OPEManagedOsmNode

-(CLLocationCoordinate2D) center
{
    return CLLocationCoordinate2DMake([self.lattitude doubleValue], [self.longitude doubleValue]);
}

+(OPEManagedOsmNode *)fetchNodeWithOsmId:(NSInteger)nodeId
{
    NSPredicate *osmNodeFilter = [NSPredicate predicateWithFormat:@"osmID == %d",nodeId];
    
    NSArray * results = [OPEManagedOsmNode MR_findAllWithPredicate:osmNodeFilter];
    
    OPEManagedOsmNode * osmNode = nil;
    
    if([results count])
    {
        osmNode = [results objectAtIndex:0];
    }
    
    return osmNode;
}

@end
