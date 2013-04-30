#import "OPEManagedReferencePoi.h"
#import "OPEManagedReferenceOptionalCategory.h"
#import "OPEManagedReferenceOptional.h"
#import "OPEManagedReferencePoiCategory.h"
#import "FMDatabase.h"
#import "OPEConstants.h"

@interface OPEManagedReferencePoi ()

// Private interface goes here.

@end


@implementation OPEManagedReferencePoi

@synthesize name,isLegacy,canAdd,imageString,currentTagMethod,oldTagMethod,optionalsSet,tags;

-(id)initWithName:(NSString *)newName withCategory:(NSString *)newCategoryName andDictionary:(NSDictionary *)dictionary
{
    if (self = [super init]) {
        self.name = newName;
        self.categoryName = newCategoryName;
        self.imageString = [dictionary objectForKey:@"image"];
        self.tags = [dictionary objectForKey:@"tags"];
        
        NSMutableSet * tempSet = [NSMutableSet set];
        for(NSString * key in [dictionary objectForKey:@"optional"])
        {
            if ([key isEqualToString:@"address"]) {
                NSArray * addressArray = kExpandedAddressArray;
                for( NSString * addr in addressArray)
                {
                    OPEManagedReferenceOptional * optional = [[OPEManagedReferenceOptional alloc] init];
                    optional.name = addr;
                    [tempSet addObject:optional];
                }
            }
            else
            {
                OPEManagedReferenceOptional * optional = [[OPEManagedReferenceOptional alloc] init];
                optional.name = key;
                [tempSet addObject:optional];
            }
            
            
            
        }
        self.optionalsSet = tempSet;
        
        self.isLegacy = ([self.name rangeOfString:@" (legacy)"].location != NSNotFound);
    }
    return self;
    
}
-(NSString *)sqliteInsertString
{
    return [NSString stringWithFormat:@"insert or replace into poi(canAdd,imageString,isLegacy,displayName,category) values(%d,\'%@\',%d,\'%@\',\'%@\')",YES,self.imageString,self.isLegacy,self.name,self.categoryName];
}
-(NSString *)sqliteOptionalInsertString
{
    NSMutableString * sqlString = nil;
    if ([self.optionalsSet count] && self.rowID) {
        BOOL first = YES;
        for ( OPEManagedReferenceOptional * optional in self.optionalsSet)
        {
            if (first) {
                sqlString =  [NSMutableString stringWithFormat:@"insert or replace into pois_optionals select %lld as poi_id,(select optional.rowid from optional where optional.name = \'%@\') as optional_id",self.rowID,optional.name];
            }
            else{
                [sqlString appendFormat:@" union select %lld,(select optional.rowid from optional where optional.name = \'%@\')",self.rowID,optional.name];
            }
            
            
            
            first = NO;
        }
    }
    return sqlString;
    
}

-(NSString *)sqliteTagsInsertString
{
    NSMutableString * sqlString = nil;
    if ([self.tags count] && self.rowID) {
        BOOL first = YES;
        for(NSString * osmKey in self.tags)
        {
            if (first) {
                sqlString = [NSMutableString stringWithFormat:@"insert or replace into pois_tags select %lld as poi_id,\'%@\' as key,\'%@\' as value",self.rowID,osmKey,self.tags[osmKey]];
            }
            else
            {
                [sqlString appendFormat:@" union select %lld,'\%@\','\%@\'",self.rowID,osmKey,self.tags[osmKey]];
                
            }
            first = NO;
            
            
        }
    }
    return sqlString;
}

-(NSInteger)numberOfOptionalSections
{
    NSLog(@"Optionals: %d",[self.optionalsSet count]);
    NSArray * uniqueSections =[self.optionalsSet valueForKeyPath:@"@distinctUnionOfObjects.referenceSection"];
    return [uniqueSections count];
}

-(NSArray *)optionalDisplayNames
{
    NSMutableArray * displayNameArray = [NSMutableArray array];
    NSArray * tempArray = [[self.optionalsSet valueForKeyPath:@"@distinctUnionOfObjects.referenceSection"] allObjects];
    
    NSSortDescriptor *sortDescriptor;
    sortDescriptor = [[NSSortDescriptor alloc] initWithKey:@"sortOrder"
                                                  ascending:YES];
    NSArray *sortDescriptors = [NSArray arrayWithObject:sortDescriptor];
    NSArray *uniqueSections;
    uniqueSections = [tempArray sortedArrayUsingDescriptors:sortDescriptors];
    
    
    //NSArray * uniqueSections =[[[[[self.optional valueForKeyPath:@"@distinctUnionOfObjects.referenceSection"] allObjects] sortedArrayUsingSelector:@selector(caseInsensitiveCompare:)] reverseObjectEnumerator] allObjects];;
    
    NSSortDescriptor *descriptor = [[NSSortDescriptor alloc] initWithKey:@"sectionSortOrder"  ascending:YES];
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"displayName" ascending:YES];
    
    
    for(OPEManagedReferenceOptionalCategory * managedOptionalCategory in uniqueSections)
    {
        //NSString * sectionName = managedOptionalCategory.displayName;
        NSPredicate * predicate = [NSPredicate predicateWithFormat:@"referenceSection == %@", managedOptionalCategory];
        NSArray * names = [[[self.optionalsSet filteredSetUsingPredicate:predicate] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nameDescriptor, nil]];
        [displayNameArray addObject:names];
    }
    return displayNameArray;
}

+(NSArray *) allTypes
{
    //return all taypes from db
    return nil;
    
    
}

@end
