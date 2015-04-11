//
//  PlotDefinition.m
//  RecycleRush
//
//  Created by FRC on 4/9/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "PlotDefinition.h"

@implementation PlotDefinition
-(id)init:(NSString *)title {
	if ((self = [super init]))
	{
        _plotTitle = title;
	}
	return self;
}

@end
