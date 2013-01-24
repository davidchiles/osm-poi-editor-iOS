#import "OPEManagedOsmElement.h"
#import "OPEManagedReferencePoi.h"

#import "OPEManagedOsmTag.h"


@interface OPEManagedOsmElement ()

// Private interface goes here.

@end


@implementation OPEManagedOsmElement

-(CLLocationCoordinate2D)center
{
    return CLLocationCoordinate2DMake(0, 0);
}

-(NSString *)name
{
    NSPredicate * nameFilter = [NSPredicate predicateWithFormat:@"key == 'name'"];
    NSSet * filteredSet = [self.tags filteredSetUsingPredicate:nameFilter];
    if ([filteredSet count]) {
        OPEManagedOsmTag * tag = [filteredSet anyObject];
        return tag.value;
    }
    else if (self.type)
    {
        return self.type.name;
    }
    else
    {
        return @"";
    }
}

-(BOOL)findType
{
    if ([self.tags count]) {
        NSMutableSet * possibleMatches = [NSMutableSet set];
        NSMutableSet * possibleLegacyMatches = [NSMutableSet set];
        for(OPEManagedOsmTag * tag in self.tags)
        {
            for(OPEManagedReferencePoi * poi in tag.referencePois)
            {
                if([poi.tags isSubsetOfSet:self.tags])
                {
                    if (poi.isLegacyValue)
                        [possibleLegacyMatches addObject:poi];
                    else
                        [possibleMatches addObject:poi];
                }
                
            }
        }
        
        if ([possibleMatches count]) {
            self.type = [possibleMatches anyObject];
            
            NSString * name = [self name];
            NSLog(@"Name: %@",name);
            return YES;
        }
        else if([possibleLegacyMatches count])
        {
            self.type = [possibleLegacyMatches anyObject];
            return YES;
        }
        
        
    }
    return NO;
    
}

@end
