//
//  OPEDatabaseManager.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/24/14.
//
//

#import "OPEDatabaseManager.h"

#import "FMDatabaseQueue.h"
#import "OPEConstants.h"
#import "FMDatabase.h"
#import "OSMDatabaseManager.h"

@implementation OPEDatabaseManager

+(BOOL)createDatabaseWithError:(NSError **)error
{
    OSMDatabaseManager * osmData = [[OSMDatabaseManager alloc] initWithFilePath:[OPEConstants databasePath] overrideIfExists:YES];
    //[OSMDatabaseManager initialize];
    osmData = nil;
    __block BOOL result = YES;
    FMDatabaseQueue *queue = [OPEDatabaseManager defaultDatabaseQueue];
    [queue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        
        if (![db executeUpdate:@"DROP TABLE IF EXISTS poi"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"DROP TABLE IF EXISTS optional"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"DROP TABLE IF EXISTS optional_section"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"DROP TABLE IF EXISTS pois_tags"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"DROP TABLE IF EXISTS optionals_tags"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"DROP TABLE IF EXISTS pois_optionals"]) {
            result = NO;
            return;
        }
        
        if (![db executeUpdateWithFormat:@"CREATE TABLE poi(edit_only INTEGER DEFAULT 0,image_string TEXT,is_legacy INTEGER DEFAULT 0,display_name TEXT NOT NULL,category TEXT NOT NULL,UNIQUE(display_name,category))"]) {
            result = NO;
            return;
        }
        if (![db executeUpdateWithFormat:@"CREATE TABLE optional(name TEXT PRIMARY KEY NOT NULL, displayName TEXT NOT NULL, osmKey TEXT,sectionSortOrder INTEGER,type TEXT,section_id INTEGER)"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"CREATE TABLE pois_tags(poi_id INTEGER NOT NULL,key TEXT NOT NULL,value TEXT NOT NULL,UNIQUE(poi_id,key,value))"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"CREATE TABLE optionals_tags(optional_id INTEGER NOT NULL,name TEXT NOT NULL,key TEXT NOT NULL,value TEXT NOT NULL)"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"CREATE TABLE optional_section(name TEXT PRIMARY KEY NOT NULL,sortOrder INTEGER)"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"CREATE TABLE pois_optionals(poi_id INTEGER NOT NULL,optional_id INTEGER NOT NULL,UNIQUE(poi_id,optional_id))"]) {
            result = NO;
            return;
        }
        
        if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS poi_lastUsed(date TEXT,displayName TEXT PRIMARY KEY)"]) {
            result = NO;
            return;
        }
        
        if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS notes(id INTEGER PRIMARY KEY NOT NULL,open INTEGER NOT NULL,lat DOUBLE NOT NULL,lon DOUBLE NOT NULL,date_created TEXT NOT NULL,closed_at TEXT)"]) {
            result = NO;
            return;
        }
        
        if (![db executeUpdate:@"CREATE TABLE IF NOT EXISTS comments (note_id INTEGER NOT NULL REFERENCES notes(id),text TEXT,user_id INTGER,date TEXT NOT NULL,user TEXT,action TEXT)"]) {
            result = NO;
            return;
        }
        
        if (![db executeUpdate:@"ALTER TABLE nodes ADD COLUMN poi_id INTEGER"]) {
            result = NO;
            return;
        }
        
        
        if (![db executeUpdate:@"ALTER TABLE ways ADD COLUMN poi_id INTEGER"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"ALTER TABLE relations ADD COLUMN poi_id INTEGER"]) {
            result = NO;
            return;
        }
        
        if (![db executeUpdate:@"ALTER TABLE nodes ADD COLUMN isVisible INTEGER DEFAULT 1"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"ALTER TABLE ways ADD COLUMN isVisible INTEGER DEFAULT 1"]) {
            result = NO;
            return;
        }
        if (![db executeUpdate:@"ALTER TABLE relations ADD COLUMN isVisible INTEGER DEFAULT 1"]) {
            result = NO;
            return;
        }
    }];
    return result;
}

+(FMDatabaseQueue *)defaultDatabaseQueue
{
    static FMDatabaseQueue *databaseQueue = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        databaseQueue = [FMDatabaseQueue databaseQueueWithPath:[OPEConstants databasePath]];
    });
    
    return databaseQueue;
}

@end
