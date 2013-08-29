//
//  OPEOpeningHoursParser.m
//  OSM POI Editor
//
//  Created by David on 8/27/13.
//
//

#define OFF_STRING @"off"
#define SUNRISE_STRING @"sunrise"
#define SUNSET_STRING @"sunset"
#define TWENTY_FOUR_SEVEN_STRING @"24/7"

#define MONTH_KEY @"month"
#define WEEKDAY_KEY @"weekday"
#define NUMBER_KEY @"number"
#define TIME_SEPERATOR_KEY @"timeSeperatorKey"
#define SUN_KEY @"sun"

#import "OPEOpeningHoursParser.h"

@implementation OPEDateComponents
@synthesize isSunrise=_isSunrise;
@synthesize isSunset=_isSunset;


-(NSString *)description
{
    if (self.isSunrise) {
        return SUNRISE_STRING;
    }
    else if (self.isSunset) {
        return SUNSET_STRING;
    }
    else {
        return [NSString stringWithFormat:@"%02d:%02d",self.hour,self.minute];
    }
    return [super description];
}

@end

@implementation OPEDateRange

@synthesize startDateComponent,endDateComponent;

-(NSString *)description
{
    return [NSString stringWithFormat:@"%@-%@",startDateComponent,endDateComponent];
}

@end

@implementation OPEOpeningHourRule

@synthesize monthsOrderedSet,daysOfWeekOrderedSet,timeRangesOrderedSet,isTwentyFourSeven;
@synthesize isOpen =_isOpen;

-(id)init {
    if (self = [super init]) {
        self.isOpen = YES;
        self.isTwentyFourSeven = NO;
        self.monthsOrderedSet = [NSOrderedSet orderedSet];
        self.timeRangesOrderedSet = [NSOrderedSet orderedSet];
        self.daysOfWeekOrderedSet = [NSOrderedSet orderedSet];
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ \n%@ \n%@",monthsOrderedSet,daysOfWeekOrderedSet,timeRangesOrderedSet];
}

@end

@interface OPEOpeningHoursToken : NSObject

@property (nonatomic,strong) NSString * type;
@property (nonatomic,strong) NSString * value;

+(id)tokenWithType:(NSString *)type value:(NSString *)value;

@end

@implementation OPEOpeningHoursToken

@synthesize type,value;
-(NSString *)description
{
    return [NSString stringWithFormat:@"%@ : %@",self.type,self.value];
}

+(id)tokenWithType:(NSString *)newType value:(NSString *)newValue
{
    OPEOpeningHoursToken * token = [[self alloc] init];
    token.type =newType;
    token.value = newValue;
    return token;
}

@end

@implementation OPEOpeningHoursParser

-(void)parseString:(NSString *)string
           success:(void (^)(NSArray *blocks))success
           failure:(void (^)(NSError *error))failure {
     NSLog(@"Original: %@",string);
    string = string.lowercaseString;
    
    if ([self containsOff:string]) {
        if (failure) {
            failure([OPEOpeningHoursParser notSupportedError]);
        }
    }
    
    NSArray * rules = [string componentsSeparatedByString:@";"];
    
    NSMutableArray * blocks = [NSMutableArray array];
    
    [rules enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray * tokenizedArray = [self tokenize:obj];
        [blocks addObject:[self parseTokens:tokenizedArray]];
    }];
    
    if (success) {
        success(blocks);
    }
    
    
    //NSLog(@"blocks: %@",blocks);
   
    NSLog(@"Round Trip: %@",[self stringWithRules:blocks]);
    
}

-(OPEOpeningHourRule *)parseTokens:(NSArray *)tokens
{
    OPEOpeningHourRule * rule = [[OPEOpeningHourRule alloc] init];
    //NSNumber * index = [NSNumber numberWithInt:0];
    NSInteger index = 0;
    while (index < [tokens count]) {
        //NSInteger idx = [index integerValue];
        if ([self matchTokens:tokens atIndex:index matches:@[MONTH_KEY]]) {
            rule.monthsOrderedSet = [self parseMonthRangeWithTokens:tokens atIndex:&index];
        }
        else if ([self matchTokens:tokens atIndex:index matches:@[WEEKDAY_KEY]]) {
            rule.daysOfWeekOrderedSet = [self parseWeekdayRangeWithTokens:tokens atIndex:&index];
        }
        else if ([self matchTokens:tokens atIndex:index matches:@[NUMBER_KEY,TIME_SEPERATOR_KEY]] || [self matchTokens:tokens atIndex:index matches:@[SUN_KEY]]) {
            rule.timeRangesOrderedSet = [self parseTimeRangeWithTokens:tokens atIndex:&index];
        }
        else if ([self matchTokens:tokens atIndex:index matches:@[TWENTY_FOUR_SEVEN_STRING]]) {
            rule.isTwentyFourSeven = YES;
            index = index+1;
        }
        else {
            index = index+1;
        }
    }
    return rule;
}

-(NSOrderedSet *)parseMonthRangeWithTokens:(NSArray *)tokens atIndex:(NSInteger *)index
{
    NSMutableOrderedSet * monthOrderedSet = [NSMutableOrderedSet orderedSet];
    while (*index < [tokens count]) {
        //NSInteger idx = [index integerValue];
        if ([self matchTokens:tokens atIndex:*index matches:@[MONTH_KEY,@"-",MONTH_KEY]]) {
            //Weekday Range
            NSInteger startMonthIndex = [[self monthsArray] indexOfObject:((OPEOpeningHoursToken *)tokens[*index]).value];
            NSInteger endMonthIndex = [[self monthsArray] indexOfObject:((OPEOpeningHoursToken *)tokens[*index+2]).value];
            
            void (^findWeekDayRangeWithStartFinish)(NSInteger,NSInteger) = ^(NSInteger start,NSInteger end) {
                for (NSInteger idx = start; idx<=end; idx++) {
                    NSDateComponents * month = [[NSDateComponents alloc] init];
                    month.month =idx +1;
                    [monthOrderedSet addObject:month];
                }
                
            };
            
            //Handle case where dates wrap around ex nov-may (11->5 = 11,12,1,2,3,4,5)
            if (endMonthIndex < startMonthIndex) {
                findWeekDayRangeWithStartFinish(startMonthIndex,11);
                findWeekDayRangeWithStartFinish(0,endMonthIndex);
            }
            else {
                findWeekDayRangeWithStartFinish(startMonthIndex,endMonthIndex);
            }
            
            *index = *index+3;
        }
        else if ([self matchTokens:tokens atIndex:*index matches:@[MONTH_KEY]])
        {
            NSInteger monthIndex = [[self monthsArray] indexOfObject:((OPEOpeningHoursToken *)tokens[*index]).value];
            NSDateComponents * month = [[NSDateComponents alloc] init];
            month.month =monthIndex +1;
            [monthOrderedSet addObject:month];
            *index = *index+1;
        }
        
        
        if (![self matchTokens:tokens atIndex:*index matches:@[@","]]) {
            break;
        }
        *index = *index+1;
        
    }
    return monthOrderedSet;
    
}

-(NSOrderedSet *)parseWeekdayRangeWithTokens:(NSArray *)tokens atIndex:(NSInteger *)index
{
    NSMutableOrderedSet * weekDayOrderedSet = [NSMutableOrderedSet orderedSet];
    while (*index < [tokens count]) {
        //NSInteger idx = [index integerValue];
        if ([self matchTokens:tokens atIndex:*index matches:@[WEEKDAY_KEY,@"-",WEEKDAY_KEY]]) {
            //Weekday Range
            NSInteger startWeekDayIndex = [[self weekdaysArray] indexOfObject:((OPEOpeningHoursToken *)tokens[*index]).value];
            NSInteger endWeekDayIndex = [[self weekdaysArray] indexOfObject:((OPEOpeningHoursToken *)tokens[*index+2]).value];
            
            void (^findWeekDayRangeWithStartFinish)(NSInteger,NSInteger) = ^(NSInteger start,NSInteger end) {
                for (NSInteger idx = start; idx<=end; idx++) {
                    NSDateComponents * weekDay = [[NSDateComponents alloc] init];
                    weekDay.weekday =idx +1;
                    [weekDayOrderedSet addObject:weekDay];
                }
                
            };
            
            //Handle case where dates wrap around ex fr-mo (6->2 = 6,7,1,2)
            if (endWeekDayIndex < startWeekDayIndex) {
                findWeekDayRangeWithStartFinish(startWeekDayIndex,6);
                findWeekDayRangeWithStartFinish(0,endWeekDayIndex);
            }
            else {
                findWeekDayRangeWithStartFinish(startWeekDayIndex,endWeekDayIndex);
            }
            
            *index = *index+3;
        }
        else if ([self matchTokens:tokens atIndex:*index matches:@[WEEKDAY_KEY]])
        {
            NSInteger weekDayIndex = [[self weekdaysArray] indexOfObject:((OPEOpeningHoursToken *)tokens[*index]).value];
            NSDateComponents * weekDay = [[NSDateComponents alloc] init];
            weekDay.weekday =weekDayIndex +1;
            [weekDayOrderedSet addObject:weekDay];
            *index = *index+1;
        }
        
        
        if (![self matchTokens:tokens atIndex:*index matches:@[@","]]) {
            break;
        }
        *index = *index+1;
        
    }
    return weekDayOrderedSet;
    
}
-(NSOrderedSet *)parseTimeRangeWithTokens:(NSArray *)tokens atIndex:(NSInteger *)index
{
    NSMutableOrderedSet * timeRangesOrderedSet = [NSMutableOrderedSet orderedSet];
    while( *index<[tokens count]) {
        //NSInteger idx = [index integerValue];
        if ([self matchTokens:tokens atIndex:*index matches:@[NUMBER_KEY, TIME_SEPERATOR_KEY, NUMBER_KEY, @"-", NUMBER_KEY, TIME_SEPERATOR_KEY, NUMBER_KEY]]) {
            
            
            OPEDateComponents * startTimeComponent = [[OPEDateComponents alloc] init];
            startTimeComponent.hour = [((OPEOpeningHoursToken *)tokens[*index]).value intValue];
            startTimeComponent.minute = [((OPEOpeningHoursToken *)tokens[*index+2]).value intValue];
            
            OPEDateComponents * endTimeComponent = [[OPEDateComponents alloc] init];
            endTimeComponent.hour = [((OPEOpeningHoursToken *)tokens[*index+4]).value intValue];
            endTimeComponent.minute = [((OPEOpeningHoursToken *)tokens[*index+6]).value intValue];
            
            OPEDateRange * timeRange = [[OPEDateRange alloc] init];
            timeRange.startDateComponent = startTimeComponent;
            timeRange.endDateComponent = endTimeComponent;
            
            [timeRangesOrderedSet addObject:timeRange];
            
            *index = *index+7;
        }
        else if ([self matchTokens:tokens atIndex:*index matches:@[NUMBER_KEY, TIME_SEPERATOR_KEY, NUMBER_KEY, @"-", SUN_KEY]]) {
            
            OPEDateComponents * startTimeComponent = [[OPEDateComponents alloc] init];
            startTimeComponent.hour = [((OPEOpeningHoursToken *)tokens[*index]).value intValue];
            startTimeComponent.minute = [((OPEOpeningHoursToken *)tokens[*index+2]).value intValue];
            
            OPEDateComponents * endTimeComponent = [[OPEDateComponents alloc] init];
            if([((OPEOpeningHoursToken *)tokens[*index+2]).value isEqualToString:SUNRISE_STRING]) {
                endTimeComponent.isSunrise = YES;
            }
            else {
                endTimeComponent.isSunset = YES;
            }
            
            OPEDateRange * timeRange = [[OPEDateRange alloc] init];
            timeRange.startDateComponent = startTimeComponent;
            timeRange.endDateComponent = endTimeComponent;
            
            [timeRangesOrderedSet addObject:timeRange];
            *index = *index+5;
        }
        else if ([self matchTokens:tokens atIndex:*index matches:@[SUN_KEY, @"-", NUMBER_KEY, TIME_SEPERATOR_KEY, NUMBER_KEY]]) {
            
            OPEDateComponents * startTimeComponent = [[OPEDateComponents alloc] init];
            if([((OPEOpeningHoursToken *)tokens[*index]).value isEqualToString:SUNRISE_STRING]) {
                startTimeComponent.isSunrise = YES;
            }
            else {
                startTimeComponent.isSunset = YES;
            }
            
            OPEDateComponents * endTimeComponent = [[OPEDateComponents alloc] init];
            endTimeComponent.hour = [((OPEOpeningHoursToken *)tokens[*index+4]).value intValue];
            endTimeComponent.minute = [((OPEOpeningHoursToken *)tokens[*index+6]).value intValue];
            
            OPEDateRange * timeRange = [[OPEDateRange alloc] init];
            timeRange.startDateComponent = startTimeComponent;
            timeRange.endDateComponent = endTimeComponent;
            
            [timeRangesOrderedSet addObject:timeRange];
            *index = *index+5;
            
        }
        else if ([self matchTokens:tokens atIndex:*index matches:@[SUN_KEY, @"-", SUN_KEY]]) {
            
            OPEDateComponents * startTimeComponent = [[OPEDateComponents alloc] init];
            if([((OPEOpeningHoursToken *)tokens[*index]).value isEqualToString:SUNRISE_STRING]) {
                startTimeComponent.isSunrise = YES;
            }
            else {
                startTimeComponent.isSunset = YES;
            }
            
            OPEDateComponents * endTimeComponent = [[OPEDateComponents alloc] init];
            if([((OPEOpeningHoursToken *)tokens[*index+2]).value isEqualToString:SUNRISE_STRING]) {
                endTimeComponent.isSunrise = YES;
            }
            else {
                endTimeComponent.isSunset = YES;
            }
            
            OPEDateRange * timeRange = [[OPEDateRange alloc] init];
            timeRange.startDateComponent = startTimeComponent;
            timeRange.endDateComponent = endTimeComponent;
            
            [timeRangesOrderedSet addObject:timeRange];
            *index = *index+3;
        }
        else {
            NSLog(@"Time Range Error at %d",*index);
        }
        if (![self matchTokens:tokens atIndex:*index matches:@[@","]]) {
            break;
        }
        *index = *index+1;
    }
    return timeRangesOrderedSet;
}

//Takes tokes start search for pattern from inded @["weekday","-","weekday"] OR @[@"number", @"timesep", @"number", @"-", @"number", @"timesep", @"number"]
-(BOOL)matchTokens:(NSArray *)tokens atIndex:(NSInteger)index matches:(NSArray *)matches {
    if (index+[matches count] > [tokens count]) {
        return NO;
    }
    
    __block BOOL allMatch = YES;
    [matches enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSString * type = ((OPEOpeningHoursToken *)tokens[index+idx]).type;
        if (![(NSString *)obj isEqualToString:type]) {
            allMatch = NO;
            stop = YES;
        }
    }];
    
    return allMatch;
    
    
}
-(NSArray *)tokenize:(NSString *)string
{
    NSMutableArray * tokens = [NSMutableArray array];
    
    while ([string length]) {
        //remove leading and trailing whitespaces
        string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        //NSString * tempString = nil;
        NSRange foundRange = NSMakeRange(NSNotFound, 0);
        //@"^(?:week|24/7|off)"
        if ((foundRange = [self firstMatchForString:string withRegularExpression:@"^(?:24/7)"]).location != NSNotFound) {
            NSString * foundString = [string substringWithRange:foundRange];
            [tokens addObject:[OPEOpeningHoursToken tokenWithType:TWENTY_FOUR_SEVEN_STRING value:foundString]];
            string = [string substringFromIndex:foundRange.length];
        }
        else if ((foundRange = [self firstMatchForString:string withRegularExpression:@"^(?:sunrise|sunset)"]).location != NSNotFound) {
            NSString * foundString = [string substringWithRange:foundRange];
            [tokens addObject:[OPEOpeningHoursToken tokenWithType:SUN_KEY value:foundString]];
            string = [string substringFromIndex:foundRange.length];
        }
        else if ((foundRange = [self firstMatchForString:string withRegularExpression:@"^(?:jan|feb|mar|apr|may|jun|jul|aug|sep|oct|nov|dec)"]).location != NSNotFound) {
            NSString * foundString = [string substringWithRange:foundRange];
            [tokens addObject:[OPEOpeningHoursToken tokenWithType:MONTH_KEY value:foundString]];
            string = [string substringFromIndex:foundRange.length];
        }
        else if ((foundRange = [self firstMatchForString:string withRegularExpression:@"^(?:mo|tu|we|th|fr|sa|su)"]).location != NSNotFound) {
            NSString * foundString = [string substringWithRange:foundRange];
            [tokens addObject:[OPEOpeningHoursToken tokenWithType:WEEKDAY_KEY value:foundString]];
            string = [string substringFromIndex:foundRange.length];
        }
        else if ((foundRange = [self firstMatchForString:string withRegularExpression:@"^\\d+"]).location != NSNotFound) {
            NSString * foundString = [string substringWithRange:foundRange];
            [tokens addObject:[OPEOpeningHoursToken tokenWithType:NUMBER_KEY value:foundString]];
            string = [string substringFromIndex:foundRange.length];
        }
        else if ((foundRange = [self firstMatchForString:string withRegularExpression:@"^[:.]"]).location != NSNotFound) {
            NSString * foundString = [string substringWithRange:foundRange];
            [tokens addObject:[OPEOpeningHoursToken tokenWithType:TIME_SEPERATOR_KEY value:foundString]];
            string = [string substringFromIndex:foundRange.length];
        }
        else {
            foundRange = NSMakeRange(0, 1);
            NSString * foundString = [string substringWithRange:foundRange];
            [tokens addObject:[OPEOpeningHoursToken tokenWithType:foundString value:foundString]];
            string = [string substringFromIndex:foundRange.length];
        }
    }
    return tokens;
}

-(NSRange)firstMatchForString:(NSString *)string withRegularExpression:(NSString *)regularExpressionString
{
    NSError * error = nil;
    NSRegularExpression * regularExpression = [NSRegularExpression regularExpressionWithPattern:regularExpressionString options:NSRegularExpressionCaseInsensitive error:&error];
    if (error) {
        NSLog(@"RegEx Error: %@",error);
    }
    return [regularExpression rangeOfFirstMatchInString:string options:NSMatchingCompleted range:NSMakeRange(0, [string length])];

}

#pragma mark BackToOsmString

-(NSString *)stringWithRules:(NSArray *)rulesArray {
    NSMutableArray * resultStrings = [NSMutableArray array];
    [rulesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray * ruleStringArray = [NSMutableArray array];
        OPEOpeningHourRule * rule = (OPEOpeningHourRule *)obj;
        if (rule.isTwentyFourSeven) {
            [ruleStringArray addObject:TWENTY_FOUR_SEVEN_STRING];
        }
        
        if ([rule.monthsOrderedSet count]) {
            [ruleStringArray addObject:[self stringWithmonthsOrderedSet:rule.monthsOrderedSet]];
        }
        
        if ([rule.daysOfWeekOrderedSet count]) {
            [ruleStringArray addObject:[self stringWithdaysOfWeekOrderedSet:rule.daysOfWeekOrderedSet]];
        }
        
        if ([rule.timeRangesOrderedSet count]) {
            [ruleStringArray addObject:[self stringWithtimeRangesOrderedSet:rule.timeRangesOrderedSet]];
        }
        
        [resultStrings addObject:[ruleStringArray componentsJoinedByString:@" "]];
        
        
    }];
    return [resultStrings componentsJoinedByString:@"; "];
}

-(NSString *)stringWithmonthsOrderedSet:(NSOrderedSet *)monthsOrderedSet {
    NSMutableArray * stringsArray = [NSMutableArray array];
    if ([monthsOrderedSet count]>11 || ![monthsOrderedSet count]) {
        return @"";
    }
    
    NSMutableArray * numbers = [NSMutableArray array];
    [monthsOrderedSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [numbers addObject:[NSNumber numberWithInteger:((NSDateComponents *)obj).month]];
    }];
    NSMutableArray * ranges = [[self intRangesFor:numbers] mutableCopy];
    NSRange firstRange = [ranges[0] rangeValue];
    NSRange lastRange = [[ranges lastObject] rangeValue];
    //check wrap around nov-may
    if (firstRange.location == 1 && (lastRange.location +lastRange.length)==13) {
        [ranges removeObjectAtIndex:0];
        [ranges removeLastObject];
        lastRange.length += firstRange.length;
        [ranges addObject:[NSValue valueWithRange:lastRange]];
    }
    
    [ranges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSRange range = [((NSValue *)obj) rangeValue];
        if (range.length == 1) {
            [stringsArray addObject:[[self monthsArray][range.location-1] capitalizedString]];
        }
        else if(range.length > 1)
        {
            NSInteger start = range.location-1;
            NSInteger end = (start+range.length-1)%12;
            NSString * string = [NSString stringWithFormat:@"%@-%@",[[self monthsArray][start] capitalizedString],[[self monthsArray][end] capitalizedString]];
            [stringsArray addObject:string];
        }
    }];
    return [stringsArray componentsJoinedByString:@","];
}
-(NSString *)stringWithdaysOfWeekOrderedSet:(NSOrderedSet *)daysOfWeekOrderedSet {
    
    NSMutableArray * stringsArray = [NSMutableArray array];
    if ([daysOfWeekOrderedSet count]>6 || ![daysOfWeekOrderedSet count]) {
        return @"";
    }
    
    NSMutableArray * numbers = [NSMutableArray array];
    [daysOfWeekOrderedSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [numbers addObject:[NSNumber numberWithInteger:((NSDateComponents *)obj).weekday]];
    }];
    NSMutableArray * ranges = [[self intRangesFor:numbers] mutableCopy];
    NSRange firstRange = [ranges[0] rangeValue];
    NSRange lastRange = [[ranges lastObject] rangeValue];
    //check wrap around fr-tu
    if (firstRange.location == 1 && (lastRange.location +lastRange.length)==8) {
        [ranges removeObjectAtIndex:0];
        [ranges removeLastObject];
        lastRange.length += firstRange.length;
        [ranges addObject:[NSValue valueWithRange:lastRange]];
    }
    
    [ranges enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSRange range = [((NSValue *)obj) rangeValue];
        if (range.length == 1) {
            [stringsArray addObject:[[self weekdaysArray][range.location-1] capitalizedString]];
        }
        else if(range.length > 1)
        {
            NSInteger start = range.location-1;
            NSInteger end = (start+range.length-1)%7;
            NSString * string = [NSString stringWithFormat:@"%@-%@",[[self weekdaysArray][start] capitalizedString],[[self weekdaysArray][end] capitalizedString]];
            [stringsArray addObject:string];
        }
    }];
    return [stringsArray componentsJoinedByString:@","];
    
}
-(NSString *)stringWithtimeRangesOrderedSet:(NSOrderedSet *)timeRangesOrderedSet {
    NSMutableArray * stringsArray = [NSMutableArray array];
    
    [timeRangesOrderedSet enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        OPEDateRange * dateRange = (OPEDateRange *)obj;
        [stringsArray addObject:[NSString stringWithFormat:@"%@",dateRange]];
    }];
    
    return [stringsArray componentsJoinedByString:@","];
}

//given array of nsnumbers find ranges and numbers that are equal
-(NSArray *)intRangesFor:(NSArray *)array
{
    if (![array count]) {
        return  @[];
    }
    else if([array count] == 1)
    {
        NSInteger integer = [[array lastObject] integerValue];
        return @[[NSValue valueWithRange:NSMakeRange(integer, 1)]];
    }
    
    NSMutableArray * resultRanges = [NSMutableArray array];
    NSSortDescriptor *highestToLowest = [NSSortDescriptor sortDescriptorWithKey:@"self" ascending:YES];
    NSArray * sortedNumbers = [array sortedArrayUsingDescriptors:@[highestToLowest]];
    
    __block NSRange currentRange = NSMakeRange(NSNotFound, 0);
    [sortedNumbers enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSInteger currentInteger = [((NSNumber *) obj) integerValue];
        if (idx > 0) {
            NSInteger previousInteger =[((NSNumber *) sortedNumbers[idx-1]) integerValue];
            
            if (previousInteger == currentInteger -1) {
                currentRange.length +=1;
            }
            else {
                [resultRanges addObject:[NSValue valueWithRange:currentRange]];
                currentRange = NSMakeRange(currentInteger, 1);
            }
        }
        else {
            currentRange = NSMakeRange(currentInteger, 1);
        }
    }];
    [resultRanges addObject:[NSValue valueWithRange:currentRange]];
    return  resultRanges;
}


#pragma  mark helpers

-(NSArray *)monthsArray
{
    return  @[@"jan", @"feb", @"mar", @"apr", @"may", @"jun", @"jul", @"aug", @"sep", @"oct", @"nov", @"dec"];
}
-(NSArray *)weekdaysArray
{
    return @[@"su",@"mo",@"tu", @"we", @"th", @"fr",@"sa"];
}

-(BOOL)containsOff:(NSString *)string
{
    return [string rangeOfString:OFF_STRING].location != NSNotFound;
}

-(BOOL)containsMonth:(NSString *)string
{
    __block BOOL containsMonth = NO;
    [self.monthsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        if([string rangeOfString:(NSString *)obj].location!=NSNotFound){
            containsMonth = YES;
            stop = YES;
        }
    }];
    return containsMonth;
}

#pragma mark Error

+(NSError *)notSupportedError
{
    NSDictionary * details = @{NSLocalizedDescriptionKey:@"Not Supported"};
    NSError * error = [NSError errorWithDomain:@"Opening Hours" code:200 userInfo:details];
    return error;
}

#pragma Tests

+(void)test
{
    NSArray * testArray = @[@"Nov-May Tu-Su 08:00-15:00;Sa 08:00-12:00",@"Mo,We Sunrise-Sunset;Tu-Sa 08:00-Sunset",@"24/7",@"Mo-We 10:30-15:00",@"Th-Tu 12:00-13:00,14:00-15:00"];
    
    [testArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[[OPEOpeningHoursParser alloc] init] parseString:obj success:^(NSArray *blocks) {
            NSLog(@"%@",blocks);
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }];
    
}

@end
