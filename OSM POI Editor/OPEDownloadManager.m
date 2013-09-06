//
//  OPEDownloadManager.m
//  OSM POI Editor
//
//  Created by David on 9/6/13.
//
//

#import "OPEDownloadManager.h"


#import "OSMParser.h"
#import "OSMParserHandlerDefault.h"

#import "OPEManagedOsmWay.h"
#import "OPEUtility.h"

@implementation OPEDownloadManager

@synthesize dowloadedAreas,foundMatchingElementsBlock;


-(id)init {
    if (self = [super init]) {
        osmData = [[OPEOSMData alloc] init];
        apiManager = [[OPEOSMAPIManager alloc] init];
        self.dowloadedAreas = [NSMutableSet set];
        parseQueue = [[NSOperationQueue alloc] init];
        parseQueue.maxConcurrentOperationCount = 2;
    }
    return self;
}


- (void)downloadDataWithSW:(CLLocationCoordinate2D)southWest
                     forNE: (CLLocationCoordinate2D) northEast
           didStartParsing:(void (^)(void))startParsing
          didFinsihParsing:(void (^)(void))finishParsing
                    faiure:(void (^)(NSError * error))failure {
    
    [apiManager downloadDataWithSW:southWest NE:northEast success:^(NSData *response) {
        [self.dowloadedAreas addObject:[OPEBoundingBox boundingBoxSW:southWest NE:northEast]];
        if (startParsing) {
            startParsing();
        }
        
        OSMParser* parser = [[OSMParser alloc] initWithOSMData:response];
        OSMParserHandlerDefault* handler = [[OSMParserHandlerDefault alloc] initWithOutputFilePath:kDatabasePath overrideIfExists:NO];
        parser.delegate=handler;
        handler.outputDao.delegate = self;
        
        [parser parseWithCompletionBlock:^{
            if (finishParsing) {
                dispatch_async(dispatch_get_main_queue(), finishParsing);
            }
        }];
        
        
    } failure:^(NSError *error) {
        if (failure) {
            failure(error);
        }
    }];
    
    
}

- (void)downloadNotesWithSW:(CLLocationCoordinate2D)southWest
                      forNE: (CLLocationCoordinate2D) northEast
            didStartParsing:(void (^)(void))startParsing
           didFinsihParsing:(void (^)(NSArray * newElements, NSArray * updatedElements))finishParsing
                     faiure:(void (^)(NSError * error))failure {
    
    
    
}

- (BOOL)downloadedAreaContainsPoint:(CLLocationCoordinate2D)point {
    __block BOOL result = NO;
    [self.dowloadedAreas enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        OPEBoundingBox * box = (OPEBoundingBox *)obj;
        if ([box containsPoint:point]) {
            result = YES;
            stop = YES;
        }
    }];
    return result;
}

//OSMDAODelegate Mehtod
-(void)didFinishSavingNewElements:(NSArray *)newElements updatedElements:(NSArray *)updatedElements
{
    NSMutableArray * newMatchedElements = [NSMutableArray array];
    NSMutableArray * updatedMatchedElements = [NSMutableArray array];
    
    BOOL showNoNameStreets = [[OPEUtility currentValueForSettingKey:kShowNoNameStreetsKey] boolValue];
    
    //match new elements
    for(Element * element in newElements)
    {
        if ([element.tags count]) {
            OPEManagedOsmElement * managedElement = [OPEManagedOsmElement elementWithBasicOsmElement:element];
            if([osmData findType:managedElement])
            {
                [newMatchedElements addObject: managedElement];
            }
            else if (showNoNameStreets && [managedElement isKindOfClass:[OPEManagedOsmWay class]]) {
                if([osmData isNoNameStreet:(OPEManagedOsmWay *)managedElement])
                {
                    [newMatchedElements addObject:managedElement];
                }
            }
        }
    }
    //match updated elements in case any tags have changed enough to change type
    for(Element * element in updatedElements)
    {
        if ([element.tags count]) {
            OPEManagedOsmElement * managedElement = [OPEManagedOsmElement elementWithBasicOsmElement:element];
            if([osmData findType:managedElement])
            {
                [updatedMatchedElements addObject: managedElement];
            }
            else if (showNoNameStreets && [managedElement isKindOfClass:[OPEManagedOsmWay class]]) {
                if([osmData isNoNameStreet:(OPEManagedOsmWay *)managedElement])
                {
                    [updatedMatchedElements addObject:managedElement];
                }
            }
        }
    }
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.foundMatchingElementsBlock(newMatchedElements,updatedMatchedElements);
    });
    
    
    
}

@end
