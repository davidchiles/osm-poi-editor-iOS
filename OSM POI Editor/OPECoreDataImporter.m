//
//  OPECoreDataImporter.m
//  OSM POI Editor
//
//  Created by David on 12/18/12.
//
//

#import "OPECoreDataImporter.h"
#import "OPEOptionalTag.h"
#import "CoreData+MagicalRecord.h"
#import "OPEConstants.h"
#import "OPEManagedOsmTag.h"
#import "OPEManagedReferenceOptionalCategory.h"


@implementation OPECoreDataImporter
@synthesize managedObjectContext;

-(void)importTagsPlist
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Tags" ofType:@"plist"];
    NSDictionary* plistDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    for(NSString * category in plistDict)
    {
        NSDictionary * categoryDictionary = [plistDict objectForKey:category];
        for(NSString * type in categoryDictionary)
        {
            NSDictionary * typeDictionary = [categoryDictionary objectForKey:type];
            NSString *imageString = [typeDictionary objectForKey:@"image"];
            NSDictionary * tags = [typeDictionary objectForKey:@"tags"];
            NSArray * optionalTags = [typeDictionary objectForKey:@"optional"];
            
            [self addPOIWithName:type category:category imageString:imageString legacy:NO optional:optionalTags tags:tags];
            
        }
    }
    NSLog(@"Number of POIs: %u",[[OPEManagedOsmTag MR_findAll] count]);
}

-(void)importOptionalSection
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"OptionalCategorySort" ofType:@"plist"];
    NSDictionary* optionalDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    for (NSString * name in optionalDictionary)
    {
        [OPEManagedReferenceOptionalCategory fetchOrCreateWithName:name sortOrder:[[optionalDictionary objectForKey:name] intValue]];
    }
    
    
}

-(void)importOptionalTags
{
    [self importOptionalSection];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Optional" ofType:@"plist"];
    NSDictionary* optionalDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    for(NSString * key in optionalDictionary)
    {
        OPEOptionalTag * optionalTag = [[OPEOptionalTag alloc] initWithName:key dictionary:[optionalDictionary objectForKey:key]];
        
        
        
        [self addOptionalWithName:key displayName:optionalTag.displayName section:optionalTag.section sectionSortOrder:optionalTag.sectionSortOrder osmkey:optionalTag.osmKey values:optionalTag.possibleValues];
    }
    [self addOptionalWithName:@"note" displayName:@"Note" section:@"Note" sectionSortOrder:[NSNumber numberWithInt:1] osmkey:@"note" values:nil];
    [self addOptionalWithName:@"source" displayName:@"Source" section:@"Note" sectionSortOrder:[NSNumber numberWithInt:2] osmkey:@"source" values:nil];
    
}

-(void)addPOIWithName:(NSString *)name  category:(NSString *)category imageString:(NSString *)imageString legacy:(BOOL )isLegacy optional:(NSArray *)optionalTags tags:(NSDictionary *) tagDictionary
{
    BOOL didCreate;
    OPEManagedReferencePoi * newPoi = [OPEManagedReferencePoi fetchOrCreateWithName:name category:category didCreate:&didCreate];
    
    if (didCreate) {
        newPoi.name = name;
        newPoi.isLegacy = [NSNumber numberWithBool:isLegacy];
        newPoi.imageString = imageString;
        newPoi.category = category;
        
        NSMutableSet * optionalSet = [NSMutableSet set];
        for(NSString * optionalString in optionalTags)
        {
            if([optionalString isEqualToString:@"address"])
            {
                NSArray * exppandedAddress = kExpandedAddressArray;
                for(NSString * addressString in exppandedAddress)
                {
                    didCreate = NO;
                    OPEManagedReferenceOptional * optional = [OPEManagedReferenceOptional fetchOrCreateWithName:addressString didCreate:&didCreate];
                    if (!didCreate) {
                        [optionalSet addObject:optional];
                    }
                }
            }
            else
            {
                didCreate = NO;
                OPEManagedReferenceOptional * optional = [OPEManagedReferenceOptional fetchOrCreateWithName:optionalString didCreate:&didCreate];
                if (!didCreate) {
                    [optionalSet addObject:optional];
                }
            }
        }
        OPEManagedReferenceOptional * optionalNote = [OPEManagedReferenceOptional fetchOrCreateWithName:@"note" didCreate:&didCreate];
        if (!didCreate) {
            [optionalSet addObject:optionalNote];
        }
        OPEManagedReferenceOptional * optionalSource = [OPEManagedReferenceOptional fetchOrCreateWithName:@"source" didCreate:&didCreate];
        if (!didCreate) {
            [optionalSet addObject:optionalSource];
        }
        [newPoi setOptional:optionalSet];
        
        NSMutableSet * osmTagSet = [NSMutableSet set];
        for (NSString * key in tagDictionary)
        {
            [osmTagSet addObject:[OPEManagedOsmTag fetchOrCreateWithKey:key value:[tagDictionary objectForKey:key]]];
        }
        [newPoi setTags:osmTagSet];
    }
    
    
    
   /* NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    */

}

-(OPEManagedReferenceOptional *)addOptionalWithName:(NSString *)name displayName:(NSString *)displayName section:(NSString *)section sectionSortOrder:(NSNumber *)sectionSortOrder osmkey:(NSString *)osmKey values:(NSDictionary *)tagValues
{
    //OPTIONAL * newOptional = [NSEntityDescription insertNewObjectForEntityForName:OPTIONALEntity inManagedObjectContext:managedObjectContext];
    NSLog(@"Tag Values: %@",tagValues);
    BOOL didCreate = NO;
    
    OPEManagedReferenceOptional * newOptional = [OPEManagedReferenceOptional fetchOrCreateWithName:name didCreate:&didCreate];
    
    if (didCreate) {
        newOptional.name = name;
        newOptional.displayName = displayName;
        [newOptional setReferenceSection:[OPEManagedReferenceOptionalCategory fetchWithName:section]];
        newOptional.sectionSortOrder = sectionSortOrder;
        newOptional.osmKey = osmKey;
        NSMutableSet * osmTags = [NSMutableSet set];
        
        
        
        for(NSString * value in tagValues)
        {
            
            OPEManagedReferenceOsmTag * tag = [OPEManagedReferenceOsmTag fetchOrCreateWithName:value key:osmKey value:[tagValues objectForKey:value]];
            [osmTags addObject: tag];
        }
        [newOptional setTags:osmTags];
        
        NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
        [context MR_saveToPersistentStoreAndWait];
    }
    
    return newOptional;
}

@end
