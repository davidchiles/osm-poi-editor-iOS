//
//  OPETagInterpreter.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPETagInterpreter.h"


@implementation OPETagInterpreter
static OPETagInterpreter *sharedManager = nil;

@synthesize nameAndCategory;
@synthesize osmKeyandValue;
@synthesize osmKeyValueAndType;
@synthesize typeAndOsmKeyValue;
@synthesize typeAndImg;
@synthesize typeandOptionalTags;
@synthesize nameAndType;

- (id) init
{
    self = [super init];
    if(self)
    {
        [self readPlist];
    }
    return self;
}

- (NSString *) category: (OPENode *)node
{
    return [[self type:node] categoryName];
}

-(OPEType *)type:(OPENode *)node
{
    if([node hasNoTags])
    {
        return nil;
    }
    NSMutableDictionary * finalCatAndType = [[NSMutableDictionary alloc] init];
    
    NSArray * allOsmKeyValue =[osmKeyValueAndType allKeys];
    
    for(NSDictionary * osmKeyValues in allOsmKeyValue)
    {
        int matches = 0;
        //NSLog(@"Number of Values: %d",numValues);
        for( NSString * osmKey in osmKeyValues)
        {
            if([[node.tags objectForKey:osmKey] isEqualToString:[osmKeyValues objectForKey:osmKey]])
            {
                matches++;
            }
        }
        if(matches == [osmKeyValues count])
        {
            [finalCatAndType setObject:[[NSNumber alloc] initWithInt:matches] forKey:osmKeyValues];
        }
        
    }
    
    if ([finalCatAndType count]>0)
    {
        //NSLog(@"finalCatAndType; %@",finalCatAndType);
        NSArray * sortedKeys = [finalCatAndType keysSortedByValueUsingSelector:@selector(compare:)];
        //NSLog(@"sorted Array: %@",sortedKeys);
        return (OPEType *)[osmKeyValueAndType objectForKey: [sortedKeys objectAtIndex:([sortedKeys count]-1)]];
    }
    //NSLog(@"NO CATEGORY OR TYPE: %@",node.tags);
    return nil;
    
    
    
}

- (void) readPlist
{
    NSLog(@"start reading plist");
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Tags" ofType:@"plist"];
    
    
    NSDictionary* plistDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    
    
    //NSLog(@"Number of dictionaries in plist: %d",[plistDict count]);
    
    //NSLog(@"Number of keys in Government: %d",[categories count]);
    
    //NSLog(@"Number of keys in amenity: %d",[type count]);	
    
    //NSLog(@"gov: %@",[type objectForKey:@"courthouse"]);
    
    nameAndCategory = [[NSMutableDictionary alloc] init];
    osmKeyandValue  = [[NSMutableDictionary alloc] init];
    osmKeyValueAndType = [[NSMutableDictionary alloc] init];
    typeAndOsmKeyValue = [[NSMutableDictionary alloc] init]; //for each category type pair : all osm keys
    typeAndImg = [[NSMutableDictionary alloc] init];
    typeandOptionalTags = [[NSMutableDictionary alloc] init];
    nameAndType = [[NSMutableDictionary alloc]init];
    
    
    // load dictionary categoryAndType with Key=category and Value= array of types
    // load dictionary osmKeyandValue with Key = key and Value = array of values (supported types)
    for (NSString * cat in plistDict)
    {
        OPECategory * category = [[OPECategory alloc] init];
        category.name = cat;
        NSMutableDictionary * tempTypes = [[NSMutableDictionary alloc] init];
        //NSLog(@"Category: %@",cat);
        NSDictionary * categories = [plistDict objectForKey:cat];
        for (NSString * typeName in categories)
        {
            //NSLog(@"Type: %@",type);
            OPEType * type = [[OPEType alloc] initWithName:typeName categoryName:category.name dictionary:[categories objectForKey:typeName]];
            
            [osmKeyValueAndType setObject:type forKey:type.tags];
            [nameAndType setObject:type forKey:type.displayName];
            
            [tempTypes setObject:type forKey:type.displayName];
            
        
            
            [nameAndCategory setObject:category forKey:category.name];
             
        }
        category.types = tempTypes;
    }
    //categoryAndType = [categoryAndType  ;
    //[osmKeyandValue initWithDictionary: osmKeyandValue];
    //NSLog(@"categoryAndType count: %@",categoryAndType);
    //NSLog(@"osmkeyandValue count: %@",[osmKeyandValue objectForKey:@"amenity"]);
    //NSLog(@"CategoryTypeandOsmKV count: %@",CategoryTypeandOsmKV );

}

- (NSString *) getName:(OPENode *)node
{
    NSString * name = [node.tags objectForKey:@"name"];
    if(name)
    {
        return name;
    }
    else
    {
        return [[self type:node] displayName];
    }
    return @"Unknown";
}

- (NSString *) getImageForNode: (OPENode *) node
{
    return [[self type:node] imageString];
}

- (void)removeTagsForType:(OPEType *)type withNode:(OPENode *)node
{
    [node.tags removeObjectsForKeys:type.tags.allKeys];
    //[node.tags removeObjectsForKeys:type.optionalTags];
}

- (BOOL)isSupported:(OPENode *)node
{
    if([self type:node])
        return YES;
    return NO;
}


+ (NSArray *) getOptionalTagsDictionaries: (NSArray *) tagArray
{
    NSMutableArray * tempFinalArray = [[NSMutableArray alloc] init];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Optional" ofType:@"plist"];
    NSDictionary* optionalDictionary = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    for (NSString * osmKey in tagArray) {
        if( [osmKey isEqualToString:@"address"])
        {
            [tempFinalArray addObject:[optionalDictionary objectForKey:@"addr:housenumber"]];
            [tempFinalArray addObject:[optionalDictionary objectForKey:@"addr:street"]];
            [tempFinalArray addObject:[optionalDictionary objectForKey:@"addr:city"]];
            [tempFinalArray addObject:[optionalDictionary objectForKey:@"addr:postcode"]];
            [tempFinalArray addObject:[optionalDictionary objectForKey:@"addr:state"]];
            [tempFinalArray addObject:[optionalDictionary objectForKey:@"addr:country"]];
            [tempFinalArray addObject:[optionalDictionary objectForKey:@"addr:province"]];
            [tempFinalArray addObject:[optionalDictionary objectForKey:@"website"]];
            [tempFinalArray addObject:[optionalDictionary objectForKey:@"phone"]];
        }
        else {
            [tempFinalArray addObject:[optionalDictionary objectForKey:osmKey]];

        }
    }
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    NSSortDescriptor *sectionDescriptor = [[NSSortDescriptor alloc] initWithKey:@"section" ascending:NO];
    [tempFinalArray sortUsingDescriptors:[NSArray arrayWithObjects:sectionDescriptor ,nameDescriptor,nil]];
    
    
    return [tempFinalArray copy];
}

-(NSDictionary *)allCategories
{
    return nameAndCategory;
}

-(NSDictionary *)allTypes
{
    return nameAndType;
}

+(OPETagInterpreter *)sharedInstance
{
    @synchronized(self) {
        if (sharedManager == nil) {
            sharedManager = [[self alloc] init];
        }
    }
    return sharedManager;
}


@end
