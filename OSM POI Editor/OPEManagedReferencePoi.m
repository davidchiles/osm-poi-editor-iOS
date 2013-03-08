#import "OPEManagedReferencePoi.h"
#import "OPEManagedReferenceOptionalCategory.h"
#import "OPEManagedReferencePoiCategory.h"


@interface OPEManagedReferencePoi ()

// Private interface goes here.

@end


@implementation OPEManagedReferencePoi

-(NSInteger)numberOfOptionalSections
{
    NSLog(@"Optionals: %d",[self.optional count]);
    NSArray * uniqueSections =[self.optional valueForKeyPath:@"@distinctUnionOfObjects.referenceSection"];
    return [uniqueSections count];
}

-(NSArray *)optionalDisplayNames
{
    NSMutableArray * displayNameArray = [NSMutableArray array];
    NSArray * tempArray = [[self.optional valueForKeyPath:@"@distinctUnionOfObjects.referenceSection"] allObjects];
    
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
        NSArray * names = [[[self.optional filteredSetUsingPredicate:predicate] allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor,nameDescriptor, nil]];
        [displayNameArray addObject:names];
    }
    return displayNameArray;
}

+(NSArray *) allTypes
{
    return [OPEManagedReferencePoi MR_findAllSortedBy:@"name" ascending:YES];
}

+(OPEManagedReferencePoi *) fetchOrCreateWithName:(NSString *)name category:(OPEManagedReferencePoiCategory *)category didCreate:(BOOL *)didCreate
{
    NSPredicate *osmPoiFilter = [NSPredicate predicateWithFormat:@"name == %@ AND category == %@",name,category];
    NSArray * results = [OPEManagedReferencePoi MR_findAllWithPredicate:osmPoiFilter];
    
    OPEManagedReferencePoi * referencePoi = nil;
    
    if(![results count])
    {
        referencePoi = [OPEManagedReferencePoi MR_createEntity];
        referencePoi.name = name;
        referencePoi.category =  category;
        
        *didCreate = YES;
    }
    else
    {
        *didCreate = NO;
        referencePoi = [results objectAtIndex:0];
    }
    return referencePoi;
}

@end
