//
//  OPENotesDatabase.m
//  OSM POI Editor
//
//  Created by David Chiles on 3/26/14.
//
//

#import "OPENotesDatabase.h"
#import "OPEDatabaseManager.h"
#import "FMDatabaseQueue.h"
#import "FMDatabase.h"

#import "OSMNote.h"
#import "OSMComment.h"
#import "OSMElement.h"


@implementation OPENotesDatabase

+ (void)saveNote:(OSMNote *)note completion:(void (^)(BOOL))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block BOOL sucess = NO;
        FMDatabaseQueue *databaseQueue = [OPEDatabaseManager defaultDatabaseQueue];
        [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
            
            sucess = [db executeUpdateWithFormat:@"INSERT OR REPLACE INTO notes (id,open,lat,lon,date_created,date_closed) VALUES (%lld,%d,%d,%d,%@,%@)",note.id,note.isOpen,note.coordinate.latitude,note.coordinate.longitude,note.dateCreated,note.dateClosed];
            
            BOOL commentSuccess = YES;
            for (OSMComment *comment in note.commentsArray) {
                BOOL tempSuccess = [db executeQueryWithFormat:@"INSERT OR REPLACE INTO comments (note_id,text,user_id,date,user,action) VALUES (%lld,%@,%lld,%@,%@,%@)",note.id,comment.text,comment.userID,comment.date,comment.username,comment.action];
                if(!tempSuccess) {
                    commentSuccess = tempSuccess;
                }
            }
            
            if(!sucess || !commentSuccess) {
                sucess = NO;
                rollback = YES;
            }
            
        }];
        if(completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(sucess);
            });
        }
    });
}

+ (void)saveNotes:(NSArray *)notes completion:(void(^)(BOOL success))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        
        __block BOOL sucess = NO;
        FMDatabaseQueue *databaseQueue = [OPEDatabaseManager defaultDatabaseQueue];
        for (OSMNote *note in notes) {
            [databaseQueue inTransaction:^(FMDatabase *db, BOOL *rollback) {
                
                sucess = [db executeUpdateWithFormat:@"INSERT OR REPLACE INTO notes (id,open,lat,lon,date_created,date_closed) VALUES (%lld,%d,%d,%d,%@,%@)",note.id,note.isOpen,note.coordinate.latitude,note.coordinate.longitude,[self stringWithDate:note.dateCreated],[self stringWithDate:note.dateClosed]];
                
                BOOL commentSuccess = YES;
                for (OSMComment *comment in note.commentsArray) {
                    BOOL tempSuccess = [db executeQueryWithFormat:@"INSERT OR REPLACE INTO comments (note_id,text,user_id,date,user,action) VALUES (%lld,%@,%lld,%@,%@,%@)",note.id,comment.text,comment.userID,[self stringWithDate:comment.date],comment.username,comment.action];
                    if(!tempSuccess) {
                        commentSuccess = tempSuccess;
                    }
                }
                
                if(!sucess || !commentSuccess) {
                    sucess = NO;
                    rollback = YES;
                }
                
            }];
        }
        if(completion)
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(sucess);
            });
        }
    });
}

+ (void)fetchNoteWithID:(int64_t)noteID completion:(void (^)(OSMNote *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block OSMNote *note = nil;
        
        FMDatabaseQueue *databaseQueue = [OPEDatabaseManager defaultDatabaseQueue];
        [databaseQueue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *noteReultSet = [db executeQueryWithFormat:@"SELECT * FROM notes WHERE id=%lld LIMIT 1",noteID];
            FMResultSet *commentResultSet = [db executeQueryWithFormat:@"SELECT * FROM comments WHERE note_id=%lld ORDER BY datetime(date)",noteID];
            
            while ([noteReultSet next]) {
                note = [self noteWithDictinoary:[noteReultSet resultDictionary]];
            }
            
            NSMutableArray *commentArray = [NSMutableArray array];
            while([commentResultSet next]) {
                OSMComment *comment = [self commentWithDictionary:[commentResultSet resultDictionary]];
                [commentArray addObject:comment];
            }
            note.commentsArray = [commentArray copy];
        }];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(note);
            });
        }
    });
}

+ (void)allNotesCompletion:(void (^)(NSArray *))completion
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        __block NSArray *notesArray = nil;
        
        FMDatabaseQueue *databaseQueue = [OPEDatabaseManager defaultDatabaseQueue];
        [databaseQueue inDatabase:^(FMDatabase *db) {
            
            FMResultSet *resultSet = [db executeQueryWithFormat:@"SELECT * FROM notes"];
            FMResultSet *commentResultSet = [db executeQueryWithFormat:@"@SELECT * FROM comments ORDER BY datetime(date)"];
            
            NSMutableDictionary *noteDictionary = [NSMutableDictionary dictionary];
            while ([resultSet next]) {
                OSMNote * note = [self noteWithDictinoary:[resultSet resultDictionary]];
                
                [noteDictionary setObject:note forKey:@(note.id)];
            }
            
            while ([commentResultSet next]) {
                OSMComment *comment = [self commentWithDictionary:[resultSet resultDictionary]];
                int64_t noteId = [commentResultSet longLongIntForColumn:@"note_id"];
                
                OSMNote *note = noteDictionary[@(noteId)];
                if(!note.commentsArray) {
                    note.commentsArray = @[comment];
                }
                else {
                    note.commentsArray = [note.commentsArray arrayByAddingObject:comment];
                }
            }
            
            notesArray = [noteDictionary allValues];
        }];
        
        if (completion) {
            dispatch_async(dispatch_get_main_queue(), ^{
                completion(notesArray);
            });
        }
    });
    
}

+ (OSMNote *)noteWithDictinoary:(NSDictionary *)dictionary
{
    OSMNote *note = [[OSMNote alloc] init];
    note.id = [[dictionary objectForKey:@"id"] longLongValue];
    note.isOpen = [[dictionary objectForKey:@"open"] boolValue];
    note.coordinate = CLLocationCoordinate2DMake([[dictionary objectForKey:@"lat"] doubleValue], [[dictionary objectForKey:@"lon"] doubleValue]);
    note.dateCreated = [self dateWithString:dictionary[@"date_created"]];
    note.dateClosed = [self dateWithString:dictionary[@"date_closed"]];
    return note;
}

+ (OSMComment *)commentWithDictionary:(NSDictionary *)dictionary
{
    OSMComment *comment = [[OSMComment alloc] init];
    comment.text = dictionary[@"text"];
    comment.username = dictionary[@"username"];
    comment.userID = [dictionary[@"user_id"] longLongValue];
    comment.action = dictionary[@"action"];
    comment.date = [self dateWithString:dictionary[@"date"]];
    return comment;
}

+ (NSString *)stringWithDate:(NSDate *)date
{
    if (date) {
        NSDateFormatter *dateFormatter = [OSMElement defaultDateFormatter];
        return [dateFormatter stringFromDate:date];
    }
    return nil;
}

+(NSDate *)dateWithString:(NSString *)dateString;
{
    if (dateString != (id)[NSNull null] || [dateString length]) {
        NSDateFormatter *dateFormatter = [OSMElement defaultDateFormatter];
        return [dateFormatter dateFromString:dateString];
    }
    return nil;
    
}



@end
