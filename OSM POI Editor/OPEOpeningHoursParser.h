//
//  OPEOpeningHoursParser.h
//  OSM POI Editor
//
//  Created by David on 8/27/13.
//
//

#import <Foundation/Foundation.h>


@interface OPEDateRange : NSObject

@property (nonatomic,strong) NSDateComponents * startDateComponent;
@property (nonatomic,strong) NSDateComponents * endDateComponent;

@end


@interface OPEOpeningHourRule : NSObject

@property (nonatomic,strong) NSArray * monthsArray;
@property (nonatomic,strong) NSArray * daysOfWeekArray;
@property (nonatomic,strong) NSArray * timeRangesArray;

@end

@interface OPEOpeningHoursParser : NSObject

@property (nonatomic,strong,readonly) NSArray * monthsArray;
@property (nonatomic,strong,readonly) NSArray * weekdaysArray;


-(void)parseString:(NSString *)string
           success:(void (^)(NSArray *blocks))success
           failure:(void (^)(NSError *error))failure;


+(void)test;

@end
