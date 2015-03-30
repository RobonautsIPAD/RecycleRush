//
//  PieCharts.m
//  RecycleRush
//
//  Created by FRC on 3/29/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "PieCharts.h"

@implementation PieCharts {
    CPTGraphHostingView *hostView;
    NSArray *dataToPlot;
    CPTTheme *selectedTheme;
}

-(void)initPlot:(UIView *)graphView withData:(NSArray *)plotData {
    dataToPlot = plotData;
    [self configureHost:(UIView *)graphView];
    [self configureGraph];
    [self configureChart];
    [self configureLegend];
}

#pragma mark - Chart behavior

-(void)configureHost:(UIView *)graphView {
	// 1 - Set up view frame
	CGRect parentRect = graphView.bounds;
	// 2 - Create host view
	hostView = [(CPTGraphHostingView *) [CPTGraphHostingView alloc] initWithFrame:parentRect];
	hostView.allowPinchScaling = NO;
	[graphView addSubview:hostView];
}

-(void)configureGraph {
	// 1 - Create and initialise graph
	CPTGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostView.bounds];
	hostView.hostedGraph = graph;
	graph.paddingLeft = 0.0f;
	graph.paddingTop = 0.0f;
	graph.paddingRight = 0.0f;
	graph.paddingBottom = 0.0f;
	graph.axisSet = nil;
	// 2 - Set up text style
	CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
	textStyle.color = [CPTColor grayColor];
	textStyle.fontName = @"Helvetica-Bold";
	textStyle.fontSize = 16.0f;
	// 3 - Configure title
	NSString *title = @"Human vs Landfill Intake";
	graph.title = title;
	graph.titleTextStyle = textStyle;
	graph.titlePlotAreaFrameAnchor = CPTRectAnchorTop;
	graph.titleDisplacement = CGPointMake(0.0f, -12.0f);
	// 4 - Set theme
    selectedTheme = [CPTTheme themeNamed:kCPTPlainWhiteTheme];
	[graph applyTheme:selectedTheme];
}

-(void)configureChart {
	// 1 - Get reference to graph
	CPTGraph *graph = hostView.hostedGraph;
	// 2 - Create chart
	CPTPieChart *pieChart = [[CPTPieChart alloc] init];
	pieChart.dataSource = self;
	pieChart.delegate = self;
	pieChart.pieRadius = (hostView.bounds.size.height * 0.7) / 2;
	pieChart.identifier = graph.title;
	pieChart.startAngle = M_PI_4;
	pieChart.sliceDirection = CPTPieDirectionClockwise;
	// 3 - Create gradient
	CPTGradient *overlayGradient = [[CPTGradient alloc] init];
	overlayGradient.gradientType = CPTGradientTypeRadial;
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.0] atPosition:0.9];
	overlayGradient = [overlayGradient addColorStop:[[CPTColor blackColor] colorWithAlphaComponent:0.4] atPosition:1.0];
	pieChart.overlayFill = [CPTFill fillWithGradient:overlayGradient];
	// 4 - Add chart to graph
	[graph addPlot:pieChart];
}

-(void)configureLegend {
	// 1 - Get graph instance
	CPTGraph *graph = hostView.hostedGraph;
	// 2 - Create legend
    //	CPTLegend *theLegend = [CPTLegend legendWithGraph:graph];
	// 3 - Configure legen
    /*	theLegend.numberOfColumns = 1;
     theLegend.fill = [CPTFill fillWithColor:[CPTColor whiteColor]];
     theLegend.borderLineStyle = [CPTLineStyle lineStyle];
     theLegend.cornerRadius = 5.0;
     // 4 - Add legend to graph
     graph.legend = theLegend;
     graph.legendAnchor = CPTRectAnchorRight;
     CGFloat legendPadding = -(self.view.bounds.size.width / 8);
     graph.legendDisplacement = CGPointMake(legendPadding, 0.0);*/
}

#pragma mark - CPTPlotDataSource methods
-(NSUInteger)numberOfRecordsForPlot:(CPTPlot *)plot {
	return [dataToPlot count];
}

-(NSNumber *)numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    /*	if (CPTPieChartFieldSliceWidth == fieldEnum) {
     return [[[CPDStockPriceStore sharedInstance] dailyPortfolioPrices] objectAtIndex:index];
     }*/
	return [dataToPlot objectAtIndex:index];
}

-(CPTFill *)sliceFillForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index
{
    CPTFill *areaGradientFill ;
    
    if (index==0)
        return areaGradientFill= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:237.0/255 green:28.0/255 blue:36.0/255 alpha:1.0]];
    else if (index==1)
        return areaGradientFill= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:0.0 green:101.0/255 blue:179.0/255 alpha:1.0]];
    else if (index==2)
        return areaGradientFill= [CPTFill fillWithColor:[CPTColor colorWithComponentRed:167.0/255 green:169.0/255 blue:172.0/255 alpha:1.0]];
    
    return areaGradientFill;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)index {
	// 1 - Define label text style
	static CPTMutableTextStyle *labelText = nil;
	if (!labelText) {
		labelText= [[CPTMutableTextStyle alloc] init];
		labelText.color = [CPTColor grayColor];
	}
    /*	if (!labelText) {
     labelText= [[CPTMutableTextStyle alloc] init];
     labelText.color = [CPTColor grayColor];
     }
     // 2 - Calculate portfolio total value
     NSDecimalNumber *portfolioSum = [NSDecimalNumber zero];
     for (NSDecimalNumber *price in [[CPDStockPriceStore sharedInstance] dailyPortfolioPrices]) {
     portfolioSum = [portfolioSum decimalNumberByAdding:price];
     }
     // 3 - Calculate percentage value
     NSDecimalNumber *price = [[[CPDStockPriceStore sharedInstance] dailyPortfolioPrices] objectAtIndex:index];
     NSDecimalNumber *percent = [price decimalNumberByDividingBy:portfolioSum];*/
	// 4 - Set up display label
    NSString *labelValue;
    if (index == 0) labelValue = [NSString stringWithFormat:@"Totes from Landfill"];
    else labelValue = [NSString stringWithFormat:@"Totes from HP"];
	// 5 - Create and return layer with label text
	return [[CPTTextLayer alloc] initWithText:labelValue style:labelText];
}

-(NSString *)legendTitleForPieChart:(CPTPieChart *)pieChart recordIndex:(NSUInteger)index {
    /*	if (index < [[[CPDStockPriceStore sharedInstance] tickerSymbols] count]) {
     return [[[CPDStockPriceStore sharedInstance] tickerSymbols] objectAtIndex:index];
     }*/
	return @"N/A";
}

@end
