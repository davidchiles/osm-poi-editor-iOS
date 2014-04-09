//
//  OPEOSMUser.m
//  OSM POI Editor
//
//  Created by David Chiles on 3/26/14.
//
//

#import "OPEOSMUser.h"

static NSString *OPECurrentUserKey = @"OPECurrentUserKey";

static NSString *OPEDisplayNameKey = @"OPEDisplayNameKey";
static NSString *OPEUserIdKey = @"OPEUserIdKey";

@interface OPEOSMUser () <NSXMLParserDelegate>

@end

@implementation OPEOSMUser

- (instancetype)initWithParser:(NSXMLParser *)parser
{
    if (self = [self init]) {
        parser.delegate = self;
        [parser parse];
    }
    return self;
}

- (instancetype)initWithDictionary:(NSDictionary *)dictionary
{
    if (self = [self init]) {
        self.userId = dictionary[OPEUserIdKey];
        self.displayName = dictionary[OPEDisplayNameKey];
    }
    return self;
}

- (NSDictionary *)dictionaryRepresentation
{
    if (self.userId && self.displayName) {
        return @{OPEUserIdKey:self.userId,OPEDisplayNameKey:self.displayName};
    }
    return nil;
}


#pragma - makr NSXMLParserDelegate Methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName attributes:(NSDictionary *)attributeDict
{
    //FIXME more properties to extract
    if ([elementName isEqualToString:@"user"]) {
        self.displayName = attributeDict[@"display_name"];
        self.userId = @([attributeDict[@"id"] integerValue]);
    }
}


#pragma - mark Class Methods

+ (void)setCurrentUser:(OPEOSMUser *)currentUser
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    NSDictionary *currentUserDictionary = [currentUser dictionaryRepresentation];
    if (currentUserDictionary) {
        [defaults setObject:currentUserDictionary forKey:OPECurrentUserKey];
    }
    else {
        [defaults removeObjectForKey:OPECurrentUserKey];
    }
}

+ (OPEOSMUser *)currentUser
{
    NSDictionary *userDictionary = [[NSUserDefaults standardUserDefaults] objectForKey:OPECurrentUserKey];
    return [[self alloc] initWithDictionary:userDictionary];
}



@end
