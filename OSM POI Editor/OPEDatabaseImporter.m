 //
//  OPECoreDataImporter.m
//  OSM POI Editor
//
//  Created by David on 12/18/12.
//
//

#import "OPEDatabaseImporter.h"
#import "OPEConstants.h"
#import "OPEOsmTag.h"
#import "OPEUtility.h"
#import "FMDatabase.h"
#import "FMDatabaseQueue.h"
#import "OSMDatabaseManager.h"
#import "OPELog.h"
#import "OPEDatabaseManager.h"

#define tagsFilePath [[NSBundle mainBundle] pathForResource:@"Tags" ofType:@"json"]
#define optionalPlistFilePath [[NSBundle mainBundle] pathForResource:@"Optional" ofType:@"json"]

@interface OPEDatabaseImporter ()

@property (nonatomic,strong) FMDatabaseQueue * databaseQueue;

@end


@implementation OPEDatabaseImporter

-(FMDatabaseQueue *)databaseQueue
{
    if (!_databaseQueue) {
        _databaseQueue = [OPEDatabaseManager defaultDatabaseQueue];
    }
    return _databaseQueue;
}

-(void)import
{
    [self importSqliteOptionalTags];
    [self importSqlitePoiTags];
}




-(void)importSqliteOptionalSections
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"OptionalCategorySort" ofType:@"json"];
    NSError * error = nil;
    NSData * data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    NSDictionary * optionalDictionary = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        for (NSString * name in optionalDictionary)
        {
            int sortOrer = [optionalDictionary[name] intValue];
            [db executeUpdateWithFormat:@"insert or replace into optional_section(name,sortOrder) values(%@,%d)",name,sortOrer];
        }
    }];
}

-(void)importSqliteOptionalTags
{
    [self importSqliteOptionalSections];
    NSString * filePath = optionalPlistFilePath;
    NSError * error = nil;
    NSData * data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    NSDictionary * optionalDictionary = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        db.logsErrors = OPELogDatabaseErrors;
        
        
        for(NSString * key in optionalDictionary)
        {
            OPEReferenceOptional * optional = [[OPEReferenceOptional alloc] initWithDictionary:optionalDictionary[key] withName:key];
            
            BOOL result = [db executeUpdate:[optional sqliteInsertString]];
            if (result) {
                optional.rowID = [db lastInsertRowId];
                NSString * tagsQuery = [optional sqliteOptionalTagsInsertString];
                if ([tagsQuery length]) {
                    result = [db executeUpdate:tagsQuery];
                }
                
            }
        }
    }];
}
-(void)importSqlitePoiTags
{
    NSString * filePath = tagsFilePath;
    NSError * error = nil;
    NSData * data = [NSData dataWithContentsOfFile:filePath options:NSDataReadingMappedIfSafe error:&error];
    NSDictionary * dictionary = [NSJSONSerialization JSONObjectWithData:data options:nil error:&error];
    [self.databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
        db.logsErrors = OPELogDatabaseErrors;
        db.traceExecution = OPETraceDatabaseTraceExecution;
        
        for(NSString * category in dictionary)
        {
            
            NSDictionary * categoryDictionary = [dictionary objectForKey:category];
            for(NSString * type in categoryDictionary)
            {
                
                NSDictionary * typeDictionary = [categoryDictionary objectForKey:type];
                OPEReferencePoi * poi = [[OPEReferencePoi alloc] initWithName:type withCategory:category andDictionary:typeDictionary];
                BOOL result = [db executeUpdate:[poi sqliteInsertString]];
                
                if (result) {
                    poi.rowID = [db lastInsertRowId];
                    result = [db executeUpdate:[poi sqliteTagsInsertString]];
                    NSString * optionalUpdate = [poi sqliteOptionalInsertString];
                    if (optionalUpdate) {
                        result = [db executeUpdate:optionalUpdate];
                    }
                }
                else
                {
                    DDLogError(@"Failed");
                }
            }
        }
    }];
}

-(NSString *)lastImportHash
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSString * hash = [userDefaults stringForKey:kLastImportHashKey];
    return hash;
    
}
-(double)appVersionNumber
{
    NSString * currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [currentVersion doubleValue];
    
}
-(NSString *)currentFileHash;
{
    NSMutableData * data = [NSMutableData dataWithContentsOfFile:optionalPlistFilePath];
    [data appendData:[NSData dataWithContentsOfFile:tagsFilePath]];
    NSString * hash = [OPEUtility hasOfData:data];
    
    
    
    return hash;
    
}

-(NSDate *)lastImportDate
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    NSDate * date = (NSDate *)[userDefaults stringForKey:kLastImportFileDate];
    return date;
}

-(NSDate *)currentMostRecentFileDate
{
    NSFileManager* fm = [NSFileManager defaultManager];
    NSDictionary* tagsAttrs = [fm attributesOfItemAtPath:tagsFilePath error:nil];
    NSDictionary* optionalAttrs = [fm attributesOfItemAtPath:optionalPlistFilePath error:nil];
    
    if (tagsAttrs != nil || optionalAttrs != nil) {
        NSDate *tagsDate = (NSDate*)[tagsAttrs objectForKey: NSFileCreationDate];
        NSDate *optionalDate = (NSDate *)[optionalAttrs objectForKey:NSFileCreationDate];
        if ([tagsDate compare:optionalDate] == NSOrderedDescending) {
            return tagsDate;
        }
        else
        {
            return optionalDate;
        }
    }
    else {
        DDLogError(@"Not found");
    }
    return nil;
}

-(BOOL)shouldDoImport
{
    double numberOfOptionals = 1;//[[OPEReferenceOptional MR_numberOfEntities] doubleValue];
    double numberOfPOI = 1;//[[OPEReferencePoi MR_numberOfEntities] doubleValue];
    if ([[self lastImportDate] compare:[self currentMostRecentFileDate]] != NSOrderedSame) {
        return YES;
    }
    else if (numberOfOptionals == 0 && numberOfPOI == 0)
    {
        return YES;
    }
    return NO;
}

-(void)setImportVersionNumber
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    [userDefaults setObject:[self currentMostRecentFileDate] forKey:kLastImportFileDate];
    [userDefaults synchronize];
}

@end
