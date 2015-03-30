//
//  PieCharts.h
//  RecycleRush
//
//  Created by FRC on 3/29/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface PieCharts : NSObject <CPTPlotDataSource>
-(void)initPlot:(UIView *)hostView withData:(NSArray *)plotData;
@end
