//
//  StackViewController.m
//  RecycleRush
//
//  Created by FRC on 2/19/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "StackViewController.h"
#import <QuartzCore/CALayer.h>
#import "TeamScore.h"
#import "LNNumberpad.h"

@interface StackViewController ()
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
@property (weak, nonatomic) IBOutlet UIImageView *fieldView;
@property (weak, nonatomic) IBOutlet UIView *stack1View;
@property (weak, nonatomic) IBOutlet UIView *stack2View;
@property (weak, nonatomic) IBOutlet UIView *stack3View;
@property (weak, nonatomic) IBOutlet UIView *stack4View;
@property (weak, nonatomic) IBOutlet UIView *stack5View;
@property (weak, nonatomic) IBOutlet UIView *stack6View;
@property (weak, nonatomic) IBOutlet UIView *stack7View;
@property (weak, nonatomic) IBOutlet UIView *stack8View;
@property (weak, nonatomic) IBOutlet UIView *stack9View;
@property (weak, nonatomic) IBOutlet UIView *stack10View;
@property (weak, nonatomic) IBOutlet UIView *stack11View;
@property (weak, nonatomic) IBOutlet UIView *stack12View;

@end

@implementation StackViewController {
    UIView *savedView;
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
    if ([[_allianceString substringToIndex:1] isEqualToString:@"R"]) {
        [_fieldView setImage:[UIImage imageNamed:@"Red 2015 New.png"]];
        CGFloat xLeft = 150;
        CGFloat xRight = 500;
        CGFloat yTop = 50;
        CGFloat yBottom = 230;
        CGFloat yInterval = 75;
        CGRect rect = CGRectMake(xLeft,yBottom,265,65);
        if (_savedData) {
            savedView = (UIView *) [NSKeyedUnarchiver unarchiveObjectWithData:_savedData];
            [self.view addSubview:savedView];
        }
        else {
            _stack1View.frame = rect;
            [self initializeStack:_stack1View forNumber:0];
        }
        rect = CGRectMake(xLeft,yBottom+yInterval,265,65);
        _stack2View.frame = rect;
        [self initializeStack:_stack2View forNumber:1];

        rect = CGRectMake(xLeft,yBottom+yInterval*2,265,65);
        _stack3View.frame = rect;
        [self initializeStack:_stack3View forNumber:2];

        rect = CGRectMake(xLeft,yBottom+yInterval*3,265,65);
        _stack4View.frame = rect;
        [self initializeStack:_stack4View forNumber:3];

        rect = CGRectMake(xLeft,yBottom+yInterval*4,265,65);
        _stack5View.frame = rect;
        [self initializeStack:_stack5View forNumber:4];

        rect = CGRectMake(xLeft,yBottom+yInterval*5,265,65);
        _stack6View.frame = rect;
        [self initializeStack:_stack6View forNumber:5];

        rect = CGRectMake(xRight,yTop,265,65);
        _stack7View.frame = rect;
        [self initializeStack:_stack7View forNumber:6];

        rect = CGRectMake(xRight,yTop+yInterval,265,65);
        _stack8View.frame = rect;
        [self initializeStack:_stack8View forNumber:7];

        rect = CGRectMake(xRight,yTop+yInterval*2,265,65);
        _stack9View.frame = rect;
        [self initializeStack:_stack9View forNumber:8];

        rect = CGRectMake(xRight,yTop+yInterval*3,265,65);
        _stack10View.frame = rect;
        [self initializeStack:_stack10View forNumber:9];

        rect = CGRectMake(xRight,yTop+yInterval*4,265,65);
        _stack11View.frame = rect;
        [self initializeStack:_stack11View forNumber:10];

        rect = CGRectMake(xRight,yTop+yInterval*5,265,65);
        _stack12View.frame = rect;
        [self initializeStack:_stack12View forNumber:11];
    }
    else {
        [_fieldView setImage:[UIImage imageNamed:@"Blue 2015 New.png"]];
        CGFloat xLeft = 185;
        CGFloat xRight = 500;
        CGFloat yTop = 40;
        CGFloat yBottom = 230;
        CGFloat yInterval = 75;
        CGRect rect = CGRectMake(xLeft,yTop,265,65);
        _stack1View.frame = rect;
        [self initializeStack:_stack1View forNumber:0];

        rect = CGRectMake(xLeft,yTop+yInterval,265,65);
        _stack2View.frame = rect;
        [self initializeStack:_stack2View forNumber:1];
        
        rect = CGRectMake(xLeft,yTop+yInterval*2,265,65);
        _stack3View.frame = rect;
        [self initializeStack:_stack3View forNumber:2];
        
        rect = CGRectMake(xLeft,yTop+yInterval*3,265,65);
        _stack4View.frame = rect;
        [self initializeStack:_stack4View forNumber:3];
        
        rect = CGRectMake(xLeft,yTop+yInterval*4,265,65);
        _stack5View.frame = rect;
        [self initializeStack:_stack5View forNumber:4];
        
        rect = CGRectMake(xLeft,yTop+yInterval*5,265,65);
        _stack6View.frame = rect;
        [self initializeStack:_stack6View forNumber:5];
        
        rect = CGRectMake(xRight,yBottom,265,65);
        _stack7View.frame = rect;
        [self initializeStack:_stack7View forNumber:6];
        
        rect = CGRectMake(xRight,yBottom+yInterval,265,65);
        _stack8View.frame = rect;
        [self initializeStack:_stack8View forNumber:7];
        
        rect = CGRectMake(xRight,yBottom+yInterval*2,265,65);
        _stack9View.frame = rect;
        [self initializeStack:_stack9View forNumber:8];
        
        rect = CGRectMake(xRight,yBottom+yInterval*3,265,65);
        _stack10View.frame = rect;
        [self initializeStack:_stack10View forNumber:9];
        
        rect = CGRectMake(xRight,yBottom+yInterval*4,265,65);
        _stack11View.frame = rect;
        [self initializeStack:_stack11View forNumber:10];
        
        rect = CGRectMake(xRight,yBottom+yInterval*5,265,65);
        _stack12View.frame = rect;
        [self initializeStack:_stack12View forNumber:11];
    }
}

-(void)initializeStack:(UIView *)stack forNumber:(int) stackNumber {
    stack.backgroundColor = [UIColor whiteColor];

    stack.layer.borderColor = [UIColor colorWithRed:(34.0/255) green:(139.0/255) blue:(34.0/255) alpha:1.0].CGColor;
    stack.layer.borderWidth = 3.0f;
    UITextField *textField;
    CGFloat height = 20;
    CGFloat width = 45;
    CGPoint basePoint;
    basePoint.x = 10;
    basePoint.y = 10;
    CGFloat heightSpace = 25;
    CGFloat widthSpace = 65;
    for (int i=0, tag=5; i<8; i++, tag+=5) {
        CGPoint location;
        location.x = basePoint.x + (i/2)*widthSpace;
        location.y = basePoint.y + (i%2)*heightSpace;
        textField = [[UITextField alloc] initWithFrame:CGRectMake(location.x, location.y, width, height)];
        [self something:textField withTag:(tag+stackNumber*40)];
        [stack addSubview:textField];
    }

}

-(void)something:(UITextField *)field withTag:(NSUInteger)newTag {
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.font = [UIFont systemFontOfSize:15];
   
    field.placeholder = @"";
//    field.placeholder = [NSString stringWithFormat:@"%d", newTag];
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.keyboardType = UIKeyboardTypeDefault;
    field.returnKeyType = UIReturnKeyDone;
    field.clearButtonMode = UITextFieldViewModeNever;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.delegate = self;
    field.inputView  = [LNNumberpad defaultLNNumberpad];
    field.tag = newTag;
}

-(NSDictionary *)calculateStackTotals:(UIView *)stack forNumber:(int)stackNumber {
    NSArray *fields = [stack subviews];
    int numeratorTotal = 0;
    int canTotal = 0;
    int litterTotal = 0;
    for (UITextField *current in fields) {
        if (current.tag%10) {
            for(int i =0 ;i<[current.text length]; i++) {
                char character = [current.text characterAtIndex:i];
                if (isdigit(character)) {
                    numeratorTotal += (int)(character - '0');
                }
                else if (character == 'C') canTotal++;
                else if (character == 'L') litterTotal++;
            }
        }
    }
    return NO; // We do not want UITextField to insert line-breaks.

    NSInteger previousTag = textField.tag - 5;
    // Try to find next responder
    UIResponder* previousResponder = [textField.superview viewWithTag:previousTag];
    if (previousResponder) {
        // Found next responder, so set it.
        [previousResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

-(NSString *)returnSet:(NSString *)inputString forSet:(NSCharacterSet *)correctSet {
    NSString *outputString;
    NSScanner *scanner = [NSScanner scannerWithString:inputString];
     //This goes through the input string and puts all the
    //characters that are digits into the new string
    [scanner scanCharactersFromSet:correctSet intoString:&outputString];
    return outputString;
 }

- (IBAction)finished:(id)sender {
    NSDictionary *stack1Results = [self calculateStackTotals:_stack1View forNumber:0];
    NSLog(@"%@", stack1Results);
    _currentScore.litterInCan = [stack1Results objectForKey:@"litter"];
    _currentScore.totalCansScored = [stack1Results objectForKey:@"cans"];
    _currentScore.totalTotesScored = [stack1Results objectForKey:@"totes"];
    NSData *dataFields = [NSKeyedArchiver archivedDataWithRootObject:_stack1View];

    [_delegate scoringViewFinished:dataFields];
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    NSLog(@"textFieldDidEndEditing tag = %d", textField.tag);
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

/* by row
 CGFloat height = 20;
 CGFloat width = 25;
 CGPoint basePoint;
 basePoint.x = 10;
 basePoint.y = 10;
 CGFloat interval = 25;
 for (int i=0; i<8; i++) {
 CGPoint location;
 location.x = basePoint.x + (i/2)*interval;
 location.y = basePoint.y + (i%2)*interval;
*/
@end
