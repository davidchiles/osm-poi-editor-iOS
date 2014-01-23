#import "OPEOsmTag.h"


@interface OPEOsmTag ()

// Private interface goes here.

@end


@implementation OPEOsmTag

@synthesize key,value;

-(void)loadWithResult:(FMResultSet *)set
{
    self.key = [set stringForColumn:@"key"];
    self.value = [set stringForColumn:@"value"];
}

@end
