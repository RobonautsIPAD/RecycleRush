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
    BOOL changedData;
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
    changedData = FALSE;
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

-(NSDictionary *)calculateStackTotals:(NSDictionary *)stackData forStack:(NSInteger)stackIndex {
    NSArray *allFields = [stackData allKeys];
    allFields = [allFields sortedArrayUsingSelector:@selector(compare:)];
    if (![[allFields objectAtIndex:0] intValue]%2) {
        NSLog(@"Stack Error");
        return nil;
    }
    for (int i=0; i<[allFields count]; i+=2) {
        NSString *numerator = [stackData objectForKey:[allFields objectAtIndex:i]];
        NSString *denominator = [stackData objectForKey:[allFields objectAtIndex:i+1]];
        NSDictionary *numeratorTotal = [self getTextFieldData:numerator];
        NSDictionary *denominatorTotal = [self getTextFieldData:denominator];
        NSLog(@"num = %@, denom = %@", numeratorTotal, denominatorTotal);
        _currentScore.totalTotesScored = [self addNumbers:_currentScore.totalTotesScored forSecondNumber:[numeratorTotal objectForKey:@"totes"]];
        _currentScore.totalCansScored = [self addNumbers:_currentScore.totalCansScored forSecondNumber:[numeratorTotal objectForKey:@"cans"]];
        _currentScore.litterInCan = [self addNumbers:_currentScore.litterInCan forSecondNumber:[numeratorTotal objectForKey:@"litter"]];
        [self calculateTotesOn:numeratorTotal withDenominator:denominatorTotal];
        [self calculateCansOn:numeratorTotal withDenominator:denominatorTotal];
    }
    // Calculate Cans
    // Calculate Can On
    // Calculate Litter
    // Calculate Total Totes
    // Calculate Totes On
    return nil;
}

-(NSDictionary *)getTextFieldData:(NSString *)field {
    NSNumber *totes = [NSNumber numberWithInt:0];
    NSNumber *cans = [NSNumber numberWithInt:0];
    NSNumber *litter = [NSNumber numberWithInt:0];
    for(int i =0 ;i<[field length]; i++) {
        char character = [field characterAtIndex:i];
        if (isdigit(character)) {
            totes = [NSNumber numberWithInt:(int)(character - '0')];
        }
        else if (character == 'C') cans = [NSNumber numberWithInt:1];
        else if (character == 'L') litter = [NSNumber numberWithInt:1];
    }
    NSDictionary *results = [NSDictionary dictionaryWithObjectsAndKeys:
                             totes, @"totes",
                             cans, @"cans",
                             litter, @"litter",
                             nil];
    return results;
}

-(NSNumber *)addNumbers:(NSNumber *)number1 forSecondNumber:(NSNumber *)number2 {
    int first = [number1 intValue];
    int second = [number2 intValue];
    NSNumber *result = [NSNumber numberWithInt:(first+second)];
    return result;
}

-(void)calculateTotesOn:(NSDictionary *)numerator withDenominator:(NSDictionary *)denominator {
    int onBottom = [[denominator objectForKey:@"totes"] intValue];
    switch (onBottom) {
        case 0:
            _currentScore.totesOn0 = [self addNumbers:_currentScore.totesOn0 forSecondNumber:[numerator objectForKey:@"totes"]];
            break;
        case 1:
            _currentScore.totesOn1 = [self addNumbers:_currentScore.totesOn1 forSecondNumber:[numerator objectForKey:@"totes"]];
            break;
        case 2:
            _currentScore.totesOn2 = [self addNumbers:_currentScore.totesOn2 forSecondNumber:[numerator objectForKey:@"totes"]];
            break;
        case 3:
            _currentScore.totesOn3 = [self addNumbers:_currentScore.totesOn3 forSecondNumber:[numerator objectForKey:@"totes"]];
            break;
        case 4:
            _currentScore.totesOn4 = [self addNumbers:_currentScore.totesOn4 forSecondNumber:[numerator objectForKey:@"totes"]];
            break;
        case 5:
            _currentScore.totesOn5 = [self addNumbers:_currentScore.totesOn5 forSecondNumber:[numerator objectForKey:@"totes"]];
            break;
        case 6:
            _currentScore.totesOn6 = [self addNumbers:_currentScore.totesOn6 forSecondNumber:[numerator objectForKey:@"totes"]];
            break;
            
        default:
            break;
    }
}

-(void)calculateCansOn:(NSDictionary *)numerator withDenominator:(NSDictionary *)denominator {
    int onBottom = [[denominator objectForKey:@"totes"] intValue];
    switch (onBottom) {
        case 0:
            _currentScore.cansOn0 = [self addNumbers:_currentScore.cansOn0 forSecondNumber:[numerator objectForKey:@"cans"]];
            break;
        case 1:
            _currentScore.cansOn1 = [self addNumbers:_currentScore.cansOn1 forSecondNumber:[numerator objectForKey:@"cans"]];
            break;
        case 2:
            _currentScore.cansOn2 = [self addNumbers:_currentScore.cansOn2 forSecondNumber:[numerator objectForKey:@"cans"]];
            break;
        case 3:
            _currentScore.cansOn3 = [self addNumbers:_currentScore.cansOn3 forSecondNumber:[numerator objectForKey:@"cans"]];
            break;
        case 4:
            _currentScore.cansOn4 = [self addNumbers:_currentScore.cansOn4 forSecondNumber:[numerator objectForKey:@"cans"]];
            break;
        case 5:
            _currentScore.cansOn5 = [self addNumbers:_currentScore.cansOn5 forSecondNumber:[numerator objectForKey:@"cans"]];
            break;
        case 6:
            _currentScore.cansOn6 = [self addNumbers:_currentScore.cansOn6 forSecondNumber:[numerator objectForKey:@"cans"]];
            break;
            
        default:
            break;
    }
}

-(NSString *)returnSet:(NSString *)inputString forSet:(NSCharacterSet *)correctSet {
    NSString *outputString;
    NSScanner *scanner = [NSScanner scannerWithString:inputString];
     //This goes through the input string and puts all the
    //characters that are digits into the new string
    [scanner scanCharactersFromSet:correctSet intoString:&outputString];
    return outputString;
 }

-(NSMutableDictionary *)saveStacks:(UIView *)currentStack forStack:(NSInteger)stackIndex {
    NSMutableDictionary *currentDictionary;
    for (UITextField *field in [currentStack subviews]) {
        if (field.text && ![field.text isEqualToString:@""]) {
            if (!currentDictionary) currentDictionary = [[NSMutableDictionary alloc]init];
            [currentDictionary setObject:field.text forKey:[NSNumber numberWithInt:field.tag]];
        }
    }
    if (currentDictionary) {
        [self calculateStackTotals:currentDictionary forStack:stackIndex];
    }
    return currentDictionary;
}

- (IBAction)finished:(id)sender {
    if (!changedData) {
        [_delegate scoringViewFinished];
        [self dismissViewControllerAnimated:YES completion:Nil];
        return;
    }
    // Set save time and savedby
    _currentScore.savedBy = _deviceName;
    _currentScore.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
    _currentScore.results = [NSNumber numberWithBool:YES];

    // Reset all totals
    _currentScore.cansOn0 = [NSNumber numberWithInt:0];
    _currentScore.cansOn1 = [NSNumber numberWithInt:0];
    _currentScore.cansOn2 = [NSNumber numberWithInt:0];
    _currentScore.cansOn3 = [NSNumber numberWithInt:0];
    _currentScore.cansOn4 = [NSNumber numberWithInt:0];
    _currentScore.cansOn5 = [NSNumber numberWithInt:0];
    _currentScore.cansOn6 = [NSNumber numberWithInt:0];
    _currentScore.litterInCan = [NSNumber numberWithInt:0];
    //    _currentScore.maxCanHeight = [NSNumber numberWithInt:0];
    //    _currentScore.maxToteHeight = [NSNumber numberWithInt:0];
//    _currentScore.stackNumber = [NSNumber numberWithInt:0];
    _currentScore.totalCansScored = [NSNumber numberWithInt:0];
//    _currentScore.totalScore = [NSNumber numberWithInt:0];
    _currentScore.totalTotesScored = [NSNumber numberWithInt:0];
    _currentScore.totesOn0 = [NSNumber numberWithInt:0];
    _currentScore.totesOn1 = [NSNumber numberWithInt:0];
    _currentScore.totesOn2 = [NSNumber numberWithInt:0];
    _currentScore.totesOn3 = [NSNumber numberWithInt:0];
    _currentScore.totesOn4 = [NSNumber numberWithInt:0];
    _currentScore.totesOn5 = [NSNumber numberWithInt:0];
    _currentScore.totesOn6 = [NSNumber numberWithInt:0];
    NSMutableDictionary *savedStack;
    
    int i = 0;
    for (UIView *stack in stackList) {
        savedStack = [self saveStacks:stack forStack:0];
        if (savedStack) [stackDictionary setObject:savedStack forKey:[NSNumber numberWithInt:i]];
        i++;
    }
    
    
  //  NSLog(@"%@", stackDictionary);
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
    [_delegate scoringViewFinished];
    [self dismissViewControllerAnimated:YES completion:Nil];
}

-(void)textFieldDidEndEditing:(UITextField *)textField {
    changedData = TRUE;
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
