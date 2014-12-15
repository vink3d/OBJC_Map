//
//  ViewController.m
//  OBJC_Map
//
//  Created by Vink on 13.12.2014.
//  Copyright (c) 2014 winklerstudio. All rights reserved.
//

#import "ViewController.h"
#import "MapViewController.h"

@interface ViewController ()

@end


@implementation ViewController

- (id)init
{
    self = [super init];
    if (self) {
        // Custom initialization
        
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    _buttonMap.hidden = true;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - functions

-(void)getJson {
    
    Reachability *reach = [Reachability reachabilityWithHostname:@"www.winklerstudio.com"];
    
    
    if ([reach isReachable]){
        
        // connection
        _buttonMap.hidden = true;
        
        _responseData = [[NSMutableData alloc]init];
        NSURL *url = [[NSURL alloc] initWithString:@"http://winklerstudio.com/test.json"];
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        
        [request setValue:@"application/json" forHTTPHeaderField:@"accept"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        (void)[NSURLConnection connectionWithRequest:request delegate:self];
        
        [_activityIndicator startAnimating];
        _textView.text = @"Loading data...";
        
    } else {
        [self displayAlertWithTitle:@"Net problem" message: @"Network connection problem"];
    }
}

-(void)parseJson:(NSString *)jsonString{
    
    NSError *error = nil;
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    // Get JSON data into a Foundation object
    id object = [NSJSONSerialization JSONObjectWithData:jsonData options:NSJSONReadingAllowFragments error:&error];
    
    
    // Verify object retrieved is dictionary
    if ([object isKindOfClass:[NSDictionary class]] && error == nil)
    {
        NSLog(@"dictionary: %@", object);
        
        // Get the value (string) for key 'next_page'
        _json_text = [object objectForKey:@"text"];
        _json_url = [object objectForKey:@"image"];
        
        
        // Get the value (an array) for key 'results'
        NSArray *array;
        
        if ([[object objectForKey:@"location"] isKindOfClass:[NSDictionary class]])
        {
            array = [object objectForKey:@"location"];
            NSLog(@"results array: %@", array);
            
            NSDictionary *locationDict = [object objectForKey:@"location"];
            
            _json_lat = [[locationDict objectForKey:@"latitude"]  doubleValue];
            _json_long = [[locationDict objectForKey:@"longitude"]  doubleValue];
            
        }
        
        
        // get image from json url
        [self getImage:_json_url];
        
        
    }
    
}

-(void)getImage:(NSString *)url {
    NSURL *imageURL = [NSURL URLWithString:url];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:imageURL];
    
    NSURLSession *session = [NSURLSession sharedSession];
    
    //
    
    void (^completionHandler)(NSData *data, NSURLResponse *response, NSError *error) = ^(NSData *data, NSURLResponse *response, NSError *error) {
        if (error == nil) {
            _json_image = [UIImage imageWithData:data];
            
            //prepare obj
            [self addObject];
            
            //preview json data in text view
            NSString *outputText = [NSString stringWithFormat: @"jsonImage: %@ \n\njsonLat: %f\n\njsonLong: %f\n\njsonText: %@", _json_url, _json_lat, _json_long, _json_text];
            
            NSLog(@"task");
            
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                _textView.text = outputText;
                [_activityIndicator stopAnimating];
                _buttonMap.hidden = false;
            });
            
        } else {
            
            dispatch_sync(dispatch_get_main_queue(), ^{
                _textView.text = @"Data not loaded";
                [_activityIndicator stopAnimating];
                
            });
        }
        
    };
    
    NSURLSessionDataTask *sessionTask = [session dataTaskWithRequest:request completionHandler:completionHandler];
    
    [sessionTask resume];
    
    
}

-(void)addObject {
    
    // prepare object
    _mapObject = [[MapObject alloc] init:_json_text image:_json_image latitude:_json_lat longitude:_json_long];
    
}

#pragma mark - NSURLConnection Delegates

- (void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error  {
    
}

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response   {
    [_responseData setLength:0];
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data  {
    [_responseData appendData:data];
}

- (void)connectionDidFinishLoading:(NSURLConnection *)connection    {
    
    NSString *responseString = [[NSString alloc]initWithData:_responseData encoding:NSUTF8StringEncoding];
    NSLog(@"%@",responseString);
    
    [self parseJson:responseString];
    
}

#pragma mark - actions
- (IBAction)loadJson:(id)sender {
    
    [self getJson];
}

- (IBAction)showMap:(id)sender {
    
}

#pragma mark - segues
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"showMap"]) {
        NSLog(@"sjow map segue");
        
        MapViewController *controller = (MapViewController *)segue.destinationViewController;
        controller.mapObject = _mapObject;
        
    }
}

- (IBAction)unwindToThisViewController:(UIStoryboardSegue *)unwindSegue
{
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




@end
