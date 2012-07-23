//
//  OPEWay.m
//  OSM POI Editor
//
//  Created by David Chiles on 7/6/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEWay.h"
#import "OPEConstants.h"

@implementation OPEWay

@synthesize nodes,ident,tags,coordinate,version,image;

-(id)init
{
    self = [super init];
    
    return self;
}

-(id)initWithArrayOfNodes:(NSArray *)arrayOfNodes tags:(NSMutableDictionary *)tagDictioanry ID:(int)i version:(int)version
{
    self = [self init];
    nodes = arrayOfNodes;
    [self setLattitudeandLongitude];
    
    self.ident = i;
    self.tags = tagDictioanry;
    
    
    return self;
}

-(id)initWithArrayOfNodes:(NSArray *)arrayOfNodes ID:(int)i version:(int)version
{
    self = [self init];
    nodes = arrayOfNodes;
    [self setLattitudeandLongitude];
    self.ident = i;
    self.tags = [NSMutableDictionary dictionary];
    
    return self;
}

+ (id)createPointWithXML:(TBXMLElement *)xml nodes:(NSDictionary *)nodes
{
    NSMutableArray * nodeArray = [[NSMutableArray alloc] init];
    
    NSString * identString = [TBXML valueOfAttributeNamed:@"id" forElement:xml];
    NSString * versionString = [TBXML valueOfAttributeNamed:@"version" forElement:xml];
    int ident = [identString intValue];
    int version = [versionString intValue];
    
    TBXMLElement* nodeXml = [TBXML childElementNamed:@"nd" parentElement:xml];
    
    while (nodeXml!=nil) {
        NSString * nodeIdentString = [TBXML valueOfAttributeNamed:@"ref" forElement:nodeXml];
        [nodeArray addObject: [nodes objectForKey:[OPENode uniqueIdentifierForID:[nodeIdentString intValue]]]];
        
        nodeXml = [TBXML nextSiblingNamed:@"nd" searchFromElement:nodeXml];
    }
    
     OPEWay * newWay = [[OPEWay alloc] initWithArrayOfNodes:nodeArray ID:ident version:version];
    
    TBXMLElement* tagXml = [TBXML childElementNamed:@"tag" parentElement:xml];
    while (tagXml!=nil) {
        NSString* key = [TBXML valueOfAttributeNamed:@"k" forElement:tagXml];
        NSString* value = [TBXML valueOfAttributeNamed:@"v" forElement:tagXml];
        //NSLog(@"key: %@, value: %@",key,value);
        [newWay addKey:key value:value];
        tagXml = [TBXML nextSiblingNamed:@"tag" searchFromElement:tagXml];
    }
    
    return newWay;
}

-(void)setLattitudeandLongitude 
{
    if(nodes)
    {
        double centerLat=0.0;
        double centerLon=0.0;
        for(OPENode * node in nodes)
        {
            centerLat += node.coordinate.latitude;
            centerLon += node.coordinate.longitude;
        }
        self.coordinate = CLLocationCoordinate2DMake(centerLat/[nodes count], centerLon/[nodes count]);
    }
}

-(NSString *)exportXMLforChangset:(NSInteger)changesetNumber
{
    NSMutableString * xml = [NSString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [xml appendString:[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"]];
    [xml appendFormat:@"<way id=\"%d\" version=\"%d\" changeset=\"%d\">",self.ident,self.version, changesetNumber];
    
    for(OPENode * node in nodes)
    {
        [xml appendFormat:@"<nd ref=\"%@\"/>",node.ident];
    }
    
    for(NSString * key in self.tags)
    {
        [xml appendFormat:@"<tag k=\"%@\" v=\"%@\"/>",key,[self.tags objectForKey:key]];
    }
    [xml appendFormat: @"</way> @</osm>"];
    
    return xml;

}

-(NSString *)type
{
    return kPointTypeWay;
}

-(NSString *)uniqueIdentifier
{
   return [NSString stringWithFormat:@"%@%d",[self type],self.ident];
}

+(NSString *)uniqueIdentifierForID:(int)ident
{
    return [NSString stringWithFormat:@"%@%d",kPointTypeWay,ident];
}


@end
