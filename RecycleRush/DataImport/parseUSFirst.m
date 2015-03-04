//
//  parseUSFirst.m
//  RecycleRush
//
//  Created by Kylor Wang on 4/2/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "parseUSFirst.h"

@implementation parseUSFirst

+ (NSArray *)parseEventList:(int) year {
    NSMutableArray *ret = [NSMutableArray arrayWithObjects: nil];
    NSError *error;
    NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:[NSString stringWithFormat:@"https://my.usfirst.org/myarea/index.lasso?event_type=FRC&year=%i", year]] encoding: NSASCIIStringEncoding error: &error];
    if (!html) {
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    NSArray *trs = [self findAll: html tagToSearch: @"tr"];
    for (int i = 2; i < [trs count]; i++) {
        NSArray *tds = [self findAll: [trs objectAtIndex: i] tagToSearch: @"td"];
        if ([[tds objectAtIndex: 0] rangeOfString: @"Regional"].location != NSNotFound) {
            NSString *link = [[self findAll: [tds objectAtIndex: 1] tagToSearch: @"a"] objectAtIndex: 0];
            NSString *name = [self stripTags: link];
            link = [link substringWithRange: [link rangeOfString:[NSString stringWithFormat: @"href=\".+\""] options: NSCaseInsensitiveSearch + NSRegularExpressionSearch]];
            link = [NSString stringWithFormat: @"https://my.usfirst.org/myarea/index.lasso%@", [link substringWithRange: NSMakeRange(6, link.length - 7)]];
            html = [NSString stringWithContentsOfURL:[NSURL URLWithString: [link stringByReplacingOccurrencesOfString:@"&amp;" withString:@"&"]] encoding: NSASCIIStringEncoding error: &error];
            if (!html) {
                NSLog(@"%@", [error localizedDescription]);
                return nil;
            }
            NSString *code = [html substringWithRange:[html rangeOfString: [NSString stringWithFormat: @"http\\://www2\\.usfirst\\.org/%icomp/events/\\w+/", year] options: NSCaseInsensitiveSearch + NSRegularExpressionSearch]];
            code = [code substringWithRange: NSMakeRange(40, code.length - 41)];
            [ret addObject:[NSString stringWithFormat:@"%@:%@", code, name]];
        }
    }
    return [NSArray arrayWithArray: ret];
}

+ (NSArray *)parseMatchResultList:(NSString *) year eventCode:(NSString *) event matchType:(NSString *) type {
    return [self parsePageTable:[NSString stringWithFormat:@"http://frc-events.usfirst.org/%@/%@/%@", year, event, type] tableIndex: 2 initialRow: 2];
}

+ (NSArray *)parsePageTable:(NSString *) url tableIndex:(int)table initialRow:(int)begin {
    NSMutableArray *ret = [NSMutableArray arrayWithObjects: nil];
    NSError *error;
    NSString *html = [NSString stringWithContentsOfURL:[NSURL URLWithString:url] encoding: NSASCIIStringEncoding error: &error];
    if (!html) {
        NSLog(@"%@", [error localizedDescription]);
        return nil;
    }
    NSArray *trs = [self findAll:[[self findAll: html tagToSearch: @"table"] objectAtIndex: table] tagToSearch: @"tr"];
    for (int i = begin; i < [trs count]; i++) {
        NSArray *tds = [self findAll:[trs objectAtIndex: i] tagToSearch: @"td"];
        if ([tds count] > 7) {
            NSMutableArray *row = [NSMutableArray arrayWithObjects: nil];
            for (NSString *col in tds) {
                [row addObject:[self stripTags: col]];
            }
            [ret addObject:[NSArray arrayWithArray: row]];
        }
    }
    return [NSArray arrayWithArray: ret];
}

+ (NSArray *)findAll:(NSString *)html tagToSearch:(NSString *)tag {
    NSMutableArray *ret = [NSMutableArray arrayWithObjects: nil];
    NSRange r;
    while ((r = [html rangeOfString:[NSString stringWithFormat: @"<%@[^>]*?(/>|>[\\s\\S]*?</%@>)", tag, tag] options: NSCaseInsensitiveSearch + NSRegularExpressionSearch]).location != NSNotFound) {
        [ret addObject:[html substringWithRange: r]];
        html = [html stringByReplacingCharactersInRange: r withString: @""];
    }
    return [NSArray arrayWithArray: ret];
}

+ (NSString *)stripTags:(NSString *)html {
    NSRange r;
    while ((r = [html rangeOfString: @"<[^>]+>" options: NSRegularExpressionSearch]).location != NSNotFound) {
        html = [html stringByReplacingCharactersInRange: r withString: @""];
    }
    return html;
}

@end