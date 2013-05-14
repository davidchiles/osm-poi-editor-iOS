#import "OPEManagedOsmTag.h"


@interface OPEManagedOsmTag ()

// Private interface goes here.

@end


@implementation OPEManagedOsmTag

@synthesize key,value;

-(void)loadWithResult:(FMResultSet *)set
{
    self.key = [set stringForColumn:@"key"];
    self.value = [set stringForColumn:@"value"];
}

@end
