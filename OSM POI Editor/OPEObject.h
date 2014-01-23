//
//  OPEObject.h
//  OSM POI Editor
//
//  Created by David on 4/25/13.
//
//

#import <Foundation/Foundation.h>
#import "FMDatabaseQueue.h"
#import "FMResultSet.h"
#import "OPEConstants.h"

@interface OPEObject : NSObject

@property (nonatomic) int64_t rowID;

-(void)loadWithResult:(FMResultSet *)set;
-(NSString *)sqliteInsertString;

@end
