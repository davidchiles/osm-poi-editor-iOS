#import "OPEManagedReferenceOptional.h"
#import "OPEManagedReferenceOsmTag.h"
#import "FMResultSet.h"
#import "FMDatabase.h"


@interface OPEManagedReferenceOptional ()

// Private interface goes here.

@end


@implementation OPEManagedReferenceOptional

@synthesize displayName,sectionSortOrder,osmKey,name,rowID;
@synthesize optionalTags = _optionalTags;
@synthesize sectionName = _sectionName;

-(id)init{
    if (self = [super init]) {
        self.optionalTags = [NSMutableSet set];
    }
    return self;
}

-(id)initWithDictionary:(NSDictionary *)dictionary withName:(NSString * )newName
{
    if (self = [self init]) {
        self.name = newName;
        [self setDictionary:dictionary];
    }
    return self;
}
-(OPEOptionalType)resolveType:(NSString *)typeString
{
    if ([typeString isEqualToString:kTypeText]) {
        return OPEOptionalTypeText;
    }
    else if ([typeString isEqualToString:KTypeName])
    {
        return OPEOptionalTypeName;
    }
    else if ([typeString isEqualToString:kTypeList])
    {
        return OPEOptionalTypeList;
    }
    else if ([typeString isEqualToString:kTypeLabel])
    {
        return OPEOptionalTypeLabel;
    }
    else if ([typeString isEqualToString:kTypeNumber])
    {
        return OPEOptionalTypeNumber;
    }
    else if ([typeString isEqualToString:kTypeUrl])
    {
        return OPEOptionalTypeUrl;
    }
    else if ([typeString isEqualToString:kTypePhone])
    {
        return OPEOptionalTypePhone;
    }
    else if ([typeString isEqualToString:kTypeHours])
    {
        return OPEOptionalTypeHours;
    }
    return OPEOptionalTypeNone;
}

-(NSString *)displayNameForKey:(NSString *)oKey withValue:(NSString *)osmValue
{
    NSPredicate * tagFilter = [NSPredicate predicateWithFormat:@"self.key == %@ AND self.value == %@",oKey,osmValue];
    NSSet * filteredSet = [self.optionalTags filteredSetUsingPredicate:tagFilter];
    
    if ([filteredSet count]) {
        OPEManagedReferenceOsmTag * managedReferenceOsmTag =  [filteredSet anyObject];
        return managedReferenceOsmTag.name;
    }
    return osmValue;
    
}
-(NSSet *)optionalTags
{
    if (!_optionalTags && self.rowID && self.type == OPEOptionalTypeList) {
        NSMutableSet * tempTags = [NSMutableSet set];
        [self.databaseQueue inDatabase:^(FMDatabase *db) {
            FMResultSet * set = [db executeQueryWithFormat:@"select * from optionals_tags where optional_id = %lld",self.rowID];
            while ([set next]) {
                OPEManagedReferenceOsmTag * tag = [[OPEManagedReferenceOsmTag alloc] init];
                [tag loadWithResult:set];
                [tempTags addObject:tag];
            }
            
        }];
        
        _optionalTags = tempTags;
    }
    
    return _optionalTags;
    
}

-(NSArray *)allSortedTags
{
    NSSortDescriptor *nameDescriptor = [[NSSortDescriptor alloc] initWithKey:@"name" ascending:YES];
    return [[self.optionalTags allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:nameDescriptor,nil]];
}

-(NSArray *)allDisplayNames
{
    NSMutableArray * finalArray = [NSMutableArray array];
    for(OPEManagedReferenceOsmTag * managedReferecneOsmTag in self.optionalTags)
    {
        [finalArray addObject:managedReferecneOsmTag.name];
    }
    return finalArray;
    
}
-(OPEManagedReferenceOsmTag *)managedReferenceOsmTagWithName:(NSString *)tagName;
{
    NSPredicate * tagFilter = [NSPredicate predicateWithFormat:@"name == %@",tagName];
    NSSet * filteredSet = [self.optionalTags filteredSetUsingPredicate:tagFilter];
    OPEManagedReferenceOsmTag * managedReferenceOsmTag = nil;
    
    if ([filteredSet count]) {
        managedReferenceOsmTag =  [filteredSet anyObject];
    }
    return managedReferenceOsmTag;
    
    
}
-(void)setDictionary:(NSDictionary*)dictionary
{
    self.displayName = dictionary[@"displayName"];
    self.sectionName = dictionary[@"section"];
    self.sectionSortOrder = [dictionary[@"sectionSortOrder"] intValue];
    self.osmKey = dictionary[@"osmKey"];
    id values = dictionary[@"values"];
    
    if( [values isKindOfClass:[NSString class]])
    {
        self.type = [self resolveType:(NSString *)values];
    }
    else
    {
        NSMutableSet * tempSet = [NSMutableSet set];
        NSDictionary * valuesDictionary = (NSDictionary *)values;
        self.type = OPEOptionalTypeList;
        for(NSString *tagName in valuesDictionary)
        {
            OPEManagedReferenceOsmTag * tag = [[OPEManagedReferenceOsmTag alloc] init];
            tag.key = self.osmKey;
            tag.value = valuesDictionary[tagName];
            tag.name = tagName;
            [tempSet addObject:tag];
        }
        self.optionalTags = tempSet;
    }
    
    
}

-(NSString *)sqliteOptionalTagsInsertString
{
    NSMutableString * sqlString = nil;
    if ([self.optionalTags count] && self.rowID) {
        BOOL first = YES;
        for(OPEManagedReferenceOsmTag * tag in self.optionalTags)
        {
            if (first) {
                sqlString = [NSMutableString stringWithFormat:@"insert or replace into optionals_tags select %lld as optional_id,\'%@\' as name,\'%@\' as key,\'%@\' as value",self.rowID,tag.name,tag.key,tag.value];
            }
            else{
                [sqlString appendFormat:@" union select %lld,\'%@\',\'%@\',\'%@\'",self.rowID,tag.name,tag.key,tag.value];
                
            }
            first = NO;
            
        }
    }
    return sqlString;
}

-(NSString *)sqliteInsertString
{
    return [NSString stringWithFormat:@"insert or replace into optional(name,displayName,osmKey,sectionSortOrder,type,section_id) select \'%@\',\'%@\',\'%@\',%ld,%lu,optional_section.rowid from optional_section where optional_section.name = \'%@\'",self.name,self.displayName,self.osmKey,self.sectionSortOrder,self.type,self.sectionName];
}

-(NSString *)description
{
    return self.name;
}

@end
