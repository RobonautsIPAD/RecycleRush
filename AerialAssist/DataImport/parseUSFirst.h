//
//  parseUSFirst.h
//  AerialAssist
//
//  Created by Kylor Wang on 4/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface parseUSFirst : NSObject

+ (NSArray *)parseEventList:(int) year;
+ (NSArray *)parseMatchResultList:(NSString *) year eventCode:(NSString *) event matchType:(NSString *) type;

@end
