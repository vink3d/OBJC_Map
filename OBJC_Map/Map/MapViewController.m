//
//  MapView.m
//
//  Created by Milosz Winkler.
//

#define METERS_PER_MILE 1609.344

#import "MapViewController.h"
#import "ViewController.h"

@interface MapViewController () {
    
    int index;
    
}

@end

@implementation MapViewController


- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization

    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    //new ios 7+ fix scroll view hide below topbar
    if ([self respondsToSelector:@selector(edgesForExtendedLayout)])
        self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.view.autoresizesSubviews = YES;
        
}


-(void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];

    //
    [self initManager];
    [self initMap:_mapObject];
    
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Map view data source

-(void)initMap:(MapObject*)dataObject {
    //get first obj data
    
    CLLocationDegrees latitude = dataObject.latitude;
    CLLocationDegrees longitude = dataObject.longitude;
    
    NSLog(@"data in obj %f %f", dataObject.latitude, dataObject.longitude);
    
    _coordTarget = CLLocationCoordinate2DMake(latitude, longitude);
    _locTarget = [[CLLocation alloc] initWithLatitude:latitude longitude:longitude];

    //map
    _mapView.delegate = self;
    _mapView.mapType = MKMapTypeHybrid;

    CLLocationDegrees delta = 0.01;

    MKCoordinateSpan span = MKCoordinateSpanMake(delta, delta);
    MKCoordinateRegion region = MKCoordinateRegionMake(_coordTarget, span);
    
    [_mapView setRegion:region animated: true];
    
    
    //add target pin
    NSString* subtitle = [NSString stringWithFormat:@"Distance: %d m", _distance];
    NSLog(@"Distance: %d", _distance);
    
    [self addPin:_coordTarget image:dataObject.image title:dataObject.text subtitle:subtitle];
    
}


#pragma - Annotation View

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id <MKAnnotation>)annotation
{
    NSLog(@"add annotation");
    
  
    if ([annotation isKindOfClass:[MapAnnotation class]])
    {
        
        MapAnnotation *senderAnnotation = annotation;
        
        NSString *pinReusableIdentifier = [NSString stringWithFormat:@"annotation_%d",senderAnnotation.index];
        
        MKPinAnnotationView* annotationView = (MKPinAnnotationView *)[mapView dequeueReusableAnnotationViewWithIdentifier:pinReusableIdentifier];
        
        if (annotationView == nil){
            /* If we fail to reuse a pin, then we will create one */
            annotationView = [[MKPinAnnotationView alloc] initWithAnnotation:senderAnnotation reuseIdentifier:pinReusableIdentifier];
           
        }
        
        annotationView.enabled = YES;
        annotationView.canShowCallout = YES;
        
        //additional views
        CGRect frame = CGRectMake(0, 0, 54, 54);
        UIImageView *imageView = [[UIImageView alloc] initWithImage:senderAnnotation.image];
        imageView.frame = frame;
        imageView.layer.masksToBounds = YES;
//        imageView.layer.borderColor = [[UIColor blackColor] CGColor];
//        imageView.layer.borderWidth = 1;
    
        annotationView.leftCalloutAccessoryView = imageView;
        
        return annotationView;
    }
    
    return nil;
    
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKPinAnnotationView*)annotationView
{
    MapAnnotation *annotation = annotationView.annotation;
    NSString* subtitle = [NSString stringWithFormat:@"Distance: %d m", _distance];

    annotation.subtitle = subtitle;

}

#pragma mark - Map view overlay

-(MKOverlayRenderer*)mapView:(MKMapView*)mapView rendererForOverlay:(id<MKOverlay>)overlay  {
    
    
    if ([overlay isKindOfClass:[MKPolyline class]]) {
        NSLog(@"draw MKPolyline");
        
        MKPolyline *poly = (MKPolyline *)overlay;
        MKPolylineRenderer *polylineRenderer = [[MKPolylineRenderer alloc] initWithPolyline:poly];
        polylineRenderer.strokeColor = [UIColor blueColor];
        polylineRenderer.lineWidth = 5;
        return polylineRenderer;
    }
    
    return nil;
}

#pragma mark - directions
-(void)drawDirectionsFrom:(CLLocationCoordinate2D)source to:(CLLocationCoordinate2D)destination {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:source addressDictionary:nil];
    MKMapItem *sourceItem = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    [request setSource:sourceItem];
    
    // Get the placemark of the destination address
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil];
    MKMapItem *destinationItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [request setDestination:destinationItem];
    
    // Set the transportation method to automobile
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    // draw directions
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            MKRoute *route = response.routes.lastObject;
            
            [_mapView addOverlay:route.polyline];
        }
    }];
    
    //change zoom - fit to region
    CLLocation *sourceLocation = [[CLLocation alloc] initWithLatitude:source.latitude longitude:source.longitude];
    CLLocation *targetLocation = [[CLLocation alloc] initWithLatitude:destination.latitude longitude:destination.longitude];

    double distance = [self getDistance:sourceLocation loc2:targetLocation];
    
    CLLocationCoordinate2D center = CLLocationCoordinate2DMake((source.latitude + destination.latitude) / 2.0, (source.longitude + destination.longitude) / 2.0);
    MKCoordinateRegion region = MKCoordinateRegionMakeWithDistance(center, distance, distance);
    
    [_mapView setRegion:region animated: true];
    
}

-(void) getDirectionsFrom:(CLLocationCoordinate2D)source to:(CLLocationCoordinate2D)destination {
    
    MKDirectionsRequest *request = [[MKDirectionsRequest alloc] init];
    
    MKPlacemark *sourcePlacemark = [[MKPlacemark alloc] initWithCoordinate:source addressDictionary:nil];
    MKMapItem *sourceItem = [[MKMapItem alloc] initWithPlacemark:sourcePlacemark];
    [request setSource:sourceItem];
    
    // Get the placemark of the destination address
    MKPlacemark *destinationPlacemark = [[MKPlacemark alloc] initWithCoordinate:destination addressDictionary:nil];
    MKMapItem *destinationItem = [[MKMapItem alloc] initWithPlacemark:destinationPlacemark];
    [request setDestination:destinationItem];
    
    // Set the transportation method to automobile
    request.transportType = MKDirectionsTransportTypeAutomobile;
    
    // Get the directions
    MKDirections *directions = [[MKDirections alloc] initWithRequest:request];
    
    [directions calculateDirectionsWithCompletionHandler:^(MKDirectionsResponse *response, NSError *error) {
        if (error) {
            [self displayAlertWithTitle:@"Navigation problem" message: @"Can't display route"];

            NSLog(@"Error %@", error.description);
        } else {
            MKRoute *route = response.routes.lastObject;
            
            [_mapView addOverlay:route.polyline];
            
            NSDictionary *launchOptions = @{MKLaunchOptionsDirectionsModeKey : MKLaunchOptionsDirectionsModeWalking};
            NSArray *items = @[response.source, response.destination];
            
            [MKMapItem openMapsWithItems:items launchOptions: launchOptions];

        }
    }];
    
}

#pragma mark - location manager

// manager
-(void)initManager{
    
    // test location services
    if ([CLLocationManager locationServicesEnabled]){
        
        CLAuthorizationStatus authorizationStatus= [CLLocationManager authorizationStatus];

        
        switch (authorizationStatus){
            
        case kCLAuthorizationStatusDenied:
                [self displayAlertWithTitle:@"Not Determined" message: @"Location services are not allowed for this app"];
                NSLog(@"location service denied");
            break;
        case kCLAuthorizationStatusNotDetermined:
                _manager = [[CLLocationManager alloc] init];
                _manager.delegate = self;
                [_manager requestWhenInUseAuthorization];

                _manager.distanceFilter = kCLDistanceFilterNone;
                _manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                [_manager startUpdatingLocation];
                
                _mapView.showsUserLocation = YES;

                NSLog(@"location service not determined");
            break;
        case kCLAuthorizationStatusRestricted:
                [self displayAlertWithTitle:@"Restricted" message: @"Location services are not allowed for this app"];

                NSLog(@"location service restricted");
            break;
        default:
                _manager = [[CLLocationManager alloc] init];
                _manager.delegate = self;
                [_manager requestWhenInUseAuthorization];

                _manager.distanceFilter = kCLDistanceFilterNone;
                _manager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
                [_manager startUpdatingLocation];
                
                _mapView.showsUserLocation = YES;

                NSLog(@"location service default");
            break;
        }
        
        
    } else {
        NSLog(@"Location services are not enabled");
    }
}

// location
-(void)locationManager:(CLLocationManager*)manager didUpdateLocations:(NSArray *)locations {
    
    CLGeocoder *geocoder = [[CLGeocoder alloc] init];
    
    [geocoder reverseGeocodeLocation:_manager.location completionHandler:^(NSArray *placemarks, NSError *error) {
        NSLog(@"Finding address");
        if (error) {
            NSLog(@"Error %@", error.description);
        } else {
            //CLPlacemark *placemark = [placemarks lastObject];
            
            if ([placemarks count] > 0) {
                
                CLPlacemark *placemark= placemarks.lastObject;
                [self updateLocationInfo:placemark];
                
                _distance = [self getDistance:_locTarget loc2:_locUser];

            } else {
                NSLog(@"Problem with the data received from geocoder");
            }
        }
    }];
}

-(void)updateLocationInfo:(CLPlacemark*)placemark {
    if(placemark) {
        
        //stop updating location to save battery life
        [_manager stopUpdatingLocation];
        
        NSString* locality = (placemark.locality != nil) ? placemark.locality : @"";
        NSString* postalCode = (placemark.postalCode != nil) ? placemark.postalCode : @"";
        NSString* administrativeArea = (placemark.administrativeArea != nil) ? placemark.administrativeArea : @"";
        NSString* country = (placemark.country != nil) ? placemark.country : @"";
        
        // put user location
        CLLocationDegrees latitude = placemark.location.coordinate.latitude;
        CLLocationDegrees longitude = placemark.location.coordinate.longitude;
        
        _coordUser = CLLocationCoordinate2DMake(latitude, longitude);
        _locUser = placemark.location;
        
        _distanceLabel.text = [NSString stringWithFormat:@"Distance from me: %d m", _distance];
        
        // log names
        NSLog(@"%@", locality);
        NSLog(@"%@", postalCode);
        NSLog(@"%@", administrativeArea);
        NSLog(@"%@", country);
    }
    
}

#pragma mark - functions

-(void)addPin:(CLLocationCoordinate2D)coordinate image:(UIImage*)image title:(NSString*)title subtitle:(NSString*)subtitle
{
    NSLog(@"add pin: %@", title);
    
    /* Create the annotations using the location */
    MapAnnotation *annotation = [[MapAnnotation alloc] initWithCoordinate:coordinate image:image title:title subtitle:subtitle index:0];
    
    /* And eventually add them to the map */
    [_mapView addAnnotation:annotation];
    
    /* And now center the map around the point */
    [self setCenterOfMapToLocation:_coordTarget delta:0.01];
}

-(void)setCenterOfMapToLocation:(CLLocationCoordinate2D)location delta:(double)delta {
    
    MKCoordinateSpan span = MKCoordinateSpanMake(delta, delta);
    MKCoordinateRegion region = MKCoordinateRegionMake(location, span);
    
    [_mapView setRegion:region animated: true];
}

-(int)getDistance:(CLLocation*)loc1 loc2:(CLLocation*)loc2 {
    CLLocationDistance distance = [loc1 distanceFromLocation:loc2];
    
    return distance;
}


// alert
-(void) displayAlertWithTitle:(NSString*)title  message:(NSString*)message
{
    
    UIAlertController *alert = [UIAlertController
                                    alertControllerWithTitle:title
                                    message:message
                                    preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *action = [UIAlertAction actionWithTitle:@"OK" style:UIAlertActionStyleDefault handler:nil];
    [alert addAction:action];
    
    [self presentViewController:alert animated:YES completion:nil];

}


#pragma - actions
- (IBAction)myLocation:(id)sender {
    
    if (CLLocationCoordinate2DIsValid(_coordUser)) {
        
        [self setCenterOfMapToLocation:_coordUser delta:0.01];
        
    } else {
        [self displayAlertWithTitle:@"GPS problem" message: @"Can't determine your location"];
    }
    
}
- (IBAction)targetLocation:(id)sender {
    if (CLLocationCoordinate2DIsValid(_coordTarget)) {
        [self setCenterOfMapToLocation:_coordTarget delta:0.01];
    } else {
        [self displayAlertWithTitle:@"GPS problem" message: @"Can't determine your location"];
    }
}
- (IBAction)drawRoute:(id)sender {
    if (CLLocationCoordinate2DIsValid(_coordUser)) {
        [self drawDirectionsFrom:_coordUser to:_coordTarget];
    } else {
        [self displayAlertWithTitle:@"GPS problem" message: @"Can't determine your location"];

    }
    
}
- (IBAction)showNavigation:(id)sender {
    if (CLLocationCoordinate2DIsValid(_coordUser)) {
        [self getDirectionsFrom:_coordUser to:_coordTarget];
    } else {
        [self displayAlertWithTitle:@"GPS problem" message: @"Can't determine your location"];

    }
}

@end
