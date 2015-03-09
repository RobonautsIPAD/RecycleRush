//
//  RidleyPageViewController.m
//  RecycleRush
//
//  Created by FRC_Mtsprite on 1/13/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "RidleyPageViewController.h"
#import "DataManager.h"
#import "PopUpPickerViewController.h"
#import "TeamData.h"
//#import "TeamDataInterfaces.h"
#import "TournamentData.h"
@interface RidleyPageViewController ()

@end

@implementation RidleyPageViewController{
    id popUp;
    NSString *tournamentName;
    NSUserDefaults *prefs;
}

@synthesize dataManager = _dataManager;
@synthesize firstPicker =_firstPicker;
@synthesize firstPickerPopover = _firstPickerPopover;
@synthesize secondPicker = _secondPicker;
@synthesize thirdPicker = _thirdPicker;
@synthesize thirdPickerPopover = _thirdPickerPopover;
@synthesize secondPickerPopover = _secondPickerPopover;
@synthesize teamList = _teamList;
@synthesize team = _team;
@synthesize first = _first;
@synthesize second = _second;
@synthesize third =_third;
@synthesize firstTeamList = _firstTeamList;
@synthesize secondTeamList = _secondTeamList;
@synthesize thirdTeamList = _thirdTeamList;
@synthesize firstListTable = _firstListTable;
@synthesize secondListTable = _secondListTable;
@synthesize thirdListTable = _thirdListTable;

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
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title = tournamentName;
    }
    else {
        self.title = @"Match Scouting";
    }

    
	// Do any additional setup after loading the view.
    NSArray *teamData = nil;//[[[[TeamDataInterfaces alloc] initWithDataManager:_dataManager] getTeamListTournament:tournamentName] mutableCopy];
   
    _firstTeamList = [[NSMutableArray alloc] init];
    _secondTeamList = [[NSMutableArray alloc] init];
    _thirdTeamList = [[NSMutableArray alloc] init];
    
    
    
    _teamList = [[NSMutableArray alloc] init];
    
    for(int i=0; i<[teamData count]; i++){
        TeamData *team = [teamData objectAtIndex:i];
        //NSLog(@"%@", team.number);
        [_teamList addObject:[NSString stringWithFormat:@"%d", [team.number intValue]]];
        
        
    }
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



-(IBAction)showTeamPopUp:(id)sender {
    UIButton *PressedButton = (UIButton*)sender;
    if (PressedButton == _first) {
       // NSLog(@"First");
        popUp = _first;
        if (_firstPicker == nil) {
          //  NSLog(@"%@", _addFirstPicker);
            _firstPicker = [[PopUpPickerViewController alloc]
                             initWithStyle:UITableViewStylePlain];
            _firstPicker.delegate = self;
        }
        _firstPicker.pickerChoices = _teamList;
        _firstPickerPopover = [[UIPopoverController alloc]initWithContentViewController:_firstPicker];
        [self.firstPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _second) {
        popUp = _second;
        if (_secondPicker == nil) {
            _secondPicker = [[PopUpPickerViewController alloc]initWithStyle:UITableViewStylePlain];
            _secondPicker.delegate = self;
        }
        _secondPicker.pickerChoices = [NSMutableArray arrayWithArray:_teamList];
        _secondPickerPopover = [[UIPopoverController alloc]initWithContentViewController:_secondPicker];
        [_secondPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                            permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
    else if (PressedButton == _third) {
        popUp = _third;
        if (_thirdPicker == nil) {
            _thirdPicker = [[PopUpPickerViewController alloc]
                                initWithStyle:UITableViewStylePlain];
            _thirdPicker.delegate = self;
        }
        _thirdPicker.pickerChoices = [NSMutableArray arrayWithArray:_teamList];
        _thirdPickerPopover = [[UIPopoverController alloc]
                                       initWithContentViewController:_thirdPicker];
        [_thirdPickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                                   permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)addFirstList:(NSString *)newFirstTeam {
    // The user has changed the intake type
    for (int i = 0 ; i < [_teamList count] ; i++) {
        if ([newFirstTeam isEqualToString:[_teamList objectAtIndex:i]]) {
            [_firstTeamList addObject:newFirstTeam];
            
            
            
           // NSLog(@"%@", _firstTeamList);
            break;
        }
    }
    [_firstListTable reloadData];
}

-(void)addSecondList:(NSString *)newSecondTeam {
    // The user has changed the drive train type
    for (int i = 0 ; i < [_teamList count] ; i++) {
        if ([newSecondTeam isEqualToString:[_teamList objectAtIndex:i]]) {
            [_secondTeamList addObject:newSecondTeam];
          //  NSLog(@"%@", _secondTeamList);
            
            break;
        }
    }
    [_secondListTable reloadData];
}

-(void)addThirdList:(NSString *)newThirdTeam {
    // The user has changed the climb zone
    for (int i = 0 ; i < [_teamList count] ; i++) {
        if ([newThirdTeam isEqualToString:[_teamList objectAtIndex:i]]) {
            [_thirdTeamList addObject:newThirdTeam];
           // NSLog(@"%@", _thirdTeamList);
            
            break;
        }
    }
    [_thirdListTable reloadData];
}


- (void)pickerSelected:(NSString *)newPick {
    // The user has made a selection on one of the pop-ups. Dismiss the pop-up
    //  and call the correct method to change the right field.
    if (popUp == _first) {
        [_firstPickerPopover dismissPopoverAnimated:YES];
        _firstPickerPopover = nil;
         [self addFirstList:newPick];
    }
    else if (popUp == _second) {
        [_secondPickerPopover dismissPopoverAnimated:YES];
        _secondPickerPopover = nil;
        [self addSecondList:newPick];
    }
    else if (popUp == _third) {
        [_thirdPickerPopover dismissPopoverAnimated:YES];
        _thirdPickerPopover = nil;
         [self addThirdList:newPick];
    }
}

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    // Return the number of sections.
    return 1;
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == _firstListTable){
        return [_firstTeamList count];
    }
    else if (tableView == _secondListTable){
        return [_secondTeamList count];
    }
    else{
        return [_thirdTeamList count];
    }
}

- (void)configureFirstPickCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSNumber *info1 = [_firstTeamList objectAtIndex:indexPath.row];
    NSLog(@"name = %@", info1);
	UILabel *pickLabel1 = (UILabel *)[cell viewWithTag:10];
	pickLabel1.text = [NSString stringWithFormat:@"%d", [info1 intValue]];

}

- (void)configureSecondPickCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSNumber *info2 = [_secondTeamList objectAtIndex:indexPath.row];
    NSLog(@"name = %@", info2);
	UILabel *pickLabel2 = (UILabel *)[cell viewWithTag:20];
	pickLabel2.text = [NSString stringWithFormat:@"%d", [info2 intValue]];
    
}

- (void)configureThirdPickCell:(UITableViewCell *)cell atIndexPath:(NSIndexPath *)indexPath {
    NSNumber *info3 = [_thirdTeamList objectAtIndex:indexPath.row];
    NSLog(@"name = %@", info3);
	UILabel *pickLabel3 = (UILabel *)[cell viewWithTag:30];
	pickLabel3.text = [NSString stringWithFormat:@"%d", [info3 intValue]];
    
}
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if(tableView == _firstListTable){
        if(editingStyle == UITableViewCellEditingStyleDelete)
        {
            [_firstTeamList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }
    }
    else if(tableView == _secondListTable){
        if(editingStyle == UITableViewCellEditingStyleDelete)
        {
            [_secondTeamList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }

    }
    else{
        if(editingStyle == UITableViewCellEditingStyleDelete)
        {
            [_thirdTeamList removeObjectAtIndex:indexPath.row];
            [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationNone];
        }

    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = nil;
    if (tableView == _firstListTable) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"FirstPick"];
        // Set up the cell...
        NSLog(@"Filling Cell");
        NSLog(@"Creating button");
        [self configureFirstPickCell:cell atIndexPath:indexPath];
        
    }
    else if (tableView == _secondListTable) {
        cell = [tableView dequeueReusableCellWithIdentifier:@"SecondPick"];
        // Set up the cell...
        [self configureSecondPickCell:cell atIndexPath:indexPath];
    }
    else if (tableView == _thirdListTable){
        cell = [tableView dequeueReusableCellWithIdentifier:@"ThirdPick"];
        //Set up the cell...
        [self configureThirdPickCell:cell atIndexPath:indexPath];
    }
    
    return cell;
}




@end
