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
#import "OPEManagedReferencePoiCategory.h"


@implementation OPECoreDataImporter

-(void)import
{
    if ([self shouldDoImport]) {
        [self importOptionalTags];
        [self importTagsPlist];
        [self setImportVersionNumber];
    }
    
}

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
            
            BOOL legacy = ([type rangeOfString:@" (legacy)"].location != NSNotFound);
            
            [self addPOIWithName:type category:category imageString:imageString legacy:legacy optional:optionalTags tags:tags];
            
        }
    }
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
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
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
    
    
}

-(void)importOptionalTags
{
    [self lastImportVersion];
    [self importOptionalSection];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Optional" ofType:@"plist"];
    NSDictionary* optionalDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    for(NSString * key in optionalDictionary)
    {
        [self importOptionalDictionary:[optionalDictionary objectForKey:key] name:key];
    }
    [self addOptionalWithName:@"note" displayName:@"Note" section:@"Note" sectionSortOrder:[NSNumber numberWithInt:1] osmkey:@"note" values:nil type:kTypeText];
    [self addOptionalWithName:@"source" displayName:@"Source" section:@"Note" sectionSortOrder:[NSNumber numberWithInt:2] osmkey:@"source" values:nil type:kTypeText];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_contextForCurrentThread];
    [context MR_saveToPersistentStoreAndWait];
    
}

-(void)addPOIWithName:(NSString *)name  category:(NSString *)category imageString:(NSString *)imageString legacy:(BOOL )isLegacy optional:(NSArray *)optionalTags tags:(NSDictionary *) tagDictionary
{
    BOOL didCreate;
    OPEManagedReferencePoiCategory * poiCategory = [OPEManagedReferencePoiCategory fetchOrCreateWithName:category];
    OPEManagedReferencePoi * newPoi = [OPEManagedReferencePoi fetchOrCreateWithName:name category:poiCategory didCreate:&didCreate];
    
    
    newPoi.name = name;
    newPoi.isLegacy = [NSNumber numberWithBool:isLegacy];
    newPoi.imageString = imageString;
    [newPoi setCanAddValue:YES];
    
    if (isLegacy) {
        NSString * newName = [name componentsSeparatedByString:@" (legacy)"][0];
        newPoi.newTagMethod = [OPEManagedReferencePoi fetchOrCreateWithName:newName category:poiCategory didCreate:&didCreate];
    }
    
    newPoi.category = [OPEManagedReferencePoiCategory fetchOrCreateWithName:category];
    
    for(NSString * optionalString in optionalTags)
    {
        OPEManagedReferenceOptional * optional;
        if([optionalString isEqualToString:@"address"])
        {
            NSArray * exppandedAddress = kExpandedAddressArray;
            for(NSString * addressString in exppandedAddress)
            {
                didCreate = NO;
                optional = [OPEManagedReferenceOptional fetchOrCreateWithName:addressString didCreate:&didCreate];
            }
        }
        else
        {
            optional = [OPEManagedReferenceOptional fetchOrCreateWithName:optionalString didCreate:&didCreate];
        }
        [newPoi addOptionalObject:optional];
    }
    OPEManagedReferenceOptional * optionalNote = [OPEManagedReferenceOptional fetchOrCreateWithName:@"note" didCreate:&didCreate];
    [newPoi addOptionalObject:optionalNote];
    OPEManagedReferenceOptional * optionalSource = [OPEManagedReferenceOptional fetchOrCreateWithName:@"source" didCreate:&didCreate];
    [newPoi addOptionalObject:optionalSource];
    
    for (NSString * key in tagDictionary)
    {
        [newPoi addTagsObject:[OPEManagedOsmTag fetchOrCreateWithKey:key value:[tagDictionary objectForKey:key]]];
    }
    
   /* NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    */

}

-(OPEManagedReferenceOptional *)importOptionalDictionary:(NSDictionary *)dictionary name:(NSString *)name
{
    BOOL didCreate = NO;
    OPEManagedReferenceOptional * newOptional = [OPEManagedReferenceOptional fetchOrCreateWithName:name didCreate:&didCreate];
    
    [newOptional MR_importValuesForKeysWithObject:dictionary];
    
    OPEManagedReferenceOptionalCategory * cat = [OPEManagedReferenceOptionalCategory fetchWithName:[dictionary objectForKey:@"section"]];
    newOptional.referenceSection = cat;
    NSDictionary * possibleValues = nil;
    
    if([[dictionary objectForKey:@"values"] isKindOfClass:[NSString class]])
    {
        newOptional.type = [dictionary objectForKey:@"values"];
    }
    else
    {
        possibleValues = [dictionary objectForKey:@"values"];
    }
    
    for(NSString * value in possibleValues)
    {
        
        OPEManagedReferenceOsmTag * tag = [OPEManagedReferenceOsmTag fetchOrCreateWithName:value key:newOptional.osmKey value:[possibleValues objectForKey:value]];
        [newOptional addTagsObject:tag];
    }
    
    return newOptional;
    
}

-(OPEManagedReferenceOptional *)addOptionalWithName:(NSString *)name displayName:(NSString *)displayName section:(NSString *)section sectionSortOrder:(NSNumber *)sectionSortOrder osmkey:(NSString *)osmKey values:(NSDictionary *)tagValues type:(NSString *)type;
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
        newOptional.type = type;
        NSMutableSet * osmTags = [NSMutableSet set];
        
        
        
        for(NSString * value in tagValues)
        {
            
            OPEManagedReferenceOsmTag * tag = [OPEManagedReferenceOsmTag fetchOrCreateWithName:value key:osmKey value:[tagValues objectForKey:value]];
            [osmTags addObject: tag];
        }
        [newOptional setTags:osmTags];
    }
    
    return newOptional;
}

-(double)lastImportVersion
{
    NSUserDefaults * userDefaults = [NSUserDefaults standardUserDefaults];
    return [userDefaults doubleForKey:kLastImportVersionNumber];    
    
}
-(double)appVersionNumber
{
    NSString * currentVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    return [currentVersion doubleValue];
    
}

-(BOOL)shouldDoImport
{
    double numberOfOptionals = [[OPEManagedReferenceOptional MR_numberOfEntities] doubleValue];
    double numberOfPOI = [[OPEManagedReferencePoi MR_numberOfEntities] doubleValue];
    if ([self lastImportVersion]<[self appVersionNumber]) {
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
    [userDefaults setDouble:[self appVersionNumber] forKey:kLastImportVersionNumber];
}

@end
