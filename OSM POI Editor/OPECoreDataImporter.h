//
//  OPECoreDataImporter.h
//  OSM POI Editor
//
//  Created by David on 12/18/12.
//
//

#import <Foundation/Foundation.h>
#import "OPEManagedReferenceOsmTag.h"
#import "OPEManagedReferenceOptional.h"
#import "OPEManagedReferencePoi.h"
#import "FMDatabaseQueue.h"

@interface OPECoreDataImporter : NSObject
{
    FMDatabaseQueue *queue;
}


-(void)import;

@end
