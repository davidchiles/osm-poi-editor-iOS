#import "OPEManagedOsmTag.h"

@interface OPEManagedReferenceOsmTag : OPEManagedOsmTag {}


@property (nonatomic,strong) NSString * name;

-(NSString *)sqliteInsertString;

@end
