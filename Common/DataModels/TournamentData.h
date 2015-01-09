//
//  TournamentData.h
//  RecycleRush
//
//  Created by FRC on 7/1/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>


@interface TournamentData : NSManagedObject

@property (nonatomic, retain) NSString * code;
@property (nonatomic, retain) NSString * name;

@end
