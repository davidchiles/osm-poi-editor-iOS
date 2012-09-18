//
//  OPEType.h
//  OSM POI Editor
//
//  Created by David on 8/24/12.
//
//

#import <Foundation/Foundation.h>

@interface OPEType : NSObject

@property (nonatomic, strong) NSString * displayName;
@property (nonatomic, strong) NSString * imageString;
@property (nonatomic, strong) NSDictionary * tags;
@property (nonatomic, strong) NSArray * optionalTags;
@property (nonatomic, strong) NSString * categoryName;


-(id)initWithName:(NSString*)name categoryName:(NSString *)catName dictionary:(NSDictionary*)dictionary;
-(BOOL)isEqual:(OPEType *)otherType;
@end
