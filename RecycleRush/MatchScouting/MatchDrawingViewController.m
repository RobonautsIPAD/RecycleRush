//
//  MatchDrawingViewController.m
//  RecycleRush
//
//  Created by FRC on 2/22/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "MatchDrawingViewController.h"
#import "DataManager.h"
#import "TeamScore.h"
#import "MatchAccessors.h"

@interface MatchDrawingViewController ()
@property (weak, nonatomic) IBOutlet UIButton *startPointButton;
@property (weak, nonatomic) IBOutlet UIButton *finishButton;
@property (weak, nonatomic) IBOutlet UIImageView *fieldMap;
@property (weak, nonatomic) IBOutlet UIImageView *autonTrace;

@end

@implementation MatchDrawingViewController {
    NSDictionary *allianceDictionary;
}

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
    NSLog(@"Match Drawing View Controller");
    allianceDictionary = _dataManager.allianceDictionary;
    NSString *allianceString = [MatchAccessors getAllianceString:_score.allianceStation fromDictionary:allianceDictionary];
    if ([[allianceString substringToIndex:1] isEqualToString:@"R"]) {
        [_fieldMap setImage:[UIImage imageNamed:@"Red 2015 New.png"]];
    }
    else {
        [_fieldMap setImage:[UIImage imageNamed:@"Blue 2015 New.png"]];
    }
}

- (IBAction)finishedDrawing:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
}

- (IBAction)startPointSelected:(id)sender {
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
