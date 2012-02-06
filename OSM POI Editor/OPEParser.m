//
//  OPEParser.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/3/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEParser.h"

@implementation OPEParser


-(id) init {
    if(self == [super init]) {
        double bboxleft = -122.26341;
        double bboxbottom = 37.86981;
        double bboxright = -122.25421;
        double bboxtop = 37.87533;
        parser = [[NSXMLParser alloc]
                  initWithContentsOfURL:[NSURL URLWithString: [NSString stringWithFormat:@"http://www.overpass-api.de/api/xapi?node[bbox=%d,%d,%d,%d]",bboxleft,bboxbottom,bboxright,bboxtop]]];
        [parser setDelegate:self];
        [parser parse];
    }      
    return self;
}

- (void)parser:(NSXMLParser*)parser didStartElement:(NSString *)elementName namespaceURI:(NSString*)namespaceURI qualifiedName:(NSString *)qualifiedName attributes:(NSDictionary*)attributeDict
{
    NSLog(@"Started Element %@", elementName);
    element = [NSMutableString string];
}

- (void)parser:(NSXMLParser*)parser didEndElement:(NSString *)elementName namespaceURI: (NSString *)namespaceURI qualifiedName:(NSString *)qName
{
    NSLog(@"Found an element named: %@ with a value of: %@", elementName, element);
}

- (void)parser:(NSXMLParser*)parser foundCharacters:(NSString *)string
{
    if(element == nil)
        element = [[NSMutableString alloc] init];
    [element appendString:string];
}
          
          
@end
