#import "OPEOsmRelationMember.h"


@interface OPEOsmRelationMember ()

// Private interface goes here.

@end


@implementation OPEOsmRelationMember

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
