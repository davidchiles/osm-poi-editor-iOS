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
#import "OPEGeo.h"

@implementation OPEDownloadManager

@synthesize dowloadedAreas,foundMatchingElementsBlock,notesDictionary;


-(id)init {
    if (self = [super init]) {
        osmData = [[OPEOSMData alloc] init];
        apiManager = [[OPEOSMAPIManager alloc] init];
        self.dowloadedAreas = [NSMutableSet set];
        self.notesDictionary = [NSMutableDictionary dictionary];
        parseQueue = [[NSOperationQueue alloc] init];
        parseQueue.maxConcurrentOperationCount = 1;
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
        OSMParserHandlerDefault* handler = [[OSMParserHandlerDefault alloc] initWithOutputFilePath:[OPEConstants databasePath] overrideIfExists:NO];
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
           didFinsihParsing:(void (^)(NSArray * newNotes))finishParsing
                     faiure:(void (^)(NSError * error))failure {
    
    [apiManager downloadNotesWithSW:southWest NE:northEast success:^(id response) {
        //NSString* newStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        [parseQueue addOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(),startParsing);
            __block NSMutableArray * newNotes = [NSMutableArray array];
            NSArray * notes = [response objectForKey:@"features"];
            [notes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary * noteDictionary = (NSDictionary *)obj;
                NSDictionary * propertiesDictionary = noteDictionary[@"properties"];
                if (![self.notesDictionary objectForKey: @([propertiesDictionary[@"id"] longLongValue])]) {
                    Note * note = [osmData createNoteWithJSONDictionary:noteDictionary];
                    [self.notesDictionary setObject:note forKey:@(note.id)];
                    [newNotes addObject:note];
                }
                
                
                NSLog(@"%@",obj);
                dispatch_async(dispatch_get_main_queue(), ^{
                    if (finishParsing) {
                        finishParsing(newNotes);
                    }
                });
            }];
        }];
        
        
    } failure:^(NSError *error) {
        
        dispatch_async(dispatch_get_main_queue(),^{
            if (failure) {
                failure(error);
            }
        });
    }];
    
    
    
}

- (BOOL)downloadedAreaContainsPoint:(CLLocationCoordinate2D)point {
    __block BOOL result = NO;
    [self.dowloadedAreas enumerateObjectsUsingBlock:^(id obj, BOOL *stop) {
        OPEBoundingBox * box = (OPEBoundingBox *)obj;
        if ([OPEGeo boundingBox:box containsPoint:point]) {
            result = YES;
            stop = YES;
        }
    }];
    return result;
}

//OSMDAODelegate Mehtod
-(void)didFinishSavingNewElements:(NSArray *)newElements updatedElements:(NSArray *)updatedElements
{
    __block NSArray * newMatchedElements;
    __block NSArray * updatedMatchedElements;
    
    //match new elements
    [osmData findType:newElements completion:^(NSArray *foundElements) {
        newMatchedElements = foundElements;
    }];
    
    //match updated elements in case any tags have changed enough to change type
    [osmData findType:updatedElements completion:^(NSArray *foundElements) {
        updatedMatchedElements = foundElements;
    }];
    
    dispatch_async(dispatch_get_main_queue(), ^{
        self.foundMatchingElementsBlock(newMatchedElements,updatedMatchedElements);
    });
    
    
    
}

@end
