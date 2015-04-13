//
//  SketchSpaceViewController.m
//  RecycleRush
//
//  Created by FRC on 2/20/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "SketchSpaceViewController.h"
#import "MatchAccessors.h"

@interface SketchSpaceViewController ()
@property (weak, nonatomic) IBOutlet UIView *containerView;
@property (weak, nonatomic) IBOutlet UIImageView *fieldView;
@property (weak, nonatomic) IBOutlet UIImageView *traceView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *homeButton;
@property (weak, nonatomic) IBOutlet UILabel *team1Label;
@property (weak, nonatomic) IBOutlet UIButton *team1Button;
@property (weak, nonatomic) IBOutlet UILabel *team2Label;
@property (weak, nonatomic) IBOutlet UIButton *team2Button;
@property (weak, nonatomic) IBOutlet UILabel *team3Label;
@property (weak, nonatomic) IBOutlet UIButton *team3Button;
@property (weak, nonatomic) IBOutlet UIButton *drawModeButton;
@property (weak, nonatomic) IBOutlet UIButton *eraseButton;
@property (weak, nonatomic) IBOutlet UIButton *saveButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *resetSketch;

@end

@implementation SketchSpaceViewController {
    BOOL drawMode;
    BOOL drawingChanged;
    UIPanGestureRecognizer *drawGesture;
    CGPoint currentPoint;
    CGPoint lastPoint;
    CGFloat red;
    CGFloat green;
    CGFloat blue;
    CGFloat red1;
    CGFloat green1;
    CGFloat blue1;
    CGFloat red2;
    CGFloat green2;
    CGFloat blue2;
    CGFloat red3;
    CGFloat green3;
    CGFloat blue3;
    CGFloat brush;
    CGFloat opacity;
    BOOL eraseMode;
    id popUp;
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
    [_saveButton setHidden:TRUE];
    if ([[_allianceString substringToIndex:1] isEqualToString:@"R"]) {
        [_fieldView setImage:[UIImage imageNamed:@"Red 2015 New.png"]];
        red1 = 255.0/255.0;
        green1 = 0.0/255.0;
        blue1 = 0.0/255.0;
        red2 = 205.0/255.0;
        green2 = 92.0/255.0;
        blue2 = 92.0/255.0;
        red3 = 250.0/255.0;
        green3 = 128.0/255.0;
        blue3 = 114.0/255.0;
    }
    else {
        [_fieldView setImage:[UIImage imageNamed:@"Blue 2015 New.png"]];
        red1 = 0.0/255.0;
        green1 = 0.0/255.0;
        blue1 = 255.0/255.0;
        red2 = 30.0/255.0;
        green2 = 144.0/255.0;
        blue2 = 255.0/255.0;
        red3 = 176.0/255.0;
        green3 = 224.0/255.0;
        blue3 = 230.0/255.0;
    }
    brush = 3.0;
    opacity = 1.0;
    drawGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(drawPath:)];
    [_traceView addGestureRecognizer:drawGesture];
    _team1Label.text = _alliance1;
    _team2Label.text = _alliance2;
    _team3Label.text = _alliance3;
    drawingChanged = FALSE;
    drawMode = FALSE;
    eraseMode = FALSE;
    [_containerView sendSubviewToBack:_fieldView];
}

- (IBAction)drawModeChanged:(id)sender {
    if (drawMode) {
        drawMode = FALSE;
        [_drawModeButton setTitle:@"Off" forState:UIControlStateNormal];
        [_traceView setUserInteractionEnabled:FALSE];
    }
    else {
        drawMode = TRUE;
        [_drawModeButton setTitle:@"On" forState:UIControlStateNormal];
        [_traceView setUserInteractionEnabled:TRUE];
    }
}

- (IBAction)eraseTapped:(id)sender {
    if (eraseMode) {
        [_eraseButton setBackgroundImage:nil forState:UIControlStateNormal];
        eraseMode = FALSE;
    }
    else {
        [_eraseButton setBackgroundImage:[UIImage imageNamed:@"Small Red Button.jpg"] forState:UIControlStateNormal];
        eraseMode = TRUE;
    }
}

- (IBAction)sketchReset:(id)sender {
    NSString *title = @"Empire Says: Are you sure you want to rest?";
    NSString *button = @"Yes, Reset";
    popUp = sender;
    
    [self confirmationActionSheet:title withButton:button];
}

-(void)matchReset {
    drawMode = FALSE;
}
                                                                                             
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    switch (buttonIndex) {
        case 0:
            if (popUp == _resetSketch) [self matchReset];
           }
}

-(void)confirmationActionSheet:title withButton:(NSString *)button {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:title delegate:self cancelButtonTitle:nil destructiveButtonTitle:button otherButtonTitles:@"Nevermind",  nil];
    
    actionSheet.actionSheetStyle = UIActionSheetStyleDefault;
    [actionSheet showInView:self.view];
}

- (IBAction)saveTapped:(id)sender {
}

- (IBAction)radioButtonTapped:(id)sender {
    if (sender == _team1Button) {
        [self coupledRadioButtons:(UIButton *)_team1Button forSecond:_team2Button forThird:_team3Button];
        red = red1;
        green = green1;
        blue = blue1;
    }
    else if (sender == _team2Button) {
        [self coupledRadioButtons:(UIButton *)_team2Button forSecond:_team1Button forThird:_team3Button];
        red = red2;
        green = green2;
        blue = blue2;
    }
    else if (sender == _team3Button) {
        [self coupledRadioButtons:(UIButton *)_team3Button forSecond:_team1Button forThird:_team2Button];
        red = red3;
        green = green3;
        blue = blue3;
    }
    if (![_team1Button isSelected] && ![_team2Button isSelected] && ![_team3Button isSelected]) {
        red = 0;
        green = 0;
        blue = 0;
    }
}

-(void)coupledRadioButtons:(UIButton *)button1 forSecond:(UIButton *)button2 forThird:(UIButton *)button3 {
    if ([button1 isSelected]) {
        [button1 setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
        [button1 setSelected:NO];
    } else {
        [button1 setImage:[UIImage imageNamed:@"RadioButton-Selected.png"] forState:UIControlStateSelected];
        [button1 setSelected:YES];
        [button2 setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
        [button2 setSelected:NO];
        [button3 setImage:[UIImage imageNamed:@"RadioButton-Unselected.png"] forState:UIControlStateNormal];
        [button3 setSelected:NO];
    }
}

-(void)drawPath:(UIPanGestureRecognizer *)gestureRecognizer {
    drawingChanged = TRUE;
    UIImageView *currentView = (UIImageView *)[gestureRecognizer view];
    //  if ([gestureRecognizer view] == _fieldImage) NSLog(@"Yeah!");
    if ([gestureRecognizer state] == UIGestureRecognizerStateBegan) {
        // NSLog(@"drawPath Began");
        lastPoint = [gestureRecognizer locationInView:currentView];
    }
    else {
        currentPoint = [gestureRecognizer locationInView: currentView];
        // NSLog(@"current point = %lf, %lf", currentPoint.x, currentPoint.y);
        //        CGContextRef context = UIGraphicsGetCurrentContext();
        UIGraphicsBeginImageContext(currentView.frame.size);
        [currentView.image drawInRect:CGRectMake(0, 0, currentView.frame.size.width, currentView.frame.size.height)];
        CGContextMoveToPoint(UIGraphicsGetCurrentContext(), lastPoint.x, lastPoint.y);
        CGContextAddLineToPoint(UIGraphicsGetCurrentContext(), currentPoint.x, currentPoint.y);
        CGContextSetLineCap(UIGraphicsGetCurrentContext(), kCGLineCapRound);
        CGContextSetRGBStrokeColor(UIGraphicsGetCurrentContext(), red, green, blue, 1.0);
        if (eraseMode) {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
            brush = 10.0;
        }
        else {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(),kCGBlendModeNormal);
            brush = 5.0;
        }
        CGContextSetLineWidth(UIGraphicsGetCurrentContext(), brush );
        CGContextStrokePath(UIGraphicsGetCurrentContext());
        currentView.image = UIGraphicsGetImageFromCurrentImageContext();
        [currentView setAlpha:opacity];
        UIGraphicsEndImageContext();
        lastPoint = currentPoint;
        if (eraseMode) {
            CGContextSetBlendMode(UIGraphicsGetCurrentContext(), kCGBlendModeClear);
            brush = 15.0;
        }
    }
}


- (IBAction)goHome:(id)sender {
    UINavigationController * navigationController = self.navigationController;
    [navigationController popToRootViewControllerAnimated:YES];
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
