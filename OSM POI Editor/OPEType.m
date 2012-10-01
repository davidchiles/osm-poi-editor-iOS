//
//  OPEType.m
//  OSM POI Editor
//
//  Created by David on 8/24/12.
//
//

#import "OPEType.h"

@implementation OPEType

@synthesize displayName;
@synthesize imageString;
@synthesize tags;
@synthesize optionalTags;
@synthesize categoryName;

-(id)initWithName:(NSString *)name categoryName:(NSString *)catName dictionary:(NSDictionary *)dictionary
{
    self = [super init];
    if(self)
    {
        self.categoryName = catName;
        self.displayName = name;
        self.imageString = [dictionary objectForKey:@"image"];
        self.tags = [dictionary objectForKey:@"tags"];
        self.optionalTags = [dictionary objectForKey:@"optional"];
    }
    return self;
}

-(BOOL)isEqual:(OPEType *)otherType
{
    if ([self.categoryName isEqualToString:otherType.categoryName] && [self.displayName isEqualToString:otherType.displayName]) {
        return YES;
    }
    else
        return NO;
}

-(NSString *) description
{
    return [NSString stringWithFormat:@"Type: %@\nCategory: %@\nImage: %@Tags: %@",self.displayName,self.categoryName,self.imageString,self.tags];
}


@end
