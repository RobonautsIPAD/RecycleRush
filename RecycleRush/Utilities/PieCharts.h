//
//  PieCharts.h
//  RecycleRush
//
//  Created by FRC on 3/29/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

#ifdef __IPHONE_7_0
@interface PieCharts : NSObject <CPTPlotDataSource>
-(void)initPlot:(UIView *)hostView withData:(NSArray *)plotData;

#else
@interface PieCharts : NSObject
#endif
@end
