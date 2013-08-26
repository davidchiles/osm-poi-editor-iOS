//
//  OPEOSMTagConverter.h
//  OSM POI Editor
//
//  Created by David on 8/26/13.
//
//

#import <Foundation/Foundation.h>

struct phoneNumber {
    int64_t countryCode;
    int64_t areaCode;
    int64_t localNumber;
};
typedef struct phoneNumber phoneNumber;

@interface OPEOSMTagConverter : NSObject

+(phoneNumber)phoneNumberWithOsmValue:(NSString *)string;
+(NSString *)osmStringWithPhoneNumber:(phoneNumber)phoneNumber;

@end
