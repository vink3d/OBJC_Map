//
//  JsonObject.m
//  OBJC_Map
//
//  Created by Vink on 14.12.2014.
//  Copyright (c) 2014 winklerstudio. All rights reserved.
//

#import "MapObject.h"

@implementation MapObject

-(id)init:(NSString *)text image:(UIImage*)image latitude:(CLLocationDegrees)latitude longitude:(CLLocationDegrees)longitude;
{
    self = [super init];
    
    _text = text;
    _image = image;
    _latitude = latitude;
    _longitude = longitude;
    
    return self;
}

@end
