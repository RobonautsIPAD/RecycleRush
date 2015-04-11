//
//  PlotDefinition.h
//  RecycleRush
//
//  Created by FRC on 4/9/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PlotDefinition : NSObject
@property (nonatomic, strong) NSString *plotTitle;
@property (nonatomic, strong) NSString *xAxisTitle;
@property (nonatomic, strong) NSString *yAxisTitle;
@property (nonatomic, strong) NSArray *plotData;
-(id)init:(NSString *)title;

@end
