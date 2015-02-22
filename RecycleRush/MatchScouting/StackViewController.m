//
//  StackViewController.m
//  RecycleRush
//
//  Created by FRC on 2/19/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "StackViewController.h"
#import "StackPad.h"
#import "LNNumberpad.h"

@interface StackViewController ()
@property (weak, nonatomic) IBOutlet UIButton *finishedButton;
@property (weak, nonatomic) IBOutlet UIImageView *fieldView;
@property (weak, nonatomic) IBOutlet UIButton *stackButton;

@end

@implementation StackViewController {
    PopUpPickerViewController *stackLocationPicker;
    UIPopoverController *stackLocationPickerPopover;
    NSArray *stackLocationList;
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
    }
    else {
        [_fieldView setImage:[UIImage imageNamed:@"Blue 2015 New.png"]];
    }
    stackLocationList = [[NSArray alloc] initWithObjects:@"Location", @"Location", @"Location", nil];
}

- (IBAction)popUpNewStack:(id)sender {
    UIButton *button = (UIButton *)sender;
    if (stackLocationPicker == nil) {
        stackLocationPicker = [[PopUpPickerViewController alloc]
                            initWithStyle:UITableViewStylePlain];
        stackLocationPicker.delegate = self;
        stackLocationPicker.pickerChoices = stackLocationList;
        stackLocationPickerPopover = [[UIPopoverController alloc]
                                      initWithContentViewController:stackLocationPicker];
    }
  //  popUp = sender;
    [stackLocationPickerPopover presentPopoverFromRect:button.bounds inView:button
                            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

- (void)pickerSelected:(NSString *)newPick {
    [stackLocationPickerPopover dismissPopoverAnimated:YES];
    [self newStack];
}

-(void)newStack {
    UIView *stack =[[UIView alloc] initWithFrame:CGRectMake(0,0,300,100)];
    stack.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:stack];
    UITextField *textField;
    CGFloat height = 20;
    CGFloat width = 45;
    CGPoint basePoint;
    basePoint.x = 10;
    basePoint.y = 10;
    CGFloat heightSpace = 25;
    CGFloat widthSpace = 65;
    for (int i=0; i<8; i++) {
        CGPoint location;
        location.x = basePoint.x + (i/2)*widthSpace;
        location.y = basePoint.y + (i%2)*heightSpace;
        textField = [[UITextField alloc] initWithFrame:CGRectMake(location.x, location.y, width, height)];
        textField.text = [NSString stringWithFormat:@"%d", i];
        [self something:textField withTag:i*10 onBottom:i%2];
        [stack addSubview:textField];
    }

}

-(void)something:(UITextField *)field withTag:(NSUInteger)newTag onBottom:(BOOL)bottom {
    field.borderStyle = UITextBorderStyleRoundedRect;
    field.font = [UIFont systemFontOfSize:15];
   // field.placeholder = @"";
    field.autocorrectionType = UITextAutocorrectionTypeNo;
    field.keyboardType = UIKeyboardTypeDefault;
    field.returnKeyType = UIReturnKeyDone;
    field.clearButtonMode = UITextFieldViewModeNever;
    field.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    field.delegate = self;
    if (bottom) field.inputView  = [LNNumberpad defaultLNNumberpad];
    else field.inputView  = [StackPad defaultStackPad];
    field.tag = newTag;
}

-(BOOL)textFieldShouldReturn:(UITextField*)textField
{
    NSInteger nextTag = textField.tag + 10;
    // Try to find next responder
    UIResponder* nextResponder = [textField.superview viewWithTag:nextTag];
    if (nextResponder) {
        // Found next responder, so set it.
        [nextResponder becomeFirstResponder];
    } else {
        // Not found, so remove keyboard.
        [textField resignFirstResponder];
    }
    return NO; // We do not want UITextField to insert line-breaks.
}

- (IBAction)finished:(id)sender {
    [self dismissViewControllerAnimated:YES completion:Nil];
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
