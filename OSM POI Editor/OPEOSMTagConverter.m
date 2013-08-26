//
//  OPEOSMTagConverter.m
//  OSM POI Editor
//
//  Created by David on 8/26/13.
//
//

#import "OPEOSMTagConverter.h"

@implementation OPEOSMTagConverter

+(phoneNumber)phoneNumberWithOsmValue:(NSString *)string
{
    NSArray * phoneArray = [[[string stringByReplacingOccurrencesOfString:@"+" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@"-" ]  componentsSeparatedByString:@"-"];
    phoneNumber pNumber;
    for(int i =0; i<3 && i<[phoneArray count]; i++)
    {
        switch (i) {
            case 0:
                pNumber.countryCode = [phoneArray[0] longLongValue];
                break;
            case 1:
                pNumber.areaCode = [phoneArray[1] longLongValue];
            case 2:
                pNumber.localNumber = [phoneArray[2] longLongValue];
                
            default:
                break;
        }
    }
    return pNumber;
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
