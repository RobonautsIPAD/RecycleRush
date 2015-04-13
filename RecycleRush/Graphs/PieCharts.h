//
//  PieCharts.h
//  RecycleRush
//
//  Created by FRC on 3/29/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlotDefinition;

#ifdef __IPHONE_7_0
@interface PieCharts : NSObject <CPTPlotDataSource>
-(void)initPlot:(UIView *)graphView withDefinition:(PlotDefinition *)plotDefinition;

#else
@interface PieCharts : NSObject
#endif
@end
