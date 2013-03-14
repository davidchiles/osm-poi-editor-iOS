//
//  OPEChangeset.m
//  OSM POI Editor
//
//  Created by David on 3/13/13.
//
//

#import "OPEChangeset.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmRelation.h"

@implementation OPEChangeset

@synthesize nodes,ways,relations,changesetID,message;

-(id)init
{
    if(self = [super init])
    {
        self.nodes = [NSMutableArray array];
        self.ways = [NSMutableArray array];
        self.relations = [NSMutableArray array];
    }
    return self;
}

-(void)addElement:(OPEManagedOsmElement *)element
{
    if ([element isKindOfClass:[OPEManagedOsmNode class]]) {
        [self.nodes addObject:element];
    }
    else if ([element isKindOfClass:[OPEManagedOsmWay class]])
    {
        [self.ways addObject:element];
    }
    else if ([element isKindOfClass:[OPEManagedOsmRelation class]])
    {
        [self.relations addObject:element];
    }
}


-(BOOL)hasNodes
{
    return [self.nodes count];
}
-(BOOL)hasWays
{
    return [self.nodes count];
}
-(BOOL)hasRelations
{
    return [self.nodes count];
}
@end
