//
//  OPEChangeset.m
//  OSM POI Editor
//
//  Created by David on 3/13/13.
//
//

#import "OPEChangeset.h"
#import "OPEOsmNode.h"
#import "OPEOsmWay.h"
#import "OPEOsmRelation.h"

@implementation OPEChangeset

@synthesize nodes,ways,relations,changesetID,message,tags;

-(id)init
{
    if(self = [super init])
    {
        tags = [NSMutableDictionary dictionary];
        self.nodes = [NSMutableArray array];
        self.ways = [NSMutableArray array];
        self.relations = [NSMutableArray array];
    }
    return self;
}

-(void)addElement:(OPEOsmElement *)element
{
    if ([element isKindOfClass:[OPEOsmNode class]]) {
        [self.nodes addObject:element];
    }
    else if ([element isKindOfClass:[OPEOsmWay class]])
    {
        [self.ways addObject:element];
    }
    else if ([element isKindOfClass:[OPEOsmRelation class]])
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


-(NSString *)xml
{
    NSMutableString * changesetString = [[NSMutableString alloc] init];
    
    [changesetString appendString:@"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [changesetString appendString:@"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"];
    [changesetString appendString:@"<changeset>"];
    
    for (NSString * key in tags)
    {
        [changesetString appendFormat:@"<tag k=\"%@\" v=\"%@\"/>",key, tags[key]];
    }
    [changesetString appendString:@"</changeset>"];
    [changesetString appendString:@"</osm>"];
    
    return changesetString;
}

@end
