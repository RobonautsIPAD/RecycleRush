//
//  StackViewController.m
//  RecycleRush
//
//  Created by FRC on 2/19/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "StackViewController.h"
#import <QuartzCore/CALayer.h>
#import "DataManager.h"
#import "TeamScore.h"
#import "FieldPhoto.h"
#import "LNNumberpad.h"

@interface StackViewController ()
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
@property (weak, nonatomic) IBOutlet UIImageView *fieldView;
@end

@implementation StackViewController {
    UIView *savedView;
    NSMutableArray *stackList;
    NSMutableDictionary *stackDictionary;
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
    NSLog(@"Add saved and savedBy stuff for stack view");
    stackList = [[NSMutableArray alloc] init];
    if (_currentScore.stacks) {
        stackDictionary = [NSKeyedUnarchiver unarchiveObjectWithData:_currentScore.stacks];
    }
    else {
        stackDictionary = [[NSMutableDictionary alloc] init];
    }
    
    UIView *newStack;
    if ([[_allianceString substringToIndex:1] isEqualToString:@"R"]) {
        [_fieldView setImage:[UIImage imageNamed:@"Red 2015 New.png"]];
        CGFloat xLeft = 150;
        CGFloat xRight = 500;
        CGFloat yTop = 30;
        CGFloat yBottom = 210;
        CGFloat yInterval = 75;
        CGRect rect;
        //       [self initializeStack:newStack forNumber:0];
 //       [stackList addObject:newStack];
/*        if (_savedData) {
            savedView = (UIView *) [NSKeyedUnarchiver unarchiveObjectWithData:_savedData];
            [self.view addSubview:savedView];
        }
        else {
            _stack1View.frame = rect;
            [self initializeStack:_stack1View forNumber:0];
        }*/
        // Left Column
        for (int i=0; i<6; i++) {
            rect = CGRectMake(xLeft,yBottom+yInterval*i,265,65);
            newStack = [[UIView alloc] initWithFrame:rect];
            newStack.frame = rect;
            [self initializeStack:newStack forNumber:i];
            [stackList addObject:newStack];
        }
        // Right Column
        for (int i=6; i<12; i++) {
            rect = CGRectMake(xRight,yTop+yInterval*(i-6),265,65);
            newStack = [[UIView alloc] initWithFrame:rect];
            newStack.frame = rect;
            [self initializeStack:newStack forNumber:i];
            [stackList addObject:newStack];
        }
    }
    else {
        [_fieldView setImage:[UIImage imageNamed:@"Blue 2015 New.png"]];
        CGFloat xLeft = 155;
        CGFloat xRight = 445;
        CGFloat yTop = 210;
        CGFloat yBottom = 30;
        CGFloat yInterval = 75;
        CGRect rect;
        // Left Column
        for (int i=0; i<6; i++) {
            rect = CGRectMake(xLeft,yTop+yInterval*i,265,65);
            newStack = [[UIView alloc] initWithFrame:rect];
            newStack.frame = rect;
            [self initializeStack:newStack forNumber:i];
            [stackList addObject:newStack];
        }
        // Right Column
        for (int i=6; i<12; i++) {
            rect = CGRectMake(xRight,yBottom+yInterval*(i-6),265,65);
            newStack = [[UIView alloc] initWithFrame:rect];
            newStack.frame = rect;
            [self initializeStack:newStack forNumber:i];
            [stackList addObject:newStack];
        }
    }
}

-(void)initializeStack:(UIView *)stack forNumber:(int) stackNumber {
    NSDictionary *savedStack = [stackDictionary objectForKey:[NSNumber numberWithInt:stackNumber]];
    stack.backgroundColor = [UIColor whiteColor];
    stack.layer.borderColor = [UIColor colorWithRed:(34.0/255) green:(139.0/255) blue:(34.0/255) alpha:1.0].CGColor;
    stack.layer.borderWidth = 3.0f;
    stack.tag = stackNumber;
    UITextField *textField;
    CGFloat height = 20;
    CGFloat width = 45;
    CGPoint basePoint;
    basePoint.x = 10;
    basePoint.y = 10;
    CGFloat heightSpace = 25;
    CGFloat widthSpace = 65;
    for (int i=0, subTag=5; i<8; i++, subTag+=5) {
        CGPoint location;
        location.x = basePoint.x + (i/2)*widthSpace;
        location.y = basePoint.y + (i%2)*heightSpace;
        textField = [[UITextField alloc] initWithFrame:CGRectMake(location.x, location.y, width, height)];
        NSUInteger tag = subTag+stackNumber*40;
        NSString *savedValue = [savedStack objectForKey:[NSNumber numberWithUnsignedInt:tag]];
        NSLog(@"%u %@", tag, savedValue);
        [self textAttributes:textField withTag:tag withSavedData:savedValue];
        [stack addSubview:textField];
    }
    [self.view addSubview:stack];
}

-(void)textAttributes:(UITextField *)field withTag:(NSUInteger)newTag withSavedData:(NSString *)savedValue {
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.font = [UIFont systemFontOfSize:15];
   
    field.placeholder = @"";
    if (savedValue) field.text = savedValue;
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
    NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:
                             [NSNumber numberWithInt:numeratorTotal], @"totes",
                             [NSNumber numberWithInt:canTotal], @"cans",
                             [NSNumber numberWithInt:litterTotal], @"litter",
                             nil];
    return results;
}

-(NSString *)returnSet:(NSString *)inputString forSet:(NSCharacterSet *)correctSet {
    NSString *outputString;
    NSScanner *scanner = [NSScanner scannerWithString:inputString];
     //This goes through the input string and puts all the
    //characters that are digits into the new string
    [scanner scanCharactersFromSet:correctSet intoString:&outputString];
    return outputString;
 }

-(NSMutableDictionary *)saveStacks:(UIView *)currentStack {
    NSMutableDictionary *currentDictionary = [[NSMutableDictionary alloc]init];
    for (UITextField *field in [currentStack subviews]) {
        if (field.text) {
            [currentDictionary setObject:field.text forKey:[NSNumber numberWithInt:field.tag]];
        }
    }
    return currentDictionary;
}

- (IBAction)finished:(id)sender {
    NSMutableDictionary *stack = [self saveStacks:[stackList objectAtIndex:0]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:0]];
    stack = [self saveStacks:[stackList objectAtIndex:1]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:1]];

    stack = [self saveStacks:[stackList objectAtIndex:1]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:1]];

    stack = [self saveStacks:[stackList objectAtIndex:2]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:2]];

    stack = [self saveStacks:[stackList objectAtIndex:3]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:3]];

    stack = [self saveStacks:[stackList objectAtIndex:4]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:4]];

    stack = [self saveStacks:[stackList objectAtIndex:5]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:5]];

    stack = [self saveStacks:[stackList objectAtIndex:6]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:6]];

    stack = [self saveStacks:[stackList objectAtIndex:7]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:7]];

    stack = [self saveStacks:[stackList objectAtIndex:8]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:8]];

    stack = [self saveStacks:[stackList objectAtIndex:9]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:9]];

    stack = [self saveStacks:[stackList objectAtIndex:9]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:9]];

    stack = [self saveStacks:[stackList objectAtIndex:10]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:10]];

    stack = [self saveStacks:[stackList objectAtIndex:11]];
    [stackDictionary setObject:stack forKey:[NSNumber numberWithInt:11]];
    
    NSLog(@"%@", stackDictionary);
    NSData *data = [NSKeyedArchiver archivedDataWithRootObject:stackDictionary];
    _currentScore.stacks = data;
    if (![_dataManager saveContext]) {
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Horrible Problem"
                                                          message:@"Unable to save data"
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
    }
/*    NSDictionary *stack1Results = [self calculateStackTotals:_stack1View forNumber:0];
    NSLog(@"%@", stack1Results);
    _currentScore.litterInCan = [stack1Results objectForKey:@"litter"];
    _currentScore.totalCansScored = [stack1Results objectForKey:@"cans"];
    _currentScore.totalTotesScored = [stack1Results objectForKey:@"totes"];
    NSData *dataFields = [NSKeyedArchiver archivedDataWithRootObject:_stack1View];*/

    [_delegate scoringViewFinished];
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
