//
//  FileIOMethods.h
//  AerialAssist
//
//  Created by FRC on 9/16/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface FileIOMethods : NSObject
+(NSDictionary *)getDictionaryFromPListFile:(NSString *)fileName;
+(void)writePListFileFromDictionary:(NSString *)fileName forDictionary:(NSDictionary *)dictionary error:(out NSError **)error NS_AVAILABLE(10_6, 4_0);
+(NSString *)applicationLibraryDirectory;


@end
