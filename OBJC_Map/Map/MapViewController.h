//
//  MapView.h
//
//  Created by Milosz Winkler.
//
//


#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import <CoreLocation/CoreLocation.h>
#import "MapAnnotation.h"
#import "MapObject.h"

@interface MapViewController : UIViewController <MKMapViewDelegate, CLLocationManagerDelegate>

-(void)initManager;
-(void)addPin:(CLLocationCoordinate2D)coordinate image:(UIImage*)image title:(NSString*)title subtitle:(NSString*)subtitle;
-(void)setCenterOfMapToLocation:(CLLocationCoordinate2D)location delta:(double)delta;
-(int)getDistance:(CLLocation*)loc1 loc2:(CLLocation*)loc2;

@property (nonatomic, strong) CLLocationManager *manager;
@property (strong, nonatomic) NSMutableArray *objectArray;
@property (strong, nonatomic) MapObject *mapObject;

@property (nonatomic, readwrite) CLLocationCoordinate2D coordTarget;
@property (nonatomic, readwrite) CLLocationCoordinate2D coordUser;
@property (nonatomic, strong) CLLocation *locTarget;
@property (nonatomic, strong) CLLocation *locUser;
@property (nonatomic, readwrite) int distance;

@property (strong, nonatomic) IBOutlet UILabel *distanceLabel;
@property (strong, nonatomic) IBOutlet MKMapView *mapView;

@end
