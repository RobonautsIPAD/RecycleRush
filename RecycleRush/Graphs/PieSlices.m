//
//  PieSlices.m
//  RecycleRush
//
//  Created by FRC on 4/9/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "PieSlices.h"

@implementation PieSlices
-(id)init:(NSString *)title withLegend:(NSString *)legend forValue:(NSNumber *)value {
    if ((self = [super init])) {
        _sliceTitle = title;
        _legendTitle = legend;
        _sliceValue = value;
	}
	return self;
}

@end
