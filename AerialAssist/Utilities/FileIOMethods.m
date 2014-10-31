//
//  FileIOMethods.m
//  AerialAssist
//
//  Created by FRC on 9/16/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "FileIOMethods.h"

@implementation FileIOMethods
+(NSDictionary *)getDictionaryFromPListFile:(NSString *)fileName {
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    if ([fileManager fileExistsAtPath:fileName]) {
        NSDictionary *propertyList;
        NSData *plistData = [NSData dataWithContentsOfFile:fileName];
        NSError *error;
        NSPropertyListFormat plistFormat;
        propertyList = [NSPropertyListSerialization propertyListWithData:plistData options:NSPropertyListImmutable format:&plistFormat error:&error];
        return propertyList;
    }
    else {
        return Nil;
    }
}

+(void)writePListFileFromDictionary:(NSString *)fileName forDictionary:(NSDictionary *)dictionary error:(out NSError **)error NS_AVAILABLE(10_6, 4_0) {
    NSData *data = [NSPropertyListSerialization dataWithPropertyList:dictionary format:NSPropertyListXMLFormat_v1_0 options:nil error:error];
    if(data) {
        [data writeToFile:fileName atomically:YES];
    }
    else {
        NSLog(@"An error has occured %@", *error);
    }
}

+(NSArray *)initializePopUpList:(NSString *)fileName {
    NSString *plistPath = [[NSBundle mainBundle] pathForResource:fileName ofType:@"plist"];
    NSDictionary *dictionary = [FileIOMethods getDictionaryFromPListFile:plistPath];
    return [dictionary keysSortedByValueUsingSelector:@selector(compare:)];
}

/**
 Returns the path to the application's Library directory.
 */
+(NSString *)applicationLibraryDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
}

/**
 Returns the path to the application's Documents directory.
 */
+(NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
