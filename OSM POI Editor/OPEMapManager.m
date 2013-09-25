//
//  OPEMapManager.m
//  OSM POI Editor
//
//  Created by David on 9/24/13.
//
//

#import "OPEMapManager.h"

#import "RMMapViewDelegate.h"
#import "RMMarker.h"
#import "RMMapView.h"
#import "RMAnnotation.h"
#import "RMPointAnnotation.h"
#import "RMShape.h"

#import "OPEManagedOsmElement.h"
#import "OPEManagedOsmNode.h"
#import "OPEManagedOsmWay.h"
#import "OPEManagedOsmRelation.h"
#import "Note.h"

#import "OPEOSMData.h"
#import "OPEGeoCentroid.h"

@implementation OPEMapManager

@synthesize osmData = _osmData;
@synthesize delegate;



-(id)init
{
    if(self = [super init])
    {
        imageDictionary = [NSMutableDictionary dictionary];
        operationQueue = [[NSOperationQueue alloc] init];
        operationQueue.maxConcurrentOperationCount = 2;
    }
    return self;
}

- (id)initWithDelegate:(id<RMMapViewDelegate>)newDelegate
{
    if (self = [self init]) {
        self.delegate = newDelegate;
    }
    return self;
}

-(OPEOSMData *)osmData
{
    if(!_osmData) {
        _osmData = [[OPEOSMData alloc] init];
    }
    return _osmData;
}
//Create Bordered image for annotation
- (UIImage*)imageWithBorderFromImage:(UIImage*)source  //Draw box around centered image
{
    CGSize imgSize = [source size];
    
    //NSLog(@"Image Size: h-%f w-%f",size.height,size.width);
    float rectSize;
    if (imgSize.width > imgSize.height) {
        rectSize = imgSize.width;
    }
    else {
        rectSize = imgSize.height;
    }
    UIView * view;
    view = [[UIView alloc] initWithFrame:CGRectMake(0, 0, rectSize+4,rectSize+4)];
    UIImageView * imageView = [[UIImageView alloc] initWithImage:source];
    
    [view addSubview:imageView];
    [view sizeToFit];
    imageView.center = view.center; //Center the Image
    
    [view.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [view.layer setBorderWidth: 1.0];
    [view setBackgroundColor:[UIColor whiteColor]];
    
    CGSize size = [view bounds].size;
    UIGraphicsBeginImageContextWithOptions(size, NO, 0.0f);
    [[view layer] renderInContext:UIGraphicsGetCurrentContext()];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}


-(RMMarker *)markerWithManagedObject:(OPEManagedOsmElement *)managedOsmElement
{
    UIImage * icon = nil;
    if (managedOsmElement.type) {
        if ([imageDictionary objectForKey:managedOsmElement.type.imageString]) {
            icon = [imageDictionary objectForKey:managedOsmElement.type.imageString];
        }
        else {
            NSString * imageString = managedOsmElement.type.imageString;
            if(![UIImage imageNamed:imageString])
                imageString = @"none.png";
            
            icon = [self imageWithBorderFromImage:[UIImage imageNamed:imageString]]; //center image inside box
            [imageDictionary setObject:icon forKey:managedOsmElement.type.imageString];
        }
    }
    RMMarker *newMarker = [[RMMarker alloc] initWithUIImage:icon anchorPoint:CGPointMake(0.5, 0.5)];
    newMarker.userInfo = managedOsmElement;
    newMarker.zPosition = 0.2;
    return newMarker;
}

-(RMAnnotation *)annotationWForNote:(Note *)note withMapView:(RMMapView *)mapView
{
    RMAnnotation * annotation = [RMAnnotation annotationWithMapView:mapView coordinate:note.coordinate andTitle:@"Note"];
    annotation.userInfo = note;
    return annotation;
}

-(NSArray *)annotationsForOsmElement:(OPEManagedOsmElement *)managedOsmElement withMapView:(RMMapView *)mapView
{
    //NSLog(@"center: %@",[managedOsmElement center]);
    [self.osmData getTypeFor:managedOsmElement];
    
    RMAnnotation * annotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:[self.osmData centerForElement:managedOsmElement] andTitle:[self.osmData nameForElement:managedOsmElement]];
    
    NSMutableString * subtitleString = [NSMutableString stringWithFormat:@"%@",managedOsmElement.type.categoryName];
    
    if ([[managedOsmElement valueForOsmKey:@"name"] length]) {
        [subtitleString appendFormat:@" - %@",managedOsmElement.type.name];
    }
    annotation.subtitle = subtitleString;
    
    
    annotation.userInfo = managedOsmElement;
    
    if ([managedOsmElement isKindOfClass:[OPEManagedOsmRelation class]]) {
        OPEManagedOsmRelation * managedRelation = (OPEManagedOsmRelation *)managedOsmElement;
        
        NSArray * outerPolygonArray = [self.osmData outerPolygonsForRelation:managedRelation];
        
        NSMutableArray * annotationsArray = [NSMutableArray array];
        for (NSArray * pointsArray in outerPolygonArray)
        {
            
            CLLocationCoordinate2D center = [[[OPEGeoCentroid alloc] init] centroidOfPolygon:pointsArray];
            RMAnnotation * newAnnoation = [RMAnnotation annotationWithMapView:mapView coordinate:center andTitle:annotation.title];
            newAnnoation.subtitle = annotation.subtitle;
            newAnnoation.userInfo = annotation.userInfo;
            //set center for each outer;
            [annotationsArray addObject:newAnnoation];
        }
        if ([annotationsArray count]) {
            return annotationsArray;
        }
        
    }
    
    
    return @[annotation];
}

-(RMAnnotation *)shapeForRelation:(OPEManagedOsmRelation *)relation withMapView:(RMMapView *)mapView
{
    NSArray * outerPoints = [self.osmData outerPolygonsForRelation:relation];
    NSArray * innerPoints = [self.osmData innerPolygonsForRelation:relation];
    
    if (![outerPoints count]) {
        return nil;
    }
    RMAnnotation * newAnnotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:((CLLocation *)[[outerPoints objectAtIndex:0] objectAtIndex:0]).coordinate andTitle:nil];
    
    RMShape *shape = [[RMShape alloc] initWithView:mapView];
    
    [shape performBatchOperations:^(RMShape *aShape)
     {
         for (NSArray * points in outerPoints)
         {
             [aShape moveToCoordinate:((CLLocation *)[points objectAtIndex:0]).coordinate];
             for (CLLocation *point in points)
             {
                 [aShape addLineToCoordinate:point.coordinate];
             }
             //[aShape closePath];
             
         }
         
         if ([innerPoints count])
         {
             [aShape moveToCoordinate:((CLLocation *)[[innerPoints objectAtIndex:0] objectAtIndex:0]).coordinate];
             for (NSArray * points in innerPoints)
             {
                 [aShape moveToCoordinate:((CLLocation *)[points objectAtIndex:0]).coordinate];
                 for (CLLocation *point in points)
                 {
                     [aShape addLineToCoordinate:point.coordinate];
                 }
                 //[aShape closePath];
                 
             }
             
             
             
         }
         aShape.lineColor = [UIColor blackColor];
         aShape.lineWidth +=1;
         aShape.fillColor = [UIColor colorWithWhite:.5 alpha:.6];
         aShape.fillRule  = kCAFillRuleEvenOdd;
     }];
    
    newAnnotation.layer = shape;
    return newAnnotation;
    
}
-(RMAnnotation *)shapeForWay:(OPEManagedOsmWay *)way withMapView:(RMMapView *)mapView
{
    
    NSArray * points = [self.osmData pointsForWay:way];
    BOOL isArea = [self.osmData isArea:way];
    
    RMAnnotation * newAnnotation = [[RMAnnotation alloc] initWithMapView:mapView coordinate:((CLLocation *)[points objectAtIndex:0]).coordinate andTitle:nil];
    
    
    
    RMShape * shape = [[RMShape alloc]initWithView:mapView];
    [shape performBatchOperations:^(RMShape *aShape) {
        [aShape moveToCoordinate:((CLLocation *)[points objectAtIndex:0]).coordinate];
        
        for (CLLocation *point in points)
            [aShape addLineToCoordinate:point.coordinate];
        
        if (isArea) {
            [aShape closePath];
        }
        
        
        
    }];
    shape.lineColor = [UIColor blackColor];
    shape.lineWidth +=1;
    if (isArea) {
        shape.fillColor = [UIColor colorWithWhite:.5 alpha:.6];
    }
    else
    {
        shape.fillColor = [UIColor clearColor];
    }
    newAnnotation.layer = shape;
    return newAnnotation;
    
}

//////////////////////////////////
#pragma mark AnnotationManagement
//////////////////////////////////

-(void)addNotes:(NSArray *)notes withMapView:(RMMapView *)mapView
{
    [notes enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        RMAnnotation * annotation = [self annotationWForNote:obj withMapView:mapView];
        [mapView addAnnotation:annotation];
    }];
}

-(void)addAnnotationsForOsmElements:(NSArray *)elementsArray withMapView:(RMMapView *)mapView {
    [elementsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
        NSArray * annotationsArray = [self annotationsForOsmElement:obj withMapView:mapView];
        [annotationsArray enumerateObjectsUsingBlock:^(id obj, NSUInteger idx, BOOL *stop) {
            [mapView addAnnotation:obj];
        }];
    }];
}

-(void)updateAnnotationsForOsmElements:(NSArray *)elementsArray withMapView:(RMMapView *)mapView {
    for (OPEManagedOsmElement * element in elementsArray)
    {
        [self removeAnnotationForOsmElement:element withMapView:mapView];
        if (![element.action isEqualToString:kActionTypeDelete]) {
            NSArray * annotationsArray = [self annotationsForOsmElement:element withMapView:mapView];
            for(RMAnnotation * annotation in annotationsArray) {
                [mapView addAnnotation:annotation];
            }
        }
    }
}

-(void)removeAnnotationForOsmElement:(OPEManagedOsmElement *)element withMapView:(RMMapView *)mapView
{
    NSSet * annotationSet = [self existingAnnotationsForOsmElement:element withMapView:mapView];
    if ([annotationSet count])
    {
        [mapView removeAnnotations:[annotationSet allObjects]];
    }
}

-(NSSet *)existingAnnotationsForOsmElement:(OPEManagedOsmElement *)element withMapView:(RMMapView *)mapView {
    NSIndexSet * indexSet = [self indexesOfOsmElement:element withMapView:mapView];
    NSMutableSet * annotationSet = [NSMutableSet set];
    
    [indexSet enumerateIndexesUsingBlock:^(NSUInteger idx, BOOL *stop) {
        [annotationSet addObject:[mapView.annotations objectAtIndex:idx]];
    }];
    
    return annotationSet;
}

-(NSIndexSet *)indexesOfOsmElement:(OPEManagedOsmElement *)element withMapView:(RMMapView *)mapView
{
    NSIndexSet * set = [mapView.annotations indexesOfObjectsPassingTest:^BOOL(id obj, NSUInteger idx, BOOL *stop) {
        RMAnnotation * annotation = (RMAnnotation *)obj;
        return [annotation.userInfo isEqual:element];
    }];
    return set;
}

/////////////////////////////////
#pragma mark RMMapViewDelegate
/////////////////////////////////

-(RMMapLayer *) mapView:(RMMapView *)mView layerForAnnotation:(RMAnnotation *)annotation
{
    RMMarker * marker = nil;
    if ([annotation.userInfo isKindOfClass:[OPEManagedOsmElement class]]) {
        OPEManagedOsmElement * managedOsmElement = (OPEManagedOsmElement *)annotation.userInfo;;
        
        marker = [self markerWithManagedObject:managedOsmElement];
        marker.canShowCallout = YES;
        marker.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
    }
    else if ([annotation.userInfo isKindOfClass:[Note class]]) {
        Note * note = annotation.userInfo;
        UIImage * image = nil;
        if (note.isOpen) {
            image = [UIImage imageNamed:@"note_open.png"];
        }
        else {
            image = [UIImage imageNamed:@"note_closed.png"];
        }
        marker = [[RMMarker alloc] initWithUIImage:image anchorPoint:CGPointMake(0.5, 0.5)];
        marker.canShowCallout = NO;
    }
    return marker;
}

-(void)tapOnAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)mapView
{
    if (wayAnnotation) {
        [mapView removeAnnotation:wayAnnotation];
        wayAnnotation = nil;
    }
    
    id osmElement = annotation.userInfo;
    
    if ([osmElement isKindOfClass:[OPEManagedOsmWay class]]) {
        OPEManagedOsmWay * osmWay = (OPEManagedOsmWay *)osmElement;
        
        wayAnnotation = [self shapeForWay:osmWay withMapView:mapView];
        wayAnnotation.userInfo = annotation.userInfo;
        [mapView addAnnotation:wayAnnotation];
    }
    else if ([osmElement isKindOfClass:[OPEManagedOsmRelation  class]])
    {
        OPEManagedOsmRelation * osmRelation = (OPEManagedOsmRelation *)osmElement;
        wayAnnotation = [self shapeForRelation:osmRelation withMapView:mapView];
        wayAnnotation.userInfo = annotation.userInfo;
        [mapView addAnnotation:wayAnnotation];
    }

    if ([self.delegate respondsToSelector:@selector(tapOnAnnotation:onMap:)]) {
        [self.delegate tapOnAnnotation:annotation onMap:mapView];
    }
}

- (BOOL) mapView:(RMMapView *)map shouldDragMarker:(RMMarker *)marker withEvent:(UIEvent *)event
{
    return NO;
}

- (void)tapOnCalloutAccessoryControl:(UIControl *)control forAnnotation:(RMAnnotation *)annotation onMap:(RMMapView *)mapView
{
    if ([self.delegate respondsToSelector:@selector(tapOnCalloutAccessoryControl:forAnnotation:onMap:)]) {
        [self.delegate tapOnCalloutAccessoryControl:control forAnnotation:annotation onMap:mapView];
    }
}

- (void)afterMapMove:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    if ([self.delegate respondsToSelector:@selector(afterMapMove:byUser:)]) {
        [self.delegate afterMapMove:map byUser:wasUserAction];
    }
    
}

- (void)afterMapZoom:(RMMapView *)map byUser:(BOOL)wasUserAction
{
    if([self.delegate respondsToSelector:@selector(afterMapZoom:byUser:)]) {
        [self.delegate afterMapZoom:map byUser:wasUserAction];
    }
}






@end
