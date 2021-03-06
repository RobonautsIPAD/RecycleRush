//
//  RossPageViewController.m
// Robonauts Scouting
//
//  Created by FRC on 2/15/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "RossPageViewController.h"
#import "TournamentData.h"
#import "MatchData.h"
#import "TeamScore.h"
#import "TeamData.h"
#import "DataManager.h"
#import "FieldDrawingViewController.h"

@interface RossPageViewController ()

@end

@implementation RossPageViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
  //  MatchTypeDictionary *matchDictionary;
    int numberMatchTypes;
    NSMutableArray *r1Matches;
    NSMutableArray *r1MatchTypes;
    NSMutableArray *r1MatchAuton;
    NSMutableArray *r1MatchTeleOp;
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
    NSLog(@"Match Analysis viewDidLoad");
    NSError *error = nil;
    if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    if (tournamentName) {
        self.title =  [NSString stringWithFormat:@"%@ Match Analysis", tournamentName];
    }
    else {
        self.title = @"Match Analysis";
    }
    if (![[self fetchedResultsController] performFetch:&error]) {
        /*
         Replace this implementation with code to handle the error appropriately.
         abort() causes the application to generate a crash log and terminate.
         You should not use this function in a shipping application,
         although it may be useful during development. If it is not possible to recover from the error, display an alert panel that instructs the user to quit the application by pressing the Home button.
         */
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
 //   matchDictionary = [[MatchTypeDictionary alloc] init];
/*
    matchTypeList = [self getMatchTypeList];
    numberMatchTypes = [matchTypeList count];
    // NSLog(@"Match Type List Count = %@", matchTypeList);

    // If there are no matches in any section then don't set this stuff. ShowMatch will set currentMatch to
    // nil, printing out blank info in all the display items.
    if (numberMatchTypes) {
        // Loading Default Data Markers
        currentSectionType = 0; //[[matchDictionary getMatchTypeEnum:[matchTypeList objectAtIndex:0]] intValue];
        rowIndex = 0;
        teamIndex = 0;
        sectionIndex = [self getMatchSectionInfo:currentSectionType];
    }
    [self SetTextBoxDefaults:matchNumber];
    [self SetBigButtonDefaults:matchType];
    
    [self ShowMatch];
    
    // Temp stuff to show db access
    NSArray *red1Matches = [self GetTeamMatches:0];
    r1Matches = [[NSMutableArray alloc] init];
    r1MatchTypes = [[NSMutableArray alloc] init];
    r1MatchAuton = [[NSMutableArray alloc] init];
    r1MatchTeleOp = [[NSMutableArray alloc] init];
    for (int i=0; i<[red1Matches count]; i++) {
        TeamScore *matchScore = [red1Matches objectAtIndex:i];
        NSLog(@"Tournament = %@, Team = %@, Match = %@, Type = %@", matchScore.tournamentName, matchScore.team.number, matchScore.match.number, matchScore.match.matchType);
        [r1Matches addObject:matchScore.match.number];
        [r1MatchTypes addObject:matchScore.match.matchType];
        [r1MatchAuton addObject:matchScore.autonShotsMade];
        [r1MatchTeleOp addObject:matchScore.teleOpShotsMade];
    }
    NSLog(@"r1matches = %@", r1Matches);
    NSLog(@"r1matchestype = %@", r1MatchTypes);
    NSLog(@"r1MatchAuton = %@", r1MatchAuton);
    NSLog(@"r1MatchTeleOp = %@", r1MatchTeleOp);*/
}

#ifdef NOTUSED
-(NSMutableArray *)getMatchTypeList {
    NSMutableArray *matchTypes = [NSMutableArray array];
    NSString *sectionName;
    for (int i=0; i < [[fetchedResultsController sections] count]; i++) {
        sectionName = [[[fetchedResultsController sections] objectAtIndex:i] name];
        // NSLog(@"Section = %@", sectionName);
      //  [matchTypes addObject:[matchDictionary getMatchTypeString:[NSNumber numberWithInt:[sectionName intValue]]]];
    }
    return matchTypes;

}

-(NSUInteger)getMatchSectionInfo:(MatchType)matchSection {
/*    NSString *sectionName;
    sectionIndex = -1;
    // Loop for number of sections in table
    for (int i=0; i < [[fetchedResultsController sections] count]; i++) {
        sectionName = [[[fetchedResultsController sections] objectAtIndex:i] name];
        if ([sectionName intValue] == matchSection) {
            sectionIndex = i;
            break;
        }
    }*/
    return 0; //sectionIndex;
}

-(int)getNumberOfMatches:(NSUInteger)section {
    if ([[fetchedResultsController sections] count]) {
        return [[[[fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count];
    }
    else return 0;
}

-(IBAction)PrevButton {
    if (rowIndex > 0) rowIndex--;
    else {
        sectionIndex = [self GetPreviousSection:currentSectionType];
        rowIndex =  [[[[fetchedResultsController sections] objectAtIndex:sectionIndex] objects] count]-1;
    }
    [self ShowMatch];
}

-(IBAction)NextButton {
    int nrows;
    nrows =  [self getNumberOfMatches:sectionIndex];
    if (rowIndex < (nrows-1)) rowIndex++;
    else {
        rowIndex = 0;
        sectionIndex = [self GetNextSection:currentSectionType];
    }
    [self ShowMatch];
}

-(NSUInteger)GetNextSection:(MatchType) currentSection {
    //    NSLog(@"GetNextSection");
    NSUInteger nextSection;
    switch (currentSection) {
        case Practice:
            currentSectionType = Seeding;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no seeding matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Seeding:
            currentSectionType = Elimination;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Elimination matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Elimination:
            currentSectionType = Practice;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Practice matches
                // Try seeding matches instead
                currentSectionType = Seeding;
                nextSection = [self getMatchSectionInfo:currentSectionType];
                if (nextSection == -1) { // There are no seeding matches either
                    nextSection = [self getMatchSectionInfo:currentSection];
                    currentSectionType = currentSection;
                }
            }
            break;
        case OtherMatch:
            currentSectionType = Testing;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Test matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Testing:
            currentSectionType = OtherMatch;
            nextSection = [self getMatchSectionInfo:currentSectionType];
            if (nextSection == -1) { // There are no Other matches
                nextSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
    }
    return nextSection;
}

// Move through the rounds
-(NSUInteger)GetPreviousSection:(NSUInteger) currentSection {
    //    NSLog(@"GetPreviousSection");
    NSUInteger newSection;
    switch (currentSection) {
        case Practice:
            currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Seeding:
            currentSectionType = Practice;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Practice matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Elimination:
            currentSectionType = Seeding;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Seeding matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case OtherMatch:
            currentSectionType = Testing;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Test matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
        case Testing:
            currentSectionType = OtherMatch;
            newSection = [self getMatchSectionInfo:currentSectionType];
            if (newSection == -1) { // There are no Other matches
                newSection = [self getMatchSectionInfo:currentSection];
                currentSectionType = currentSection;
            }
            break;
    }
    return newSection;
}

-(IBAction)MatchTypeSelectionChanged:(id)sender {
    //    NSLog(@"matchTypeSelectionChanged");
/*    if (matchTypePicker == nil) {
        self.matchTypePicker = [[MatchTypePickerController alloc]
                                initWithStyle:UITableViewStylePlain];
        matchTypePicker.delegate = self;
        matchTypePicker.matchTypeChoices = matchTypeList;
        self.matchTypePickerPopover = [[UIPopoverController alloc]
                                       initWithContentViewController:matchTypePicker];
    }
    [self.matchTypePickerPopover presentPopoverFromRect:matchType.bounds inView:matchType
                               permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];*/
}

- (void)matchTypeSelected:(NSString *)newMatchType {
    [self.matchTypePickerPopover dismissPopoverAnimated:YES];

    for (int i = 0 ; i < [matchTypeList count] ; i++) {
        if ([newMatchType isEqualToString:[matchTypeList objectAtIndex:i]]) {
            // NSLog(@"New section = %@", newMatchType);
            currentSectionType = 0; //[[matchDictionary getMatchTypeEnum:newMatchType] intValue];
            sectionIndex = [self getMatchSectionInfo:currentSectionType];
            break;
        }
    }
    rowIndex = 0;
    [self ShowMatch];
}

-(IBAction)MatchNumberChanged {
    // NSLog(@"MatchNumberChanged");
    
    int matchField = [matchNumber.text intValue];
    int nmatches =  [self getNumberOfMatches:sectionIndex];
    
    if (matchField > nmatches) { /* Ooops, not that many matches */
        // For now, just change the match field to the last match in the section
        matchField = nmatches;
    }
    rowIndex = matchField-1;
    
    [self ShowMatch];

}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{ /*
    [segue.destinationViewController setCurrentMatch:currentMatch];
    [segue.destinationViewController setDrawDirectory:settings.tournament.directory];
    if ([segue.identifier isEqualToString:@"Red1"]) {
        [segue.destinationViewController setCurrentTeam:[self GetTeam:0]];
    } else if ([segue.identifier isEqualToString:@"Red2"]) {
        [segue.destinationViewController setCurrentTeam:[self GetTeam:1]];
    } else if ([segue.identifier isEqualToString:@"Red3"]) {
        [segue.destinationViewController setCurrentTeam:[self GetTeam:2]];
    } else if ([segue.identifier isEqualToString:@"Blue1"]) {
        [segue.destinationViewController setCurrentTeam:[self GetTeam:3]];
    } else if ([segue.identifier isEqualToString:@"Blue2"]) {
        [segue.destinationViewController setCurrentTeam:[self GetTeam:4]];
    } else if ([segue.identifier isEqualToString:@"Blue3"]) {
        [segue.destinationViewController setCurrentTeam:[self GetTeam:5]];
    }*/
}

-(MatchData *)getCurrentMatch {
    if (numberMatchTypes == 0) {
        return nil;
    }
    else {
        NSIndexPath *matchIndex = [NSIndexPath indexPathForRow:rowIndex inSection:sectionIndex];
        return [fetchedResultsController objectAtIndexPath:matchIndex];
    }
}

-(void)ShowMatch {
    currentMatch = [self getCurrentMatch];
    [self setTeamList];
    
    [matchType setTitle:currentMatch.matchType forState:UIControlStateNormal];
    matchNumber.text = [NSString stringWithFormat:@"%d", [currentMatch.number intValue]];
    if ([currentMatch.redScore intValue] == -1) {
        redScore.text = @"";
    }
    else {
        redScore.text = [NSString stringWithFormat:@"%d", [currentMatch.redScore intValue]];
    }
    if ([currentMatch.blueScore intValue] == -1) {
        blueScore.text = @"";
    }
    else {
        blueScore.text = [NSString stringWithFormat:@"%d", [currentMatch.blueScore intValue]];
    }
    
    [red1 setTitle: [teamOrder objectAtIndex:0] forState:UIControlStateNormal];
    [red2 setTitle:[teamOrder objectAtIndex:1] forState:UIControlStateNormal];
    [red3 setTitle:[teamOrder objectAtIndex:2] forState:UIControlStateNormal];
    [blue1 setTitle:[teamOrder objectAtIndex:3] forState:UIControlStateNormal];
    [blue2 setTitle:[teamOrder objectAtIndex:4] forState:UIControlStateNormal];
    [blue3 setTitle:[teamOrder objectAtIndex:5] forState:UIControlStateNormal];
    

    //    [teamNumber setTitle:[NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]] forState:UIControlStateNormal];
//    teamName.text = currentTeam.team.name;

                                                  /*
     if ([currentTeam.endGameScore.modedRamp intValue] == 0) [modedRamp setOn:NO animated:YES];
     else [modedRamp setOn:YES animated:YES];
     */
//    notes.text = currentTeam.notes;
//    [alliance setTitle:[allianceList objectAtIndex:currentTeamIndex] forState:UIControlStateNormal];
    
    //    startingPosition.text =  [NSString stringWithFormat:@"%d", [currentTeam.startingPosition intValue]];
    
    // NSLog(@"Load the Picture");
    /*
    fieldDrawingPath = [baseDrawingPath stringByAppendingPathComponent:[NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]]];
    
    // Check the database to see if this team and match have a drawing already
    if (currentTeam.fieldDrawing) {
        // Load file, set file name to the name read, and load it as image
        // NSLog(@"Field Drawing= %@", currentTeam.fieldDrawing);
        fieldDrawingFile = currentTeam.fieldDrawing;
        NSString *path = [fieldDrawingPath stringByAppendingPathComponent:currentTeam.fieldDrawing];
        // NSLog(@"Full path = %@", path);
        if ([[NSFileManager defaultManager] fileExistsAtPath:path]) {
            [fieldImage setImage:[UIImage imageWithContentsOfFile:path]];
        }
        else {
            [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
            NSLog(@"Error reading field drawing file %@", fieldDrawingFile);
        }
        drawMode = DrawLock;
    }
    else {
        // NSLog(@"Field Drawing= %@", currentTeam.fieldDrawing);
        [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
        NSString *match;
        if ([currentMatch.number intValue] < 10) {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"00%d", [currentMatch.number intValue]]];
        } else if ( [currentMatch.number intValue] < 100) {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"0%d", [currentMatch.number intValue]]];
        } else {
            match = [NSString stringWithFormat:@"M%c%@", [currentMatch.matchType characterAtIndex:0], [NSString stringWithFormat:@"%d", [currentMatch.number intValue]]];
        }
        NSString *team;
        if ([currentTeam.team.number intValue] < 100) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"00%d", [currentTeam.team.number intValue]]];
        } else if ( [currentTeam.team.number intValue] < 1000) {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"0%d", [currentTeam.team.number intValue]]];
        } else {
            team = [NSString stringWithFormat:@"T%@", [NSString stringWithFormat:@"%d", [currentTeam.team.number intValue]]];
        }
        // Since no field drawing exists, we guess that the user wants to start in auton mode
        drawMode = DrawOff;
        fieldDrawingFile = [NSString stringWithFormat:@"%@_%@.png", match, team];
        [fieldImage setImage:[UIImage imageNamed:@"2013_field.png"]];
    }
    [self drawModeSettings:drawMode]; */
}

-(NSArray *)GetTeamMatches:(NSUInteger)currentTeamIndex {
    TeamScore *score = [self GetTeam:currentTeamIndex];
    NSLog(@"team number = %@", score.team.number);
    NSArray* objectsArray;// = [score.team.match allObjects];
/*    switch (currentTeamIndex) {
        case 0:
            teamNumber = [teamOrder objectAtIndex:currentTeamIndex];  // Red 1
            break;
        case 1:
            teamNumber = [teamData objectAtIndex:4];  // Red 2
            break;
        case 2:
            teamNumber = [teamData objectAtIndex:5];  // Red 3
            break;
        case 3:
            teamNumber = [teamData objectAtIndex:0];  // Blue 1
            break;
        case 4:
            teamNumber = [teamData objectAtIndex:1];  // Blue 2
            break;
        case 5:
            teamNumber = [teamData objectAtIndex:2];  // Blue 3
            break;
        default:
            teamNumber = nil;
    }
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:managedObjectContext];
    [fetchRequest setEntity:entity];
    
    // Edit the sort key as appropriate.
//    NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
//    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
//    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
    
    // Add the search for tournament name
//    NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament CONTAINS %@", settings.tournament.name];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number is %@", [teamNumber intValue]];
    [fetchRequest setPredicate:pred];
//    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *teamMatches = [managedObjectContext executeFetchRequest:fetchRequest error:&error];
    */
    return objectsArray;
}

-(TeamScore *)GetTeam:(NSUInteger)currentTeamIndex {
    switch (currentTeamIndex) {
        case 0: return [teamData objectAtIndex:3];  // Red 1
        case 1: return [teamData objectAtIndex:4];  // Red 2
        case 2: return [teamData objectAtIndex:5];  // Red 3
        case 3: return [teamData objectAtIndex:0];  // Blue 1
        case 4: return [teamData objectAtIndex:1];  // Blue 2
        case 5: return [teamData objectAtIndex:2];  // Blue 3
    }
    return nil;
}

-(void)setTeamList {
    TeamScore *score;
    NSSortDescriptor *allianceSort = [NSSortDescriptor sortDescriptorWithKey:@"alliance" ascending:YES];
    teamData = [[currentMatch.score allObjects] sortedArrayUsingDescriptors:[NSArray arrayWithObject:allianceSort]];
    
    if (teamOrder == nil) {
        self.teamOrder = [NSMutableArray array];
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
        for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder addObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        
    }
    else {
        // Reds
        for (int i = 3; i < 6; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder replaceObjectAtIndex:(i-3)
                                withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
        // Blues
        for (int i = 0; i < 3; i++) {
            score = [teamData objectAtIndex:i];
            [teamOrder replaceObjectAtIndex:(i+3)
                                withObject:[NSString stringWithFormat:@"%d", [score.team.number intValue]]];
        }
    }
}

-(void)SetTextBoxDefaults:(UITextField *)currentTextField {
    currentTextField.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:24.0];
}

-(void)SetSmallButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:15.0];
}

- (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    
    if (textField != matchNumber)  return YES;
    
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}
#endif
#pragma mark -
#pragma mark Text

- (BOOL)textFieldShouldReturn:(UITextField *)textField {
	[textField resignFirstResponder];
	return YES;
}

- (NSFetchedResultsController *)fetchedResultsController {
    // Set up the fetched results controller if needed.
    if (_fetchedResultsController == nil) {
        // Create the fetch request for the entity.
        NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
        // Edit the entity name as appropriate.
        NSEntityDescription *entity = [NSEntityDescription entityForName:@"MatchData" inManagedObjectContext:_dataManager.managedObjectContext];
        [fetchRequest setEntity:entity];
        
        // Edit the sort key as appropriate.
        NSSortDescriptor *typeDescriptor = [[NSSortDescriptor alloc] initWithKey:@"matchTypeSection" ascending:YES];
        NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
        NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:typeDescriptor, numberDescriptor, nil];
        // Add the search for tournament name
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"tournament CONTAINS %@", tournamentName];
        [fetchRequest setPredicate:pred];
        [fetchRequest setSortDescriptors:sortDescriptors];
        
        // Edit the section name key path and cache name if appropriate.
        // nil for section name key path means "no sections".
        NSFetchedResultsController *aFetchedResultsController =
        [[NSFetchedResultsController alloc]
         initWithFetchRequest:fetchRequest
         managedObjectContext:_dataManager.managedObjectContext
         sectionNameKeyPath:@"matchTypeSection"
         cacheName:@"Root"];
        aFetchedResultsController.delegate = self;
        self.fetchedResultsController = aFetchedResultsController;
    }
	
	return _fetchedResultsController;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return UIInterfaceOrientationIsLandscape(interfaceOrientation);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
