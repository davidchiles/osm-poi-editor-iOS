//
//  OPECrosshairMapView.m
//  OSM POI Editor
//
//  Created by David on 6/26/13.
//
//

#import "OPECrosshairMapView.h"

@implementation OPECrosshairMapView
@synthesize plusImageView = _plusImageView;

-(id)init
{
    if(self = [super init])
    {
        self.showLogoBug = NO;
        self.showsUserLocation = YES;
        self.hideAttribution = YES;
        
    }
    return self;

}
-(id)initWithFrame:(CGRect)frame andTilesource:(id<RMTileSource>)newTilesource
{
    if (self = [super initWithFrame:frame andTilesource:newTilesource])
    {
        self.showLogoBug = NO;
        self.showsUserLocation = YES;
        self.hideAttribution = YES;
        
    }
    return self;
}

-(UIImageView *)plusImageView
{
    if (!_plusImageView) {
        _plusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus.png"]];
    }
    return  _plusImageView;
}

-(void)layoutSubviews
{
    [super layoutSubviews];
    self.plusImageView.center = self.center;
    [self addSubview:self.plusImageView];
}

@end
