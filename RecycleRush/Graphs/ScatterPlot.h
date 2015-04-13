//
//  ScatterPlot.h
//  RecycleRush
//
//  Created by FRC on 4/10/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@class PlotDefinition;

#ifdef __IPHONE_7_0
@interface ScatterPlot : NSObject <CPTPlotDataSource>
-(void)initPlot:(UIView *)graphView withDefinition:(PlotDefinition *)plotDefinition;

#else
@interface ScatterPlot : NSObject
#endif
@end
