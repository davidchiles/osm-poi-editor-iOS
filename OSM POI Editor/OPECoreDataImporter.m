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

#define POIEntitity @"POI"
#define OSMTAGEntity @"OSMTAG"
#define OPTIONALEntity @"OPTIONAL"


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
    POI * newPoi = (POI*)[NSEntityDescription insertNewObjectForEntityForName:POIEntitity inManagedObjectContext:managedObjectContext];
    
    newPoi.name = name;
    newPoi.isLegacy = [NSNumber numberWithBool:isLegacy];
    newPoi.imageString = imageString;
    newPoi.category = category;
    
    NSMutableSet * optionalSet = [NSMutableSet set];
    for(NSString * optional in optionalTags)
    {
        [optionalSet addObject:[self OptionalWithName:optional]];
        //deal with address stuff here
    }
    [newPoi setOptional:optionalSet];
    
    NSMutableSet * osmTagSet = [NSMutableSet set];
    for (NSString * key in tagDictionary)
    {
        [osmTagSet addObject:[self osmKey:key value:[tagDictionary objectForKey:key] name:nil]];
    }
    [newPoi setTags:osmTagSet];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    
}

-(OPTIONAL *)OptionalWithName:(NSString *)name
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:OPTIONALEntity inManagedObjectContext:self.managedObjectContext];    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@",@"name",name];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    OPTIONAL * optional = [[self.managedObjectContext executeFetchRequest:request error:nil] objectAtIndex:0];
    
    return optional;
    
}

-(OPTIONAL *)addOptionalWithName:(NSString *)name displayName:(NSString *)displayName section:(NSString *)section sectionSortOrder:(NSNumber *)sectionSortOrder osmkey:(NSString *)osmKey values:(NSDictionary *)tagValues
{
    OPTIONAL * newOptional = [NSEntityDescription insertNewObjectForEntityForName:OPTIONALEntity inManagedObjectContext:managedObjectContext];
    
    newOptional.name = name;
    newOptional.section = section;
    newOptional.sectionSortOrder = sectionSortOrder;
    
    NSMutableSet * osmTags = [NSMutableSet set];
    
    for(NSString * value in tagValues)
    {
        OSMTAG * tag = [self osmKey:osmKey value:[tagValues objectForKey:value] name:value];
        [osmTags addObject: tag];
    }
    [newOptional setTags:osmTags];
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    
    return newOptional;
}

-(OSMTAG *)osmKey:(NSString *)key value:(NSString *)value name:(NSString *)name
{
    NSEntityDescription *entity = [NSEntityDescription entityForName:OSMTAGEntity inManagedObjectContext:self.managedObjectContext];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"%K == %@ AND %K == %@",@"key",name,@"value",value];
    NSFetchRequest *request = [[NSFetchRequest alloc] init];
    [request setEntity:entity];
    [request setPredicate:predicate];
    
    NSArray * result = [self.managedObjectContext executeFetchRequest:request error:nil];
    OSMTAG * osmTag;
    
    if(![result count])
    {
        osmTag = [NSEntityDescription insertNewObjectForEntityForName:OSMTAGEntity inManagedObjectContext:managedObjectContext];
        osmTag.key = key;
        osmTag.value = value;
        osmTag.name = name;
    }
    else
    {
        osmTag = [result objectAtIndex:0];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"Couldn't save: %@", [error localizedDescription]);
    }
    
    return osmTag;
}

@end
