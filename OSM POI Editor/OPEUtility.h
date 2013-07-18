//
//  OPEUtility.h
//  OSM POI Editor
//
//  Created by David on 11/1/12.
//
//

#import <Foundation/Foundation.h>
#import "RMTileSource.h"


@interface OPEUtility : NSObject


+(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color;
+(NSString *)fileFromBundleOrDocumentsForResource:(NSString *)resource ofType:(NSString *)type;

+(NSString *)removeHTML:(NSString *)string;
+(NSString *)addHTML:(NSString *)string;
+(NSString *)formatDistanceMeters:(double)meters;
+(BOOL)uesMetric;

+(NSString *)hashOfFilePath:(NSString *)filePath;
+(NSString *)hasOfData:(NSData *)data;

+(id)currentValueForSettingKey:(NSString *)settingKey;
+(void)setSettingsValue:(id)settingValue forKey:(NSString *)key;

+(id <RMTileSource>)currentTileSource;

+(NSString *)appVersion;
+(NSString *)iOSVersion;
+(NSString *)tileSourceName;

+(NSDate *)noteDateFromString:(NSString *)dateString;
+(NSDate *)dateFromString:(NSString *)dateString;
+(NSString *)currentDateFormatted;
+(NSString *)displayFormatDate:(NSDate *)date;

@end
