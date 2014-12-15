//
//  MapAnnotation.h
//
//  Created by Milosz Winkler
//
//

//#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <MapKit/MKAnnotation.h>

@interface MapAnnotation : NSObject  <MKAnnotation>

@property (nonatomic, copy) NSString *title;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordinate;
@property (nonatomic, copy) NSString *subtitle;
@property (nonatomic,readwrite) UIImage *image;
@property (nonatomic,readwrite) int index;

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord image:(UIImage*)image title:(NSString *)title subtitle:(NSString*)subtitle index:(int)index;


@end