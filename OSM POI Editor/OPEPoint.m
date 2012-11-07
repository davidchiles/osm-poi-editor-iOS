//
//  oPoint.m
//  OSM POI Editor
//
//  Created by David on 11/7/12.
//
//

#import "OPEPoint.h"
#import "OPEConstants.h"
#import "OPETagInterpreter.h"

@implementation OPEPoint

@synthesize coordinate;
@synthesize tags;
@synthesize version;
@synthesize image;
@synthesize ident;
@synthesize name;

- (void) addKey: (NSString *) key value: (NSString *)value
{
    if (!self.tags) {
        self.tags = [[NSMutableDictionary alloc] init];
    }
    
    [self.tags setValue:value forKey:key];
}
-(NSString *)name
{
    if(tags)
    {
        NSString* tagName = [tags objectForKey:@"name"];
        if(tagName)
            return tagName;
        else
            return [[OPETagInterpreter sharedInstance] getName:self];
    }
    else
        return @"no name";
}

- (BOOL) isequaltToPoint:(OPEPoint*)point
{
    if(self.ident != point.ident)
        return NO;
    else if (self.coordinate.latitude != point.coordinate.latitude)
        return NO;
    else if (self.coordinate.longitude != point.coordinate.longitude)
        return NO;
    else if (![self.tags isEqualToDictionary:point.tags])
        return NO;
    
    return YES;
}
- (NSString *)type
{
    return kPointTypePoint;
}
-(NSString *)description{
    return [NSString stringWithFormat:@"%@: %@",[self uniqueIdentifier],self.tags];
}
- (NSString *)uniqueIdentifier
{
    return [NSString stringWithFormat:@"%@%d",[self type],self.ident];
}
-(BOOL)hasNoTags
{
    if(![self.tags count])
    {
        return YES;
    }
    return NO;
}
-(id)copy
{
    OPEPoint * nodeCopy = [[OPEPoint alloc] init];
    nodeCopy.coordinate = self.coordinate;
    nodeCopy.ident = self.ident;
    nodeCopy.tags = [self.tags mutableCopy];
    nodeCopy.version = self.version;
    nodeCopy.image = [self.image mutableCopy];
    
    return nodeCopy;
}
- (NSData *) updateXMLforChangset: (NSInteger) changesetNumber
{
    @throw [NSException exceptionWithName:@"OPEPointMethodInvocation"
                                   reason:@"updateXMLforChangset: invoked on OPEPoint. Override this method when instantiating an abstract class."
                                 userInfo:nil];
}
- (NSData *) createXMLforChangset: (NSInteger) changesetNumber
{
    @throw [NSException exceptionWithName:@"OPEPointMethodInvocation"
                                   reason:@"createXMLforChangset: invoked on OPEPoint. Override this method when instantiating an abstract class."
                                 userInfo:nil];
}
- (NSData *) deleteXMLforChangset: (NSInteger) changesetNumber
{
    @throw [NSException exceptionWithName:@"OPEPointMethodInvocation"
                                   reason:@"deleteXMLforChangset: invoked on OPEPoint. Override this method when instantiating an abstract class."
                                 userInfo:nil];
}

+ (NSString *)uniqueIdentifierForID:(int)ident
{
    return [NSString stringWithFormat:@"%@%d",kPointTypePoint,ident];
}


@end
