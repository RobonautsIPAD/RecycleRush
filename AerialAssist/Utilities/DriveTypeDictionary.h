//
//  DriveTypeDictionary.h
// Robonauts Scouting
//
//  Created by FRC on 10/10/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface DriveTypeDictionary : NSObject
-(NSString *)getString:(id) key;
-(id)getEnumValue:(NSString *) value;
-(NSArray *)getDriveTypes;
@end
