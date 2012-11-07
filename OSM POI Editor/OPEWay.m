//
//  OPEWay.m
//  OSM POI Editor
//
//  Created by David Chiles on 7/6/12.
//  Copyright (c) 2011 David Chiles. All rights reserved.
//
//  This file is part of POI+.
//
//  POI+ is free software: you can redistribute it and/or modify
//  it under the terms of the GNU General Public License as published by
//  the Free Software Foundation, either version 3 of the License, or
//  (at your option) any later version.
//
//  POI+ is distributed in the hope that it will be useful,
//  but WITHOUT ANY WARRANTY; without even the implied warranty of
//  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
//  GNU General Public License for more details.
//
//  You should have received a copy of the GNU General Public License
//  along with POI+.  If not, see <http://www.gnu.org/licenses/>.

#import "OPEWay.h"
#import "OPEConstants.h"

@implementation OPEWay

@synthesize nodes;

-(id)init
{
    self = [super init];
    
    return self;
}

-(id)initWithArrayOfNodes:(NSArray *)arrayOfNodes tags:(NSMutableDictionary *)tagDictioanry ID:(int)i version:(int) newVersion
{
    self = [self init];
    nodes = arrayOfNodes;
    [self setLattitudeandLongitude];
    
    self.ident = i;
    self.tags = tagDictioanry;
    self.version = newVersion;
    
    return self;
}

-(id)initWithArrayOfNodes:(NSArray *)arrayOfNodes ID:(int)i version:(int)newVersion
{
    self = [self init];
    nodes = arrayOfNodes;
    [self setLattitudeandLongitude];
    self.ident = i;
    self.tags = [NSMutableDictionary dictionary];
    self.version = newVersion;
    
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

- (NSData * )XMLrepresentation:(NSInteger) changesetNumber;
{
    NSMutableString * xml = [NSMutableString stringWithFormat: @"<?xml version=\"1.0\" encoding=\"UTF-8\" ?>"];
    [xml appendString:[NSString stringWithFormat: @"<osm version=\"0.6\" generator=\"OSMPOIEditor\">"]];
    [xml appendFormat:@"<way id=\"%d\" version=\"%d\" changeset=\"%d\">",self.ident,self.version, changesetNumber];
    
    for(OPENode * node in nodes)
    {
        [xml appendFormat:@"<nd ref=\"%d\"/>",node.ident];
    }
    
    for(NSString * key in self.tags)
    {
        [xml appendFormat:@"<tag k=\"%@\" v=\"%@\"/>",key,[self.tags objectForKey:key]];
    }
    [xml appendFormat: @"</way> @</osm>"];
    
    return [xml dataUsingEncoding:NSUTF8StringEncoding];
    
}

- (NSData *) updateXMLforChangset: (NSInteger) changesetNumber;
{
    return  [self XMLrepresentation:changesetNumber];

}

-(BOOL)isequaltToPoint:(OPEPoint*)point
{
    if ([[self type] isEqualToString:[point type]])
        return NO;
    else if(self.ident != point.ident)
        return NO;
    else if (self.coordinate.latitude != point.coordinate.latitude)
        return NO;
    else if (self.coordinate.longitude != point.coordinate.longitude)
        return NO;
    else if (![self.tags isEqualToDictionary:point.tags])
        return NO;
    
    return YES;
    
}

-(NSString *)type
{
    return kPointTypeWay;
}

-(id)copy
{
    OPEWay * wayCopy = [[OPEWay alloc] init];
    wayCopy.coordinate = self.coordinate;
    wayCopy.ident = self.ident;
    wayCopy.tags = [self.tags mutableCopy];
    wayCopy.version = self.version;
    wayCopy.image = [self.image mutableCopy];
    wayCopy.nodes = [self.nodes copy];
    
    
    return wayCopy;
}

-(void)prepareToDelete:(NSArray *)keys
{
    NSMutableSet * tempSet = [NSMutableSet setWithArray:keys];
    [tempSet minusSet:[NSSet setWithObjects:@"addr:housenumber",@"addr:street",@"addr:city",@"addr:postcode",@"addr:state",@"addr:country", @"addr:province",nil]];
    [self.tags removeObjectsForKeys:[tempSet allObjects]];
    
}

+ (NSString *)uniqueIdentifierForID:(int)ident
{
    return [NSString stringWithFormat:@"%@%d",kPointTypeWay,ident];
}





@end
