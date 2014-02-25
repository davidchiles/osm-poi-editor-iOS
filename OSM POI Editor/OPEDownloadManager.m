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

#import "OPEOsmWay.h"
#import "OPEUtility.h"
#import "OPEGeo.h"
#import "OPEDatabaseManager.h"

#import "OPELog.h"

@interface OPEDownloadManager ()

@property (nonatomic, strong) OPEOSMData * osmData;
@property (nonatomic, strong) OPEOSMAPIManager * apiManager;
@property (nonatomic, strong) NSOperationQueue * parseQueue;

@end

@implementation OPEDownloadManager

-(id)init {
    if (self = [super init]) {
        self.osmData = [[OPEOSMData alloc] init];
        self.apiManager = [[OPEOSMAPIManager alloc] init];
        self.dowloadedAreas = [NSMutableSet set];
        self.notesDictionary = [NSMutableDictionary dictionary];
        self.parseQueue = [[NSOperationQueue alloc] init];
        self.parseQueue.maxConcurrentOperationCount = 1;
    }
    return self;
}


- (void)downloadDataWithSW:(CLLocationCoordinate2D)southWest
                     forNE: (CLLocationCoordinate2D) northEast
           didStartParsing:(void (^)(void))startParsing
          didFinsihParsing:(void (^)(void))finishParsing
                    faiure:(void (^)(NSError * error))failure {
    
    [self.apiManager downloadDataWithSW:southWest NE:northEast success:^(NSData *response) {
        [self.dowloadedAreas addObject:[OPEBoundingBox boundingBoxSW:southWest NE:northEast]];
        if (startParsing) {
            startParsing();
        }
        
        OSMParser* parser = [[OSMParser alloc] initWithOSMData:response];
        OSMParserHandlerDefault* handler = [[OSMParserHandlerDefault alloc] initWithDatabaseQueue:[OPEDatabaseManager defaultDatabaseQueue]];
        parser.delegate=handler;
        handler.databaseManager.delegate = self;
        
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
    
    [self.apiManager downloadNotesWithSW:southWest NE:northEast success:^(id response) {
        //NSString* newStr = [[NSString alloc] initWithData:response encoding:NSUTF8StringEncoding];
        
        [self.parseQueue addOperationWithBlock:^{
            dispatch_async(dispatch_get_main_queue(),startParsing);
            __block NSMutableArray * newNotes = [NSMutableArray array];
            NSArray * notes = [response objectForKey:@"features"];
            [notes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
                NSDictionary * noteDictionary = (NSDictionary *)obj;
                NSDictionary * propertiesDictionary = noteDictionary[@"properties"];
                if (![self.notesDictionary objectForKey: @([propertiesDictionary[@"id"] longLongValue])]) {
                    OSMNote * note = [self.osmData createNoteWithJSONDictionary:noteDictionary];
                    [self.notesDictionary setObject:note forKey:@(note.id)];
                    [newNotes addObject:note];
                }
                
                
                DDLogInfo(@"%@",obj);
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

//OSMDatabaseManagerDelegate Mehtod
-(void)didFinishSavingNewElements:(NSArray *)newElements updatedElements:(NSArray *)updatedElements
{
    __block NSArray * newMatchedElements = nil;
    __block NSArray * updatedMatchedElements = nil;
    
    //match new elements
    [self.osmData findType:newElements completion:^(NSArray *foundElements) {
        dispatch_async(dispatch_get_main_queue(), ^{
            newMatchedElements = foundElements;
            self.foundMatchingElementsBlock(newMatchedElements,updatedMatchedElements);
        });
    }];
    
    //match updated elements in case any tags have changed enough to change type
    [self.osmData findType:updatedElements completion:^(NSArray *foundElements) {
        dispatch_async(dispatch_get_main_queue(), ^{
            updatedMatchedElements = foundElements;
            self.foundMatchingElementsBlock(newMatchedElements,updatedMatchedElements);
        });
    }];
    
    
    
    
    
}

@end
