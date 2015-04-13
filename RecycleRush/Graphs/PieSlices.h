//
//  PieSlices.h
//  RecycleRush
//
//  Created by FRC on 4/9/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PieSlices : NSObject
@property (nonatomic, strong) NSString *sliceTitle;
@property (nonatomic, strong) NSString *legendTitle;
@property (nonatomic, strong) NSNumber *sliceValue;
-(id)init:(NSString *)title withLegend:(NSString *)legend forValue:(NSNumber *)value;
@end
