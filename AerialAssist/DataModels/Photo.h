//
//  Photo.h
//  AerialAssist
//
//  Created by FRC on 2/5/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class TeamData;

@interface Photo : NSManagedObject

@property (nonatomic, retain) NSString * assetURL;
@property (nonatomic, retain) TeamData *teamPhoto;

@end
