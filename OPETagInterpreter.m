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

- (id) init
{
    self = [super init];
    [self readPlist];
    
    return self;
}

- (BOOL) nodeHasRecognizedTags:(OPENode *)node
{
    NSString * nodeValue;
    for(NSString * nodeKey in node.tags)
    {
        nodeValue = [node.tags objectForKey:nodeKey];
        NSArray * osmValues = [osmKeyandValue objectForKey:nodeKey];
        
        if(osmValues && [osmValues containsObject:nodeValue])
        {
            NSLog(@"Does contain nodeValue %@",nodeValue);
            return YES;
        }
    }
    NSLog(@"Doesn't contain nodeValue %@",nodeValue);
    return NO;
}

- (NSDictionary *) getPrimaryKeyValue: (OPENode *)node
{
    for(NSString * nodeKey in node.tags)
    {
        NSString * nodeValue = [node.tags objectForKey:nodeKey];
        NSMutableArray * values = [osmKeyandValue objectForKey:nodeKey];
        if(values)
        {
            if([values containsObject:nodeValue])
            {
                NSDictionary * primaryKeyValue = [[NSDictionary alloc] initWithObjectsAndKeys:nodeValue,nodeKey, nil];
                return primaryKeyValue;
            }
        }
    }
         
    return nil;
}

- (NSString *) getCategory: (OPENode *)node
{
    NSDictionary * primaryKeyValue = [[NSDictionary alloc] initWithDictionary:[self getPrimaryKeyValue:node]];
    //NSLog(@"primaryKeyValue: %@",primaryKeyValue);
    if(primaryKeyValue)
    {
        //NSLog(@"Cat and Type keys: %@",[osmKVandCategoryType objectForKey:primaryKeyValue]);
        NSDictionary * catAndType = [[NSDictionary alloc] initWithDictionary:[osmKVandCategoryType objectForKey:primaryKeyValue]];
        for(NSString * cat in catAndType)
        {
            //NSLog(@"Category %@",cat);
            return cat;
        }
    }
    return nil;
}

- (NSString *) getType: (OPENode *)node
{
    NSDictionary * primaryKeyValue = [[NSDictionary alloc] initWithDictionary:[self getPrimaryKeyValue:node]];
    if(primaryKeyValue)
    {
        NSDictionary * catAndType = [[NSDictionary alloc] initWithDictionary:[osmKVandCategoryType objectForKey:primaryKeyValue]];
        for(NSString * cat in catAndType)
        {
            //NSLog(@"Type: %@",[catAndType objectForKey:cat]);
            return [catAndType objectForKey:cat];
        }
    }
    return nil;
}

- (NSArray *) getOsmKeyValue: (NSDictionary *) catAndTyp
{
    /*
    NSString * key;
    NSString * value;
    for (key in catAndTyp)
    {
        value = [catAndTyp objectForKey:key];
    }
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Tags" ofType:@"plist"];
    NSDictionary* plistDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    NSDictionary* categories = [[NSDictionary alloc] initWithDictionary:[plistDict objectForKey:key]];
    
    for (NSString * osmKey in categories)
    {
        NSDictionary * type = [categories objectForKey:osmKey];
        if([type allKeysForObject:value])
        {
            NSDictionary * osmKeyValue = [[NSDictionary alloc] initWithObjectsAndKeys: [type allKeysForObject:value],osmKey,nil];
            return osmKeyValue;
        }
    }
    return nil;*/
    //NSLog(@"getOSMKEYVALUE: %@",[osmKVandCategoryType allKeysForObject:catAndTyp]);
    return [osmKVandCategoryType allKeysForObject:catAndTyp];
    
}

- (void) readPlist
{
    NSLog(@"start reading plist");
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"Tags" ofType:@"plist"];
    NSDictionary* plistDict = [[NSDictionary alloc] initWithContentsOfFile:filePath];
    
    NSLog(@"Number of dictionaries in plist: %d",[plistDict count]);
    
    NSDictionary* categories = [[NSDictionary alloc] initWithDictionary:[plistDict objectForKey:@"Government"]];
    
    NSLog(@"Number of keys in Government: %d",[categories count]);
    
    NSDictionary* type = [[NSDictionary alloc] initWithDictionary:[categories objectForKey:@"amenity"]];
    
    NSLog(@"Number of keys in amenity: %d",[type count]);	
    
    NSLog(@"gov: %@",[type objectForKey:@"courthouse"]);
    
    categoryAndType = [[NSMutableDictionary alloc] init];
    osmKeyandValue  = [[NSMutableDictionary alloc] init];
    osmKVandCategoryType = [[NSMutableDictionary alloc] init];
    
    // load dictionary categoryAndType with Key=category and Value= array of types
    // load dictionary osmKeyandValue with Key = key and Value = array of values (supported types)
    for (NSString * i in plistDict)
    {
        //NSLog(@"NAME: %@",i);
        NSDictionary * categories = [plistDict objectForKey:i];
        for (NSString * osmKey in categories)
        {
            NSMutableArray * converted = [[NSMutableArray alloc] init];
            NSMutableArray * osmValues;
            
            //check if already exists an array with values 
            if(!([osmKeyandValue objectForKey:osmKey]))
            {
                osmValues = [[NSMutableArray alloc] init];
            }
            else
            {
                osmValues = [[NSMutableArray alloc] initWithArray:[osmKeyandValue objectForKey:osmKey]];
            }
            
            NSDictionary * p = [categories objectForKey:osmKey];
            
            for (NSString * osmValue in p)
            {
                [osmValues addObject:osmValue];
                [converted addObject:[p objectForKey:osmValue]];
                //[osmKVandCategoryType setObject:[[NSDictionary alloc] initWithObjectsAndKeys:osmValue,osmKey, nil] forKey:[[NSDictionary alloc] initWithObjectsAndKeys:[p objectForKey:osmValue],i,nil]];
                [osmKVandCategoryType setObject:[[NSDictionary alloc] initWithObjectsAndKeys:[p objectForKey:osmValue],i, nil] forKey:[[NSDictionary alloc] initWithObjectsAndKeys:osmValue,osmKey,nil]];
                //NSLog(@"type: %@",[p objectForKey:key]);
            }
            [categoryAndType setObject:converted forKey:i];
            
            [osmKeyandValue setObject:osmValues forKey:osmKey];
        }
    }
    //categoryAndType = [categoryAndType  ;
    //[osmKeyandValue initWithDictionary: osmKeyandValue];
    NSLog(@"categoryAndType count: %d",[categoryAndType count]);
    NSLog(@"osmkeyandValue count: %d",[osmKeyandValue count]);
    NSLog(@"osmKVandCategoryType count: %d",[osmKVandCategoryType count]);
    
    for (NSDictionary * key in osmKVandCategoryType) 
    {
        //NSLog(@"Each key: %@",key);
        NSDictionary * value = [osmKVandCategoryType objectForKey:key];
        for( NSString * k in value)
        {
            NSLog(@"Each value: %@",[value objectForKey:k]);
        }
    }
    
    

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
