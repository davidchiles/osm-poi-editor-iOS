//
//  OPEManagedOsmNode.m
//  OSM POI Editor
//
//  Created by David on 1/21/13.
//
//

#import "OPEManagedOsmNode.h"


@implementation OPEManagedOsmNode

@dynamic lattitude;
@dynamic longitude;


-(CLLocationCoordinate2D) center
{
    return CLLocationCoordinate2DMake([self.lattitude doubleValue], [self.longitude doubleValue]);
}

@end
