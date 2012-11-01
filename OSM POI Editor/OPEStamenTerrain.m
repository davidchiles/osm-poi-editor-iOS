//
//  OPEStamenTerrain.m
//  OSM POI Editor
//
//  Created by David Chiles on 3/26/12.
//  Copyright (c) 2012 __MyCompanyName__. All rights reserved.
//

#import "OPEStamenTerrain.h"

@implementation OPEStamenTerrain



-(id) init
{       
	if(self = [super init]) 
	{
		//http://wiki.openstreetmap.org/index.php/FAQ#What_is_the_map_scale_for_a_particular_zoom_level_of_the_map.3F 
		[self setMaxZoom:18];
		[self setMinZoom:1];
	}
	return self;
} 

-(NSURL *)URLForTile:(RMTile)tile
{
    NSAssert4(((tile.zoom >= self.minZoom) && (tile.zoom <= self.maxZoom)),
			  @"%@ tried to retrieve tile with zoomLevel %d, outside source's defined range %f to %f",
			  self, tile.zoom, self.minZoom, self.maxZoom);
    
    return [NSURL URLWithString:[NSString stringWithFormat:@"http://tile.stamen.com/terrain/%d/%d/%d.png", tile.zoom, tile.x, tile.y]];
    
}

-(NSString*) uniqueTilecacheKey
{
	return @"StamenTerrain";
}

-(NSString *)shortName
{
	return @"Stamen Terrain";
}
-(NSString *)longDescription
{
	return @"Map tiles by Stamen Design, under CC BY 3.0. Data by OpenStreetMap, under CC BY SA.";
}
-(NSString *)shortAttribution
{
	return @"© OpenStreetMap CC-BY-SA";
}
-(NSString *)longAttribution
{
	return @"Map data © OpenStreetMap, licensed under Creative Commons Share Alike By Attribution.";
}

@end
