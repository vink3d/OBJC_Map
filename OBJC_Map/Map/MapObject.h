//
//  JsonObject.h
//  OBJC_Map
//
//  Created by Vink on 14.12.2014.
//  Copyright (c) 2014 winklerstudio. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>

@interface MapObject : NSObject

@property(nonatomic, readwrite) NSString *text;
@property(nonatomic, readwrite) UIImage *image;
@property(nonatomic, readwrite) CLLocationDegrees latitude;
@property(nonatomic, readwrite) CLLocationDegrees longitude;

- (id)init:(NSString *)text image:(UIImage*)image latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;


@end
