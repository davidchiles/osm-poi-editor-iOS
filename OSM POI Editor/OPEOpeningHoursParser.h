//
//  OPEOpeningHoursParser.h
//  OSM POI Editor
//
//  Created by David on 8/27/13.
//
//

#import <Foundation/Foundation.h>

@interface OPEDateComponents : NSDateComponents

@property (nonatomic) BOOL isSunrise;
@property (nonatomic) BOOL isSunset;

-(NSDate *)date;
-(NSString *)displayString;

+(id)dateComponentWithDate:(NSDate *)date;

@end

@interface OPEDateRange : NSObject

@property (nonatomic,strong) OPEDateComponents * startDateComponent;
@property (nonatomic,strong) OPEDateComponents * endDateComponent;

@end


@interface OPEOpeningHourRule : NSObject

@property (nonatomic,strong) NSMutableOrderedSet * monthsOrderedSet;
@property (nonatomic,strong) NSMutableOrderedSet * daysOfWeekOrderedSet;
@property (nonatomic,strong) NSMutableOrderedSet * timeRangesOrderedSet;
@property (nonatomic,strong) NSMutableOrderedSet * timesOrderedSet;

@property (nonatomic) BOOL isOpen;
@property (nonatomic) BOOL isTwentyFourSeven;

- (BOOL)isEmpty;

@end

@interface OPEOpeningHoursParser : NSObject

@property (nonatomic,strong,readonly) NSArray * monthsArray;
@property (nonatomic,strong,readonly) NSArray * weekdaysArray;


-(void)parseString:(NSString *)string
           success:(void (^)(NSArray *blocks))success
           failure:(void (^)(NSError *error))failure;

-(NSString *)stringWithRules:(NSArray *)rulesArray;
-(NSString *)stringWithRule:(OPEOpeningHourRule *)rule;
-(NSString *)stringWithTimeRangesOrderedSet:(NSOrderedSet *)timeRangesOrderedSet;
-(NSString *)stringWithMonthsOrderedSet:(NSOrderedSet *)monthsOrderedSet;
-(NSString *)stringWithDaysOfWeekOrderedSet:(NSOrderedSet *)daysOfWeekOrderedSet;


+(void)test;

@end
