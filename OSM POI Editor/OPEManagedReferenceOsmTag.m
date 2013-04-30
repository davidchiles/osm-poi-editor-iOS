#import "OPEManagedReferenceOsmTag.h"
#import "OPEManagedOsmTag.h"

@interface OPEManagedReferenceOsmTag ()

// Private interface goes here.

@end


@implementation OPEManagedReferenceOsmTag
@synthesize name;

-(void)loadWithResult:(FMResultSet *)set
{
    [super loadWithResult:set];
    self.name = [set stringForColumn:@"name"];
}

@end
