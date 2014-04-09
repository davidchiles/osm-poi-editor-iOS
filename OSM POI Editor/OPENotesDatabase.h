//
//  OPENotesDatabase.h
//  OSM POI Editor
//
//  Created by David Chiles on 3/26/14.
//
//

#import <Foundation/Foundation.h>

@class OSMNote;

@interface OPENotesDatabase : NSObject

+ (void)saveNote:(OSMNote *)note completion:(void(^)(BOOL success))comletion;
+ (void)saveNotes:(NSArray *)notes completion:(void(^)(BOOL success))comletion;
+ (void)fetchNoteWithID:(int64_t)noteID completion:(void(^)(OSMNote *note))completion;

+ (void)allNotesCompletion:(void(^)(NSArray *notes))completion;

@end
