//
//  OPEUserTrackingBarButtonItem.h
//  OSM POI Editor
//
//  Created by David on 11/1/12.
//
//

#import <UIKit/UIKit.h>

@class RMMapView;

@interface OPEUserTrackingBarButtonItem : UIBarButtonItem

/** @name Initializing */

/** Initializes a newly created bar button item with the specified map view.
 *   @param mapView The map view used by this bar button item.
 *   @return The initialized bar button item. */
- (id)initWithMapView:(RMMapView *)mapView;

/** @name Accessing Properties */

/** The map view associated with this bar button item. */
@property (nonatomic, retain) RMMapView *mapView;

@end
