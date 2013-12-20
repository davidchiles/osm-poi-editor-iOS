//
//  OPEUtility.m
//  OSM POI Editor
//
//  Created by David on 11/1/12.
//
//

#import "OPEUtility.h"

#import <QuartzCore/QuartzCore.h>
#import <CommonCrypto/CommonDigest.h>
#import "OPEConstants.h"
#import "OPEAPIConstants.h"

#import "OPEOpenMapQuestAerialTileSource.h"
#import "OPEOpenStreetMapSource.h"
#import "OPEBingTileSource.h"

@implementation OPEUtility

+(UIImage *)imageNamed:(NSString *)name withColor:(UIColor *)color
{
    UIImage *img = [UIImage imageNamed:name];
    
    // begin a new image context, to draw our colored image onto
    UIGraphicsBeginImageContextWithOptions(img.size, NO, [UIScreen mainScreen].scale);
    
    // get a reference to that context we created
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // set the fill color
    [color setFill];
    
    // translate/flip the graphics context (for transforming from CG* coords to UI* coords
    CGContextTranslateCTM(context, 0, img.size.height);
    CGContextScaleCTM(context, 1.0, -1.0);
    
    // set the blend mode to color burn, and the original image
    CGContextSetBlendMode(context, kCGBlendModeNormal);
    CGRect rect = CGRectMake(0, 0, img.size.width, img.size.height);
    CGContextDrawImage(context, rect, img.CGImage);
    
    // set a mask that matches the shape of the image, then draw (color burn) a colored rectangle
    CGContextClipToMask(context, rect, img.CGImage);
    CGContextAddRect(context, rect);
    CGContextDrawPath(context,kCGPathFill);
    
    // generate a new UIImage from the graphics context we drew onto
    UIImage *coloredImg = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    //return the color-burned image
    return coloredImg;
    
}

+(NSString *)fileFromBundleOrDocumentsForResource:(NSString *)resource ofType:(NSString *)type
{
    NSString* documentsPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) objectAtIndex:0];
    NSString* filePath = [documentsPath stringByAppendingPathComponent:[resource stringByAppendingPathExtension:type]];
    
    if([[NSFileManager defaultManager] fileExistsAtPath:filePath])
        return filePath;
    else
        return [[NSBundle mainBundle] pathForResource:resource ofType:type];
}

+(NSString *)removeHTML:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"];
}
+(NSString *)addHTML:(NSString *)string
{
    return [string stringByReplacingOccurrencesOfString:@"&" withString:@"&amp;"];
}

+(BOOL)uesMetric
{
    return [[[NSLocale currentLocale] objectForKey:NSLocaleUsesMetricSystem] boolValue];
}

+(NSString *)formatDistanceMeters:(double)meters
{
    if (meters < 0) {
        return @"";
    }
    
    if ([OPEUtility uesMetric]) {
        if (meters < 1.0) {
            return @"<1 m";
        }
        else if (meters > 500.0)
        {
            return [NSString stringWithFormat: @"%.1f %@",meters/1000.0,@"km"];
        }
        return [NSString stringWithFormat: @"%.1f %@",meters,@"m"];
    }
    else{
        double ft = meters*3.28084;
        
        if (ft > 100) {
            return [NSString stringWithFormat: @"%.1f %@",ft/3.0,@"yd"];
        }
        else if (ft > 3000)
        {
            return [NSString stringWithFormat: @"%.1f %@",ft/5280,@"mi"];
        }
        return [NSString stringWithFormat: @"%.1f %@",ft,@"ft"];
        
    }
    
}
+(NSString *)hasOfData:(NSData *)data
{
    unsigned char md5Buffer[CC_MD5_DIGEST_LENGTH];
    CC_MD5(data.bytes, (CC_LONG)data.length, md5Buffer);
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x",md5Buffer[i]];
    
    return output;
}

+(NSString *)hashOfFilePath:(NSString *)filePath
{
    NSData * data = [[NSData alloc] initWithContentsOfFile:filePath];
    return [self hasOfData:data];
}

+(id)currentValueForSettingKey:(NSString *)settingKey
{
    return [[NSUserDefaults standardUserDefaults] objectForKey:settingKey];
    
}

+(void)setSettingsValue:(id)settingValue forKey:(NSString *)key
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    [defaults setObject:settingValue forKey:key];
    [defaults synchronize];
    
}

+(id <RMTileSource>)currentTileSource
{
    int num = 0;
   
    if ([self currentValueForSettingKey:kTileSourceNumber]) {
        num = [[self currentValueForSettingKey:kTileSourceNumber] intValue] ;
        
    }
    
    if (num == 1) {
        return [[OPEOpenMapQuestAerialTileSource alloc] init];
    }
    else if (num == 2) {
        return [[OPEOpenStreetMapSource alloc] init];
    }
    else if([bingMapsKey length]){
        return [[OPEBingTileSource alloc] initWithMapsKey:bingMapsKey];
    }
    else
    {
        return [[OPEOpenMapQuestAerialTileSource alloc] init];
    }
    
    
    return nil;
}

+(NSString *)appVersion
{
    return [NSString stringWithFormat:@"%@", [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"]];
}
+(NSString *)iOSVersion
{
    return [NSString stringWithFormat:@"%@ %@",[UIDevice currentDevice].systemName,[UIDevice currentDevice].systemVersion];
}
+(NSString *)tileSourceName
{
    return [[self currentTileSource] shortName];
}

+(NSString *)currentDateFormatted
{
    NSDateFormatter * dateFormatter = [[self class] defaultDateFormatter];
    return [dateFormatter stringFromDate:[NSDate date]];
    
}
+(NSDate *)dateFromString:(NSString *)dateString
{
    NSDateFormatter * dateFormatter = [[self class] defaultDateFormatter];
    return [dateFormatter dateFromString:dateString];
}
+(NSDateFormatter *)defaultDateFormatter
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd'T'HH:mm:ssZ"];
    return formatter;
}

+(NSDate *)noteDateFromString:(NSString *)dateString
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    [formatter setDateFormat:@"yyyy-MM-dd HH:mm:ss z"];
    NSDate * date =  [formatter dateFromString:dateString];
    return date;
}

+(NSString *)displayFormatDate:(NSDate *)date
{
    NSDateFormatter * formatter = [[NSDateFormatter alloc] init];
    NSTimeInterval timeInterval = fabs([date timeIntervalSinceNow]);
    //last week
    if (timeInterval < 518400)
    {
        [formatter setDateFormat:@"EEEE HH:mm"];
    }
    else if (timeInterval < 28908000)
    {
        [formatter setDateFormat:@"MMM d HH:mm"];
    }
    else{
        [formatter setDateFormat:@"YYYY MMM d HH:mm"];
    }
    
    return [formatter stringFromDate:date];
}

@end
