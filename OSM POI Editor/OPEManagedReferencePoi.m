#import "OPEManagedReferencePoi.h"
#import "OPEManagedReferenceOptional.h"
#import "FMDatabase.h"
#import "OPEConstants.h"
#import "OPETranslate.h"

@interface OPEManagedReferencePoi ()

// Private interface goes here.

@end


@implementation OPEManagedReferencePoi

@synthesize isLegacy,editOnly,imageString,currentTagMethod,oldTagMethod,optionalsSet,tags;
@synthesize categoryName = _categoryName;
@synthesize name = _name;

-(id)init
{
    if (self = [super init]) {
        self.isLegacy = NO;
        self.optionalsSet = [NSMutableSet set];
        self.tags = [NSMutableDictionary dictionary];
    }
    return self;
    
    
}

-(id)initWithName:(NSString *)newName withCategory:(NSString *)newCategoryName andDictionary:(NSDictionary *)dictionary
{
    if (self = [self init]) {
        self.name = newName;
        self.categoryName = newCategoryName;
        self.imageString = [dictionary objectForKey:@"image"];
        self.tags = [dictionary objectForKey:@"tags"];
        
        self.editOnly = NO;
        if ([dictionary objectForKey:@"editOnly"]) {
            self.editOnly = [[dictionary objectForKey:@"editOnly"] boolValue];
        }
        
        
        NSMutableSet * tempSet = [NSMutableSet set];
        for(NSString * key in [dictionary objectForKey:@"optional"])
        {
            if ([key isEqualToString:@"address"]) {
                NSArray * addressArray = [OPEConstants expandedAddressArray];
                for( NSString * addr in addressArray)
                {
                    OPEManagedReferenceOptional * optional = [[OPEManagedReferenceOptional alloc] init];
                    optional.name = addr;
                    [tempSet addObject:optional];
                }
            }
            else if ([key isEqualToString:@"contact"]) {
                NSArray * addressArray = [OPEConstants expandedContactArray];
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
-(id)initWithSqliteResultDictionary:(NSDictionary *)dictionary
{
    if (self = [self init]) {
        self.name = dictionary[@"displayName"];
        self.imageString = dictionary[@"imageString"];
        self.editOnly = [dictionary[@"editOnly"] boolValue];
        self.isLegacy = [dictionary[@"isLegacy"]boolValue];
        self.categoryName = dictionary[@"category"];
        id itemId = dictionary[@"id"];
        if ([itemId isKindOfClass:[NSNumber class]]) {
            self.rowID = [itemId intValue];
        }
    }
    return self;
    
}

-(NSString *)sqliteInsertString
{
    return [NSString stringWithFormat:@"insert or replace into poi(editOnly,imageString,isLegacy,displayName,category) values(%d,\'%@\',%d,\'%@\',\'%@\')",self.editOnly,self.imageString,self.isLegacy,self.refName,self.categoryName];
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
            [sqlString appendFormat:@" union select %lld,(select optional.rowid from optional where optional.name = \'note\')",self.rowID];
            [sqlString appendFormat:@" union select %lld,(select optional.rowid from optional where optional.name = \'source\')",self.rowID];
            
            
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
    NSArray * uniqueSections =[self.optionalsSet valueForKeyPath:@"@distinctUnionOfObjects.sectionName"];
    return [uniqueSections count];
}

-(NSString *)categoryName
{
    return [OPETranslate translateString:_categoryName];
}
-(NSString *)name
{
    return [OPETranslate translateString:_name];
}
-(NSString *)refName
{
    return _name;
}
@end
