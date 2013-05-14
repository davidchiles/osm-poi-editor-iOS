#import "OPEManagedReferenceOsmTag.h"
#import "OPEManagedOsmTag.h"
#import "OPETranslate.h"

@interface OPEManagedReferenceOsmTag ()

// Private interface goes here.

@end


@implementation OPEManagedReferenceOsmTag
@synthesize name =_name;

-(void)loadWithResult:(FMResultSet *)set
{
    [super loadWithResult:set];
    self.name = [set stringForColumn:@"name"];
}

-(NSString *)name
{
    return [OPETranslate translateString:_name];
}

@end
