//
//  SketchSpaceViewController.m
//  RecycleRush
//
//  Created by FRC on 2/20/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "SketchSpaceViewController.h"

@interface SketchSpaceViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *fieldView;

@end

@implementation SketchSpaceViewController

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
    if ([[_allianceString substringToIndex:1] isEqualToString:@"R"]) {
        [_fieldView setImage:[UIImage imageNamed:@"Red 2015 New.png"]];
    }
    else {
        [_fieldView setImage:[UIImage imageNamed:@"Blue 2015 New.png"]];
    }
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
