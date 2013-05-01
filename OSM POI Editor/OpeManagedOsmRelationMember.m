#import "OpeManagedOsmRelationMember.h"


@interface OpeManagedOsmRelationMember ()

// Private interface goes here.

@end


@implementation OpeManagedOsmRelationMember
@synthesize role,type,ref,element;

-(id)initWithDictionary:(NSDictionary *)dictionary
{
    if(self = [super init])
    {
        self.role = dictionary[@"role"];
        self.ref = [dictionary[@"ref"] longLongValue];
        self.type = dictionary[@"type"];
        
    }
    return self;
}

@end
