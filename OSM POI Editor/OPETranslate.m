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
        //NSLog(@"Bundle path is nil! Falling back to 2-character locale.");
    }
    if (!bundlePath) {
        NSString *defaultLocale = @"en";
        bundlePath = [[NSBundle mainBundle] pathForResource:@"Localizable" ofType:@"strings" inDirectory:nil forLocalization:defaultLocale];
        //NSLog(@"Bundle path is nil! Falling back to english locale.");
    }
    NSBundle *foreignBundle = [[NSBundle alloc] initWithPath:[bundlePath stringByDeletingLastPathComponent]];
    //NSError * error = nil;
    //BOOL load = [foreignBundle loadAndReturnError:&error];
    NSString * translatedString = NSLocalizedStringFromTableInBundle(englishString, nil, foreignBundle, nil);
    
    return translatedString;
    
}

@end
