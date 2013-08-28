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

@synthesize monthsArray,daysOfWeekArray,timeRangesArray,isTwentyFourSeven;
@synthesize isOpen =_isOpen;

-(id)init {
    if (self = [super init]) {
        self.isOpen = YES;
        self.isTwentyFourSeven = NO;
        self.monthsArray = [NSArray array];
        self.timeRangesArray = [NSArray array];
        self.daysOfWeekArray = [NSArray array];
    }
    return self;
}

-(NSString *)description {
    return [NSString stringWithFormat:@"%@ \n%@ \n%@",monthsArray,daysOfWeekArray,timeRangesArray];
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
    
    string = string.lowercaseString;
    
    if ([self containsMonth:string]||[self containsOff:string]) {
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
    
    
    //NSLog(@"blocks: %@",blocks);
    NSLog(@"Round Trip %@",[self stringWithRules:blocks]);
    
}

-(OPEOpeningHourRule *)parseTokens:(NSArray *)tokens
{
    OPEOpeningHourRule * rule = [[OPEOpeningHourRule alloc] init];
    //NSNumber * index = [NSNumber numberWithInt:0];
    NSInteger index = 0;
    while (index < [tokens count]) {
        //NSInteger idx = [index integerValue];
        if ([self matchTokens:tokens atIndex:index matches:@[WEEKDAY_KEY]]) {
            rule.daysOfWeekArray = [self parseWeekdayRangeWithTokens:tokens atIndex:&index];
        }
        else if ([self matchTokens:tokens atIndex:index matches:@[NUMBER_KEY,TIME_SEPERATOR_KEY]] || [self matchTokens:tokens atIndex:index matches:@[SUN_KEY]]) {
            rule.timeRangesArray = [self parseTimeRangeWithTokens:tokens atIndex:&index];
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

-(NSArray *)parseWeekdayRangeWithTokens:(NSArray *)tokens atIndex:(NSInteger *)index
{
    NSMutableArray * weekDayArray = [NSMutableArray array];
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
                    [weekDayArray addObject:weekDay];
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
            
            *index = *index+2;
        }
        else if ([self matchTokens:tokens atIndex:*index matches:@[WEEKDAY_KEY]])
        {
            NSInteger weekDayIndex = [[self weekdaysArray] indexOfObject:((OPEOpeningHoursToken *)tokens[*index]).value];
            NSDateComponents * weekDay = [[NSDateComponents alloc] init];
            weekDay.weekday =weekDayIndex +1;
            [weekDayArray addObject:weekDayArray];
        }
        *index = *index+1;
        
        if (![self matchTokens:tokens atIndex:index matches:@[@","]]) {
            break;
        }
        
    }
    return weekDayArray;
    
}
-(NSArray *)parseTimeRangeWithTokens:(NSArray *)tokens atIndex:(NSInteger *)index
{
    NSMutableArray * timeRangesArray = [NSMutableArray array];
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
            
            [timeRangesArray addObject:timeRange];
            
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
            
            [timeRangesArray addObject:timeRange];
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
            
            [timeRangesArray addObject:timeRange];
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
            
            [timeRangesArray addObject:timeRange];
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
    return timeRangesArray;
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

-(NSString *)stringWithRules:(NSArray *)rulesArray {
    NSMutableArray * resultStrings = [NSMutableArray array];
    [rulesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSMutableArray * ruleStringArray = [NSMutableArray array];
        OPEOpeningHourRule * rule = (OPEOpeningHourRule *)obj;
        if (rule.isTwentyFourSeven) {
            [ruleStringArray addObject:TWENTY_FOUR_SEVEN_STRING];
        }
        
        if ([rule.monthsArray count]) {
            [ruleStringArray addObject:[self stringWithMonthsArray:rule.monthsArray]];
        }
        
        if ([rule.daysOfWeekArray count]) {
            [ruleStringArray addObject:[self stringWithDaysOfWeekArray:rule.daysOfWeekArray]];
        }
        
        if ([rule.timeRangesArray count]) {
            [ruleStringArray addObject:[self stringWithtimeRangesArray:rule.timeRangesArray]];
        }
        
        [resultStrings addObject:[ruleStringArray componentsJoinedByString:@" "]];
        
        
    }];
    return [resultStrings componentsJoinedByString:@"; "];
}

-(NSString *)stringWithMonthsArray:(NSArray *)monthsArray {
    NSMutableArray * stringsArray = [NSMutableArray array];
    
    return [stringsArray componentsJoinedByString:@", "];
}
-(NSString *)stringWithDaysOfWeekArray:(NSArray *)DaysOfWeekArray {
    NSMutableArray * stringsArray = [NSMutableArray array];
    NSArray * sortedArray = [DaysOfWeekArray sortedArrayUsingComparator:^NSComparisonResult(id obj1, id obj2) {
        NSDateComponents * date1 = obj1;
        NSDateComponents * date2 = obj2;
        if (date1.weekday > date2.weekday) {
            return (NSComparisonResult)NSOrderedDescending;
        }
        
        if (date1.weekday < date2.weekday) {
            return (NSComparisonResult)NSOrderedAscending;
        }
        return (NSComparisonResult)NSOrderedSame;
    }];
    
    
    return [stringsArray componentsJoinedByString:@", "];
    
}
-(NSString *)stringWithtimeRangesArray:(NSArray *)timeRangesArray {
    NSMutableArray * stringsArray = [NSMutableArray array];
    
    [timeRangesArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        OPEDateRange * dateRange = (OPEDateRange *)obj;
        [stringsArray addObject:[NSString stringWithFormat:@"%@",dateRange]];
    }];
    
    return [stringsArray componentsJoinedByString:@", "];
}

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

+(NSError *)notSupportedError
{
    NSDictionary * details = @{NSLocalizedDescriptionKey:@"Not Supported"};
    NSError * error = [NSError errorWithDomain:@"Opening Hours" code:200 userInfo:details];
    return error;
}

+(void)test
{
    NSArray * testArray = @[@"Mo Sunrise-Sunset;Tu 08:00-Sunset",@"24/7",@"Mo-We 10:30-15:00",@"Th-Tu 12:00-13:00,14:00-15:00",@"Tu-Su 08:00-15:00;Sa 08:00-12:00"];
    
    [testArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[[OPEOpeningHoursParser alloc] init] parseString:obj success:^(NSArray *blocks) {
            NSLog(@"%@",blocks);
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }];
    
}

@end
