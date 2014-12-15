//
//  MapAnnotation.cpp
//
//  Created by Milosz Winkler
//
//
#import "MapAnnotation.h"

@implementation MapAnnotation

- (id)initWithCoordinate:(CLLocationCoordinate2D)coord image:(UIImage*)image title:(NSString *)title subtitle:(NSString*)subtitle index:(int)index
{
	self = [super init];
    
    _coordinate = coord;
    _image = image;

	_title = title;
    _subtitle = subtitle;
    
    _index = index;
    
	return self;
}

@end
