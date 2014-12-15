//
//  ViewController.h
//  OBJC_Map
//
//  Created by Vink on 13.12.2014.
//  Copyright (c) 2014 winklerstudio. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <MapKit/MapKit.h>
#import "MapObject.h"
#import "Reachability.h"

@interface ViewController : UIViewController

-(void)getJson;
-(void)parseJson:(NSString *)jsonString;
-(void)addObject;
-(void)getImage:(NSString *)url;

@property(nonatomic, strong) NSMutableData *responseData;
@property(nonatomic, strong) MapObject *mapObject;
@property (nonatomic, readwrite) BOOL net;

@property(nonatomic, strong) NSString *json_text;
@property(nonatomic, strong) NSString *json_url;
@property(nonatomic, readwrite) CLLocationDegrees json_lat;
@property(nonatomic, readwrite) CLLocationDegrees json_long;
@property(nonatomic, strong) UIImage *json_image;

@property (strong, nonatomic) IBOutlet UITextView *textView;
@property (strong, nonatomic) IBOutlet UIButton *buttonMap;
@property (strong, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@end

