//
//  OPETagInterpreter.m
//  OSM POI Editor
//
//  Created by David Chiles on 2/9/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPETagInterpreter.h"


@implementation OPETagInterpreter

@synthesize categoryAndType;
@synthesize osmKeyandValue;

- (id) init
{
    self = [super init];
    
    
    return self;
}

- (BOOL) nodeHasRecognizedTags:(OPENode *)node
{
    return NO;
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
    
    NSMutableDictionary * categoryAndTypeTemp = [[NSMutableDictionary alloc] init];
    NSMutableDictionary * osmKeyandValueTemp  = [[NSMutableDictionary alloc] init];
    
    // load dictionary categoryAndType with Key=category and Value= array of types
    for (NSString * i in plistDict)
    {
        //NSLog(@"NAME: %@",i);
        NSDictionary * categories = [plistDict objectForKey:i];
        for (NSString * osmKey in categories)
        {
            NSMutableArray * converted = [[NSMutableArray alloc] init];
            NSMutableArray * osmValues;
            
            //check if already exists an array with values 
            if(!([osmKeyandValueTemp objectForKey:osmKey]))
            {
                osmValues = [[NSMutableArray alloc] init];
            }
            else
            {
                osmValues = [[NSMutableArray alloc] initWithArray:[osmKeyandValueTemp objectForKey:osmKey]];
            }
                
            
            NSDictionary * p = [categories objectForKey:osmKey];
            
            for (NSString * osmValue in p)
            {
                [osmValues addObject:osmValue];
                [converted addObject:[p objectForKey:osmValue]];
                //NSLog(@"type: %@",[p objectForKey:key]);
            }
            [categoryAndTypeTemp setObject:converted forKey:i];
            
            [osmKeyandValueTemp setObject:osmValues forKey:osmKey];
        }
    }
    //categoryAndType = [categoryAndTypeTemp  ;
    //[osmKeyandValue initWithDictionary: osmKeyandValueTemp];
    NSLog(@"categoryAndType count: %d",[categoryAndTypeTemp count]);
    NSLog(@"osmkeyandValue count: %d",[osmKeyandValueTemp count]);
    
    for (NSString * key in osmKeyandValueTemp) 
    {
        NSLog(@"Each key: %@",key);
        NSMutableArray * array = [osmKeyandValueTemp objectForKey:key];
        for( NSString * value in array)
        {
            NSLog(@"Each value: %@",value);
        }
    }
    
    

}

@end
