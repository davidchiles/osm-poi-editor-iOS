//
//  OPETranslate.m
//  OSM POI Editor
//
//  Created by David on 4/23/13.
//
//

#import "OPETranslate.h"
#import "OPEConstants.h"

@implementation OPETranslate

+(NSString *)translateString:(NSString *)englishString;
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    NSString * locale = [[defaults objectForKey:kOTRAppleLanguagesKey] objectAtIndex:0];
    NSString *bundlePath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil forLocalization:locale];
    if (!bundlePath && locale.length > 2) {
        locale = [locale substringToIndex:2];
        bundlePath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil forLocalization:locale];
    }
    if (!bundlePath) {
        NSString *defaultLocale = @"en";
        bundlePath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil forLocalization:defaultLocale];
    }
    NSBundle *foreignBundle = [[NSBundle alloc] initWithPath:[bundlePath stringByDeletingLastPathComponent]];
    //NSError * error = nil;
    //BOOL load = [foreignBundle loadAndReturnError:&error];
    NSString * translatedString = NSLocalizedStringFromTableInBundle(englishString, nil, foreignBundle, nil);
    
    return translatedString;
    
}

+(NSString *)systemLocale
{
    NSUserDefaults * defaults = [NSUserDefaults standardUserDefaults];
    DDLogInfo(@"Languages: %@",[defaults objectForKey:kOTRAppleLanguagesKey]);
    return [[defaults objectForKey:kOTRAppleLanguagesKey] objectAtIndex:0];
}

@end
