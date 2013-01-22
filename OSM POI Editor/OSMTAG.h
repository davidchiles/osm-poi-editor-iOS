//
//  OSMTAG.h
//  OSM POI Editor
//
//  Created by David on 12/18/12.
//
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface OSMTAG : NSManagedObject

@property (nonatomic, retain) NSString * key;
@property (nonatomic, retain) NSString * value;
@property (nonatomic, retain) NSString * name;

@end
