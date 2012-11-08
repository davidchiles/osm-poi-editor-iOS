//
//  OPEFileUpdater.m
//  OSM POI Editor
//
//  Created by David on 11/7/12.
//
//

#import "OPEFileUpdater.h"

@implementation OPEFileUpdater


-(NSArray *)availableFiles;
{
    PFQuery *query = [PFQuery queryWithClassName:@"files"];
    return [query findObjects];
}


-(BOOL)downloadFiles
{
    NSArray * files = [self availableFiles];
    
    for(PFObject *item in files)
    {
        PFFile * file = [item objectForKey:@"file"];
        NSString * fileName = [item objectForKey:@"name"];
        NSString * fileType = [item objectForKey:@"type"];
        
        NSArray * paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *documentsDirectory = [paths objectAtIndex:0];
        NSString * filePath = [documentsDirectory stringByAppendingPathComponent:[fileName stringByAppendingPathExtension:fileType]];
        
        
        NSData * fileData = [file getData];
        [fileData writeToFile:filePath atomically:YES];
    }
    
    
    return YES;
}








@end
