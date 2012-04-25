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

@synthesize categoryAndType;
@synthesize osmKeyandValue;
@synthesize osmKVandCategoryType;
@synthesize CategoryTypeandOsmKV;
@synthesize CategoryTypeandImg;
@synthesize CategoryTypeandOptionalTags;

- (id) init
{
    self = [super init];
    if(self)
    {
        [self readPlist];
    }
    return self;
}

- (NSString *) getCategory: (OPENode *)node
{
    return [[[self getCategoryandType:node] allKeys]objectAtIndex:0];
}

- (NSString *) getType: (OPENode *)node
{
    return [[[self getCategoryandType:node] allValues] objectAtIndex:0];
}

-(NSDictionary *)getCategoryandType:(OPENode *)node
{   
    
    NSMutableDictionary * finalCatAndType = [[NSMutableDictionary alloc] init];;
    
    
    NSDictionary * catAndType;
    for(catAndType in CategoryTypeandOsmKV)
    {
        NSDictionary * osmKeysValues = [CategoryTypeandOsmKV objectForKey:catAndType];
        //int numValues = [osmKeyandValue count];
        int matches = 0;
        //NSLog(@"Number of Values: %d",numValues);
        for( NSString * osmKey in osmKeysValues)
        {
            if([[node.tags objectForKey:osmKey] isEqualToString:[osmKeysValues objectForKey:osmKey]])
            {
                matches++;
            }
        }
        if(matches >0)
        {
            [finalCatAndType setObject:[[NSNumber alloc] initWithInt:matches] forKey:catAndType];
        }
        
    }
    
    if ([finalCatAndType count]>0)
    {
        //NSLog(@"finalCatAndType; %@",finalCatAndType);
        NSArray * sortedKeys = [finalCatAndType keysSortedByValueUsingSelector:@selector(compare:)];
        //NSLog(@"sorted Array: %@",sortedKeys);
        return [sortedKeys objectAtIndex:([sortedKeys count]-1)];
    }
    //NSLog(@"NO CATEGORY OR TYPE: %@",node.tags);
    return nil;
    
}

- (NSDictionary *) getOSmKeysValues: (NSDictionary *) catAndType
{
    return [self.CategoryTypeandOsmKV objectForKey:catAndType];
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
    
    categoryAndType = [[NSMutableDictionary alloc] init];
    osmKeyandValue  = [[NSMutableDictionary alloc] init];
    osmKVandCategoryType = [[NSMutableDictionary alloc] init];
    CategoryTypeandOsmKV = [[NSMutableDictionary alloc] init]; //for each category type pair : all osm keys
    CategoryTypeandImg = [[NSMutableDictionary alloc] init];
    CategoryTypeandOptionalTags = [[NSMutableDictionary alloc] init];
    
    
    // load dictionary categoryAndType with Key=category and Value= array of types
    // load dictionary osmKeyandValue with Key = key and Value = array of values (supported types)
    for (NSString * cat in plistDict)
    {
        //NSLog(@"Category: %@",cat);
        NSMutableSet * types = [[NSMutableSet alloc] init];
        NSDictionary * categories = [plistDict objectForKey:cat];
        for (NSString * type in categories)
        {
            //NSLog(@"Type: %@",type);
            NSDictionary * typeDictionary = [categories objectForKey:type];
            NSDictionary * tags = [typeDictionary objectForKey:@"tags"];
            NSString * img = [typeDictionary objectForKey:@"image"];
            NSArray * optionalTags = [typeDictionary objectForKey:@"optional"];
            [CategoryTypeandOsmKV setObject:tags forKey:[[NSDictionary alloc] initWithObjectsAndKeys:type,cat, nil]];
            [CategoryTypeandImg setObject:img forKey:[[NSDictionary alloc] initWithObjectsAndKeys:type,cat, nil]];
            if (optionalTags) {
                [CategoryTypeandOptionalTags setObject:optionalTags forKey:[[NSDictionary alloc] initWithObjectsAndKeys:type,cat, nil]];
                //NSLog(@"Optional tags: %@",optionalTags);
            }
            
            [types addObject:type]; 
            
            
            
            for (NSString * osmKey in tags)
            {
                if ([osmKeyandValue objectForKey:osmKey]) {
                    NSMutableSet * tempValues = [osmKeyandValue objectForKey:osmKey];
                    [tempValues addObject:[tags objectForKey:osmKey]];
                    [osmKeyandValue setObject: tempValues forKey:osmKey];
                }
                else {
                    NSMutableSet * values = [[NSMutableSet alloc] initWithObjects:[tags objectForKey:osmKey], nil];
                    [osmKeyandValue setObject:values forKey:osmKey];
                }
                
            }
            
        [categoryAndType setObject:types forKey:cat];
             
        }
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
        return [self getType:node];
    }
    return @"Unknown";
}

- (NSString *) getImageForNode: (OPENode *) node
{
    NSDictionary * catAndType = [self getCategoryandType:node];
    return [self.CategoryTypeandImg objectForKey:catAndType];
}

- (void)removeCatAndType:(NSDictionary *) catType fromNode:(OPENode *)node
{
    [node.tags removeObjectsForKeys:[[self getOSmKeysValues:catType] allKeys]];
    
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
