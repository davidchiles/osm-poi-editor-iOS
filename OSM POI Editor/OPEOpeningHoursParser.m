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

#import "OPEOpeningHoursParser.h"

@implementation OPEDateRange

@synthesize startDateComponent,endDateComponent;

-(NSString *)description
{
    return [NSString stringWithFormat:@"%d:%d - %d:%d",startDateComponent.hour,startDateComponent.minute,endDateComponent.hour,endDateComponent.minute];
}

@end

@implementation OPEOpeningHourRule

@synthesize monthsArray,daysOfWeekArray,timeRangesArray;

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
    
    
    NSLog(@"blocks: %@",blocks);
    
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
        else if ([self matchTokens:tokens atIndex:index matches:@[NUMBER_KEY,TIME_SEPERATOR_KEY]]) {
            rule.timeRangesArray = [self parseTimeRangeWithTokens:tokens atIndex:&index];
        }
        else if ([self matchTokens:tokens atIndex:index matches:@[TWENTY_FOUR_SEVEN_STRING]]) {
            
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
            
            
            NSDateComponents * startTimeComponent = [[NSDateComponents alloc] init];
            startTimeComponent.hour = [((OPEOpeningHoursToken *)tokens[*index]).value intValue];
            startTimeComponent.minute = [((OPEOpeningHoursToken *)tokens[*index+2]).value intValue];
            
            NSDateComponents * endTimeComponent = [[NSDateComponents alloc] init];
            endTimeComponent.hour = [((OPEOpeningHoursToken *)tokens[*index+4]).value intValue];
            endTimeComponent.minute = [((OPEOpeningHoursToken *)tokens[*index+6]).value intValue];
            
            OPEDateRange * timeRange = [[OPEDateRange alloc] init];
            timeRange.startDateComponent = startTimeComponent;
            timeRange.endDateComponent = endTimeComponent;
            
            [timeRangesArray addObject:timeRange];
            
            *index = *index+7;
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
    NSArray * testArray = @[@"24/7",@"Mo-We 10:30-15:00",@"Th-Tu 12:00-13:00,14:00-15:00",@"Tu-Su 08:00-15:00;Sa 08:00-12:00"];
    
    [testArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        [[[OPEOpeningHoursParser alloc] init] parseString:obj success:^(NSArray *blocks) {
            NSLog(@"%@",blocks);
        } failure:^(NSError *error) {
            NSLog(@"%@",error);
        }];
    }];
    
}

@end
