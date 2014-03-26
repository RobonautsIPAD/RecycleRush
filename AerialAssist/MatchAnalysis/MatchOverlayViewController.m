//
//  MatchOverlayViewController.m
//  AerialAssist
//
//  Created by FRC on 3/14/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "MatchOverlayViewController.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "FieldDrawing.h"

@interface MatchOverlayViewController ()

@end

@implementation MatchOverlayViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    for (int i=0; i<[_matchList count]; i++) {
        TeamScore *score = [_matchList objectAtIndex:i];
        if ([score.results boolValue] && score.fieldDrawing.trace) {
            UIImageView *trace =[[UIImageView alloc] initWithFrame:CGRectMake(0,0,848,424)];
            trace.image = [UIImage imageWithData:score.fieldDrawing.trace];
            if ([score.allianceSection intValue] > 2) {
                trace.transform = CGAffineTransformMakeScale(-1, 1);
            }
            [self.view addSubview:trace];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
