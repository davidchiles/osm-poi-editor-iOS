//
//  OPEFileUpdater.m
//  OSM POI Editor
//
//  Created by David on 11/7/12.
//
//

#import "OPEFileUpdater.h"
#import "OPEConstants.h"

@implementation OPEFileUpdater


-(NSArray *)availableFiles;
{
    PFQuery *query = [PFQuery queryWithClassName:@"files"];
    return [query findObjects];
}


-(BOOL)downloadFiles
{
    NSDate * lastDownload = [[NSUserDefaults standardUserDefaults] objectForKey:kLastDownloadedKey];
    
    if (!lastDownload || [[NSDate date] timeIntervalSinceDate:lastDownload]>(60.0*60.0*24.0*7.0)) {
    
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
        [[NSUserDefaults standardUserDefaults] setObject:[NSDate date] forKey:kLastDownloadedKey];
        return YES;
    }
    
    return NO;
    
}








@end
