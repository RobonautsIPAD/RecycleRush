//
//  TeamScoreInterfaces.m
//  AerialAssist
//
//  Created by FRC on 2/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "TeamScoreInterfaces.h"

@implementation TeamScoreInterfaces
@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

@end
