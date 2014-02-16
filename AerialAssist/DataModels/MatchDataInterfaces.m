//
//  MatchDataInterfaces.m
//  AerialAssist
//
//  Created by FRC on 2/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchDataInterfaces.h"
#import "MatchData.h"

@implementation MatchDataInterfaces
@synthesize dataManager = _dataManager;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(NSString *) exportMatchListToCSV:(BOOL)header forMatch:(MatchData *)match forTournament:(NSString *)tournament {
    
}


@end
