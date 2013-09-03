//
//  OPEOpeningHoursTimeRangesViewController.h
//  OSM POI Editor
//
//  Created by David on 8/29/13.
//
//

#import "OPEOpeningHoursBaseTimeEditViewController.h"

@class OPEDateComponents;

@interface OPEOpeningHoursTimeRangesViewController : OPEOpeningHoursBaseTimeEditViewController
{
    OPEDateComponents * currentDateComponent;
}

@end
