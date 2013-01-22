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
}

-(void)importOptionalTags
{
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Optional" ofType:@"plist"];
    NSDictionary* optionalDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    for(NSString * key in optionalDictionary)
    {
        OPEOptionalTag * optionalTag = [[OPEOptionalTag alloc] initWithName:key dictionary:[optionalDictionary objectForKey:key]];
        
        
        
        [self addOptionalWithName:key displayName:optionalTag.displayName section:optionalTag.section sectionSortOrder:optionalTag.sectionSortOrder osmkey:optionalTag.osmKey values:optionalTag.possibleValues];
    }
    
    
}

-(void)addPOIWithName:(NSString *)name  category:(NSString *)category imageString:(NSString *)imageString legacy:(BOOL )isLegacy optional:(NSArray *)optionalTags tags:(NSDictionary *) tagDictionary
{
    OPEManagedReferencePoi * newPoi = [OPEManagedReferencePoi MR_createEntity];
    
    newPoi.name = name;
    newPoi.isLegacy = [NSNumber numberWithBool:isLegacy];
    newPoi.imageString = imageString;
    newPoi.category = category;
    
    NSMutableSet * optionalSet = [NSMutableSet set];
    for(NSString * optional in optionalTags)
    {
        if([optional isEqualToString:@"address"])
        {
            NSArray * exppandedAddress = kExpandedAddressArray;
            for(NSString * addressString in exppandedAddress)
            {
                [optionalSet addObject:[self OptionalWithName:addressString]];
            }
            
        }
        else
        {
            [optionalSet addObject:[self OptionalWithName:optional]];
        }
            
        //deal with address stuff here
    }
    [newPoi setOptional:optionalSet];
    
    NSMutableSet * osmTagSet = [NSMutableSet set];
    for (NSString * key in tagDictionary)
    {
        [osmTagSet addObject:[self osmKey:key value:[tagDictionary objectForKey:key] name:nil]];
    }
    [newPoi setTags:osmTagSet];
    
   /* NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    */

}

-(OPEManagedReferenceOptional *)OptionalWithName:(NSString *)name
{
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"name == %@",name];
    
    NSArray * results = [OPEManagedReferenceOptional MR_findAllWithPredicate:predicate];
    
    OPEManagedReferenceOptional * optional = [results objectAtIndex:0];
    
    return optional;
    
}

-(OPEManagedReferenceOptional *)addOptionalWithName:(NSString *)name displayName:(NSString *)displayName section:(NSString *)section sectionSortOrder:(NSNumber *)sectionSortOrder osmkey:(NSString *)osmKey values:(NSDictionary *)tagValues
{
    //OPTIONAL * newOptional = [NSEntityDescription insertNewObjectForEntityForName:OPTIONALEntity inManagedObjectContext:managedObjectContext];
    OPEManagedReferenceOptional * newOptional = [OPEManagedReferenceOptional MR_createEntity];
    
    newOptional.name = name;
    newOptional.section = section;
    newOptional.sectionSortOrder = sectionSortOrder;
    
    NSMutableSet * osmTags = [NSMutableSet set];
    
    for(NSString * value in tagValues)
    {
        OPEManagedReferenceOsmTag * tag = [self osmKey:osmKey value:[tagValues objectForKey:value] name:value];
        [osmTags addObject: tag];
    }
    [newOptional setTags:osmTags];
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    [context MR_saveToPersistentStoreAndWait];

    
    return newOptional;
}

-(OPEManagedReferenceOsmTag *)osmKey:(NSString *)key value:(NSString *)value name:(NSString *)name
{
    NSPredicate *osmTagFilter = [NSPredicate predicateWithFormat:@"key == %@ AND value == %@",key,value];
    NSArray * osmTags = [OPEManagedReferenceOsmTag MR_findAllWithPredicate:osmTagFilter];
    
    OPEManagedReferenceOsmTag * osmTag;
    
    if(![osmTags count])
    {
        osmTag = [OPEManagedReferenceOsmTag MR_createEntity];
        osmTag.key = key;
        osmTag.value = value;
        osmTag.name = name;
    }
    else
    {
        osmTag = [osmTags objectAtIndex:0];
    }
    
    NSManagedObjectContext *context = [NSManagedObjectContext MR_defaultContext];
    [context MR_saveToPersistentStoreAndWait];
    
    return osmTag;
}

@end
