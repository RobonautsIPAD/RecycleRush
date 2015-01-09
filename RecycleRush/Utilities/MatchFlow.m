//
//  MatchFlow.m
//  RecycleRush
//
//  Created by FRC on 10/27/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchFlow.h"

@implementation MatchFlow
+(NSUInteger)getPreviousMatchType:(NSArray *)matchTypeList forCurrent:(NSString *)typeString {
    NSUInteger newSection = NSNotFound;
    if ([typeString isEqualToString:@"Practice"]) {
        // Look for Elim matches
        newSection = [matchTypeList indexOfObject:@"Elimination"];
        if (newSection == NSNotFound) {
            // No Elim matches, look for Qual
            newSection = [matchTypeList indexOfObject:@"Qualification"];
         }
    }
    if ([typeString isEqualToString:@"Qualification"]) {
        // Look for Practice matches
        newSection = [matchTypeList indexOfObject:@"Practice"];
        if (newSection == NSNotFound) {
            // No Practice matches, look for Elims
            newSection = [matchTypeList indexOfObject:@"Elimination"];
         }
    }
    if ([typeString isEqualToString:@"Elimination"]) {
        // Look for Qual matches
        newSection = [matchTypeList indexOfObject:@"Qualification"];
        if (newSection == NSNotFound) {
            // No Qual matches, look for Practice
            newSection = [matchTypeList indexOfObject:@"Practice"];

        }
    }
    if ([typeString isEqualToString:@"Testing"]) {
        // Look for Other matches
        newSection = [matchTypeList indexOfObject:@"Other"];
        if (newSection == NSNotFound) {
            // No Other matches, reset to Testing
            newSection = [matchTypeList indexOfObject:@"Testing"];
            
        }
    }
    if ([typeString isEqualToString:@"Other"]) {
        // Look for Testing matches
        newSection = [matchTypeList indexOfObject:@"Testing"];
        if (newSection == NSNotFound) {
            // No Testing matches, reset to Other
            newSection = [matchTypeList indexOfObject:@"Other"];
            
        }
    }
   return newSection;
}

+(NSUInteger)getNextMatchType:(NSArray *)matchTypeList forCurrent:(NSString *)typeString {
    NSUInteger newSection = NSNotFound;
    if ([typeString isEqualToString:@"Practice"]) {
        // Look for Qual matches
        newSection = [matchTypeList indexOfObject:@"Qualification"];
        if (newSection == NSNotFound) {
            // No Qual matches, look for Elims
            newSection = [matchTypeList indexOfObject:@"Elimination"];
        }
    }
    if ([typeString isEqualToString:@"Qualification"]) {
        // Look for Elims matches
        newSection = [matchTypeList indexOfObject:@"Elimination"];
        if (newSection == NSNotFound) {
            // No Elims matches, look for Practice
            newSection = [matchTypeList indexOfObject:@"Practice"];
        }
    }
    if ([typeString isEqualToString:@"Elimination"]) {
        // Look for Practice matches
        newSection = [matchTypeList indexOfObject:@"Practice"];
        if (newSection == NSNotFound) {
            // No Practice matches, look for Qual
            newSection = [matchTypeList indexOfObject:@"Qualification"];
            
        }
    }
    if ([typeString isEqualToString:@"Testing"]) {
        // Look for Other matches
        newSection = [matchTypeList indexOfObject:@"Other"];
        if (newSection == NSNotFound) {
            // No Other matches, reset to Testing
            newSection = [matchTypeList indexOfObject:@"Testing"];
            
        }
    }
    if ([typeString isEqualToString:@"Other"]) {
        // Look for Testing matches
        newSection = [matchTypeList indexOfObject:@"Testing"];
        if (newSection == NSNotFound) {
            // No Testing matches, reset to Other
            newSection = [matchTypeList indexOfObject:@"Other"];
            
        }
    }
    return newSection;
}

@end
