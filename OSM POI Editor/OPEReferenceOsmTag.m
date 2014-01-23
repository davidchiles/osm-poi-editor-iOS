#import "OPEReferenceOsmTag.h"
#import "OPEOsmTag.h"
#import "OPETranslate.h"

@interface OPEReferenceOsmTag ()

// Private interface goes here.

@end


@implementation OPEReferenceOsmTag
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
