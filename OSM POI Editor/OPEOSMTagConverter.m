//
//  OPEOSMTagConverter.m
//  OSM POI Editor
//
//  Created by David on 8/26/13.
//
//

#import "OPEOSMTagConverter.h"

#import "OPELog.h"

@implementation OPEOSMTagConverter

+(phoneNumber)phoneNumberWithOsmValue:(NSString *)string
{
    __block phoneNumber pNumber;
    pNumber.areaCode = 0;
    pNumber.countryCode = 0;
    pNumber.localNumber = 0;
    
    BOOL containsCountryCode = [string rangeOfString:@"+"].location != NSNotFound;
    int length = 2;
    if (containsCountryCode) {
        length = 3;
    }
    //int areaCode = [self findAreaCode:string];
    //pNumber.areaCode = areaCode;
    string = [self phoneCleanString:string];
    NSArray * phoneArray = [string componentsSeparatedByString:@" "];
    
    if ([phoneArray count] > length) {
        __block NSString * localString = @"";
        [phoneArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            if (idx == length -2) {
                stop = YES;
            }
            else {
                localString = [NSString stringWithFormat:@"%@%@",obj,localString];
            }
        }];
        if (length == 2) {
            phoneArray = @[phoneArray[0],localString];
        }
        else if (length == 3)
        {
            phoneArray = @[phoneArray[0],phoneArray[1],localString];
        }
        
    }
    
    [phoneArray enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        int64_t num = [obj longLongValue];
        if (!pNumber.localNumber) {
            pNumber.localNumber = num;
        }
        else if (!pNumber.areaCode) {
            pNumber.areaCode = num;
        }
        else if (!pNumber.countryCode) {
            pNumber.countryCode = num;
        }
    }];
    return pNumber;
}

+(int)findAreaCode:(NSString *)string
{
    NSError * error = nil;
    NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:@"(\(d+))" options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        DDLogInfo(@"RegEx Error: %@",error);
    }
    
    NSRange range = [regularExpression rangeOfFirstMatchInString:string options:NSMatchingCompleted range:NSMakeRange(0, [string length])];
    if (range.location != NSNotFound) {
        NSRange newRange;
        newRange.location = range.location+1;
        newRange.length = range.length -1;
        return [[string substringWithRange:newRange] intValue];
    }
    return 0;
}

+(NSString *)phoneCleanString:(NSString *)string
{
    NSString* (^replaceWithWhiteSpace)(NSString* string,NSString * regex) = ^NSString*(NSString* string,NSString * regex) {
        NSError * error = nil;
        NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:regex options:NSRegularExpressionCaseInsensitive error:&error];
        if (error) {
            DDLogInfo(@"RegEx Error: %@",error);
        }

        NSRange range = [regularExpression rangeOfFirstMatchInString:string options:NSMatchingCompleted range:NSMakeRange(0, [string length])];
        while (range.location != NSNotFound) {
            string = [string stringByReplacingCharactersInRange:range withString:@" "];
            range = [regularExpression rangeOfFirstMatchInString:string options:NSMatchingCompleted range:NSMakeRange(0, [string length])];
        }
        return string;
    };
    
    string = replaceWithWhiteSpace(string,@"[^0-9| \t]+");
    string = replaceWithWhiteSpace(string,@"[ \t]{2,}");
    
    
    return [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    
}

+(NSString *)osmStringWithPhoneNumber:(phoneNumber)phoneNumber
{
    NSMutableString * finalString = [NSMutableString string];
    if (phoneNumber.countryCode) {
        [finalString appendFormat:@"+%lld",phoneNumber.countryCode];
    }
    
    if(phoneNumber.areaCode){
        [finalString appendFormat:@" %lld",phoneNumber.areaCode];
    }
    
    if(phoneNumber.localNumber){
        [finalString appendFormat:@" %lld",phoneNumber.localNumber];
    }
    return [finalString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
}

@end
