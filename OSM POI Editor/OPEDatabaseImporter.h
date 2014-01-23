//
//  OPECoreDataImporter.h
//  OSM POI Editor
//
//  Created by David on 12/18/12.
//
//

#import <Foundation/Foundation.h>
#import "OPEReferenceOsmTag.h"
#import "OPEReferenceOptional.h"
#import "OPEReferencePoi.h"
#import "FMDatabaseQueue.h"

@interface OPEDatabaseImporter : NSObject
{
    FMDatabaseQueue *queue;
}


-(void)import;

@end
