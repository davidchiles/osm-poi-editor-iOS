//
//  OPEOpeningHoursTimeRangesViewController.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEDone+CancelViewController.h"

@interface OPEOpeningHoursTimeRangesViewController : OPEDone_CancelViewController <UITableViewDataSource,UITableViewDelegate>
{
    NSOrderedSet * originalOrderedSet;
}

@property (nonatomic,strong) NSMutableOrderedSet * timeRangesOrderedSet;

-(id)initWithTimeRanges:(NSOrderedSet *)timeRanges;

@end
