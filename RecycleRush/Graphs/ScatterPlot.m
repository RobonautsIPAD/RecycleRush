//
//  ScatterPlot.m
//  RecycleRush
//
//  Created by FRC on 4/10/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "ScatterPlot.h"
#import "PlotDefinition.h"

@implementation ScatterPlot {
    CPTGraphHostingView *hostView;
    NSString *plotTitle;
    NSString *xAxisTitle;
    NSString *yAxisTitle;
    NSArray *dataToPlot;
}

#ifdef __IPHONE_7_0

-(void)initPlot:(UIView *)graphView withDefinition:(PlotDefinition *)plotDefinition {
    plotTitle = plotDefinition.plotTitle;
    dataToPlot = plotDefinition.plotData;
    [self configureHost:graphView];
    [self configureGraph:graphView];
    [self configurePlots];
    [self configureAxes];
}

#pragma mark - Chart behavior
-(void)configureHost:(UIView *)graphView {
	hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:graphView.bounds];
	hostView.allowPinchScaling = YES;
	[graphView addSubview:hostView];
}

-(void)configureGraph:(UIView *)graphView {
	// 1 - Create the graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:graphView.bounds];
	[graph applyTheme:[CPTTheme themeNamed:kCPTDarkGradientTheme]];
	hostView.hostedGraph = graph;
	// 2 - Set graph title
	NSString *title = plotTitle;
	graph.title = title;
	// 3 - Create and set text style
	CPTMutableTextStyle *titleStyle = [CPTMutableTextStyle textStyle];
	titleStyle.color = [CPTColor whiteColor];
	titleStyle.fontName = @"Helvetica-Bold";
	titleStyle.fontSize = 16.0f;
	graph.titleTextStyle = titleStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, 10.0f);
	// 4 - Set padding for plot area
	[graph.plotAreaFrame setPaddingLeft:30.0f];
	[graph.plotAreaFrame setPaddingBottom:30.0f];
	// 5 - Enable user interactions for plot space
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	plotSpace.allowsUserInteraction = YES;
}

-(void)configurePlots {
	// 1 - Get graph and plot space
	CPTGraph *graph = hostView.hostedGraph;
	CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) graph.defaultPlotSpace;
	// 2 - Create the plots
    NSMutableArray *plot = [[NSMutableArray alloc] init];
    if (!dataToPlot || ![dataToPlot count]) return;
    for (int i = 0; i < [dataToPlot count]; i++) {
        CPTScatterPlot *scatter = [[CPTScatterPlot alloc] init];
        scatter.dataSource = self;
        scatter.identifier = [NSNumber numberWithInt:i];
        CPTColor *scatterColor = [CPTColor redColor];
        [graph addPlot:scatter toPlotSpace:plotSpace];
        [plot addObject:scatter];
        // 4 - Create styles and symbols
        CPTMutableLineStyle *myLineStyle = [scatter.dataLineStyle mutableCopy];
        myLineStyle.lineWidth = 2.5;
        myLineStyle.lineColor = scatterColor;
        scatter.dataLineStyle = myLineStyle;
        CPTMutableLineStyle *mySymbolLineStyle = [CPTMutableLineStyle lineStyle];
        mySymbolLineStyle.lineColor = scatterColor;
        CPTPlotSymbol *symbol = [CPTPlotSymbol ellipsePlotSymbol];
        symbol.fill = [CPTFill fillWithColor:scatterColor];
        symbol.lineStyle = mySymbolLineStyle;
        symbol.size = CGSizeMake(6.0f, 6.0f);
        scatter.plotSymbol = symbol;
    }

	// 3 - Set up plot space
	[plotSpace scaleToFitPlots:plot];
	CPTMutablePlotRange *xRange = [plotSpace.xRange mutableCopy];
	[xRange expandRangeByFactor:CPTDecimalFromCGFloat(1.1f)];
	plotSpace.xRange = xRange;
	CPTMutablePlotRange *yRange = [plotSpace.yRange mutableCopy];
	[yRange expandRangeByFactor:CPTDecimalFromCGFloat(1.2f)];
	plotSpace.yRange = yRange;
}

-(void)configureAxes {
	// 1 - Create styles
	CPTMutableTextStyle *axisTitleStyle = [CPTMutableTextStyle textStyle];
	axisTitleStyle.color = [CPTColor whiteColor];
	axisTitleStyle.fontName = @"Helvetica-Bold";
	axisTitleStyle.fontSize = 12.0f;
	CPTMutableLineStyle *axisLineStyle = [CPTMutableLineStyle lineStyle];
	axisLineStyle.lineWidth = 2.0f;
	axisLineStyle.lineColor = [CPTColor whiteColor];
	CPTMutableTextStyle *axisTextStyle = [[CPTMutableTextStyle alloc] init];
	axisTextStyle.color = [CPTColor whiteColor];
	axisTextStyle.fontName = @"Helvetica-Bold";
	axisTextStyle.fontSize = 11.0f;
	CPTMutableLineStyle *tickLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor whiteColor];
	tickLineStyle.lineWidth = 2.0f;
	CPTMutableLineStyle *gridLineStyle = [CPTMutableLineStyle lineStyle];
	tickLineStyle.lineColor = [CPTColor blackColor];
	tickLineStyle.lineWidth = 1.0f;
	// 2 - Get axis set
	CPTXYAxisSet *axisSet = (CPTXYAxisSet *) hostView.hostedGraph.axisSet;
	// 3 - Configure x-axis
	CPTAxis *x = axisSet.xAxis;
	x.title = @"Day of Month";
	x.titleTextStyle = axisTitleStyle;
	x.titleOffset = 15.0f;
	x.axisLineStyle = axisLineStyle;
	x.labelingPolicy = CPTAxisLabelingPolicyNone;
	x.labelTextStyle = axisTextStyle;
	x.majorTickLineStyle = axisLineStyle;
	x.majorTickLength = 4.0f;
	x.tickDirection = CPTSignNegative;
/*	CGFloat dateCount = [[[CPDStockPriceStore sharedInstance] datesInMonth] count];
	NSMutableSet *xLabels = [NSMutableSet setWithCapacity:dateCount];
	NSMutableSet *xLocations = [NSMutableSet setWithCapacity:dateCount];
	NSInteger i = 0;
	for (NSString *date in [[CPDStockPriceStore sharedInstance] datesInMonth]) {
		CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:date  textStyle:x.labelTextStyle];
		CGFloat location = i++;
		label.tickLocation = CPTDecimalFromCGFloat(location);
		label.offset = x.majorTickLength;
		if (label) {
			[xLabels addObject:label];
			[xLocations addObject:[NSNumber numberWithFloat:location]];
		}
	}
	x.axisLabels = xLabels;
	x.majorTickLocations = xLocations;*/
	// 4 - Configure y-axis
	CPTAxis *y = axisSet.yAxis;
	y.title = @"Price";
	y.titleTextStyle = axisTitleStyle;
	y.titleOffset = -40.0f;
	y.axisLineStyle = axisLineStyle;
	y.majorGridLineStyle = gridLineStyle;
	y.labelingPolicy = CPTAxisLabelingPolicyNone;
	y.labelTextStyle = axisTextStyle;
	y.labelOffset = 16.0f;
	y.majorTickLineStyle = axisLineStyle;
	y.majorTickLength = 4.0f;
	y.minorTickLength = 2.0f;
	y.tickDirection = CPTSignPositive;
	NSInteger majorIncrement = 100;
	NSInteger minorIncrement = 50;
	CGFloat yMax = 700.0f;  // should determine dynamically based on max price
	NSMutableSet *yLabels = [NSMutableSet set];
	NSMutableSet *yMajorLocations = [NSMutableSet set];
	NSMutableSet *yMinorLocations = [NSMutableSet set];
	for (NSInteger j = minorIncrement; j <= yMax; j += minorIncrement) {
		NSUInteger mod = j % majorIncrement;
		if (mod == 0) {
			CPTAxisLabel *label = [[CPTAxisLabel alloc] initWithText:[NSString stringWithFormat:@"%i", j] textStyle:y.labelTextStyle];
			NSDecimal location = CPTDecimalFromInteger(j);
			label.tickLocation = location;
			label.offset = -y.majorTickLength - y.labelOffset;
			if (label) {
				[yLabels addObject:label];
			}
			[yMajorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:location]];
		} else {
			[yMinorLocations addObject:[NSDecimalNumber decimalNumberWithDecimal:CPTDecimalFromInteger(j)]];
		}
	}
	y.axisLabels = yLabels;
	y.majorTickLocations = yMajorLocations;
	y.minorTickLocations = yMinorLocations;
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
    if (dataToPlot && [dataToPlot count]) {
        return [[dataToPlot objectAtIndex:0] count];
    }
	return 0;
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSUInteger plotNumber = [(NSNumber *)plot.identifier intValue];
    NSArray *plotData = [dataToPlot objectAtIndex:plotNumber];
    NSArray *plotPoint = [plotData objectAtIndex:index];
    switch (fieldEnum) {
		case CPTScatterPlotFieldX:
            return [plotPoint objectAtIndex:0];
			break;
		case CPTScatterPlotFieldY:
            return [plotPoint objectAtIndex:1];
			break;
    }
	return [NSDecimalNumber zero];
}

#endif
@end
