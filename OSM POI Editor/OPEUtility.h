//
//  OPEUtility.h
//  OSM POI Editor
//
//  Created by David on 11/1/12.
//
//

#import <Foundation/Foundation.h>


@interface OPEUtility : NSObject



+(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;
+(NSString *)fileFromBundleOrDocumentsForResource:(NSString *)resource ofType:(NSString *)type;

@end
