//
//  OPEChangeset.h
//  OSM POI Editor
//
//  Created by David on 3/13/13.
//
//

#import <Foundation/Foundation.h>

@class OPEOsmElement;

@interface OPEChangeset : NSObject


@property (nonatomic, strong) NSMutableArray * nodes;
@property (nonatomic, strong) NSMutableArray * ways;
@property (nonatomic, strong) NSMutableArray * relations;
@property (nonatomic) int64_t changesetID;
@property (nonatomic, strong) NSString * message;
@property (nonatomic, strong) NSMutableDictionary * tags;

-(void)addElement:(OPEOsmElement *)element;
-(BOOL)hasNodes;
-(BOOL)hasWays;
-(BOOL)hasRelations;
-(NSString *)xml;
@end
