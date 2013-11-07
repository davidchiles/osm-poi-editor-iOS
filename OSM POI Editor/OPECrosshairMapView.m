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
        [self addSubview:self.plusImageView];
        
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
        [self addSubview:self.plusImageView];
        
    }
    return self;
}

-(UIImageView *)plusImageView
{
    if (!_plusImageView) {
        _plusImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plus.png"]];
        _plusImageView.translatesAutoresizingMaskIntoConstraints = NO;
    }
    return  _plusImageView;
}

-(void)updateConstraints
{
    [super updateConstraints];
    
    NSLayoutConstraint * constraint = [NSLayoutConstraint constraintWithItem:self.plusImageView
                                                                   attribute:NSLayoutAttributeCenterX
                                                                   relatedBy:NSLayoutRelationEqual
                                                                      toItem:self
                                                                   attribute:NSLayoutAttributeCenterX
                                                                  multiplier:1.0
                                                                    constant:0.0];
    [self addConstraint:constraint];
    
    constraint = [NSLayoutConstraint constraintWithItem:self.plusImageView
                                              attribute:NSLayoutAttributeCenterY
                                              relatedBy:NSLayoutRelationEqual
                                                 toItem:self
                                              attribute:NSLayoutAttributeCenterY
                                             multiplier:1.0
                                               constant:0.0];
    [self addConstraint:constraint];
}

@end
