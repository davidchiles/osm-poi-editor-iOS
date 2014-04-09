//
//  OPEOSMUser.h
//  OSM POI Editor
//
//  Created by David Chiles on 3/26/14.
//
//

#import <Foundation/Foundation.h>

@interface OPEOSMUser : NSObject

@property (nonatomic, strong) NSString *displayName;
@property (nonatomic, strong) NSNumber *userId;

- (instancetype)initWithParser:(NSXMLParser *)parser;
- (instancetype)initWithDictionary:(NSDictionary *)dictionary;
- (NSDictionary *)dictionaryRepresentation;

+ (void)setCurrentUser:(OPEOSMUser *)currentUser;
+ (OPEOSMUser *)currentUser;

@end
