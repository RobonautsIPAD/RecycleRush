//
//  PadSyncViewController.m
//  RecycleRush
//
//  Created by Kylor Wang on 4/17/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PadSyncViewController.h"
#import "DataManager.h"
#import "DataSync.h"
#import "TournamentData.h"
#import "TeamData.h"
#import "MatchData.h"
#import "SyncTableCells.h"
#import "EnumerationDictionary.h"
#import "SyncTypeDictionary.h"
#import "SyncOptionDictionary.h"
#import "PopUpPickerViewController.h"
#import <QuartzCore/CALayer.h>

@interface PadSyncViewController ()
@property (nonatomic, weak) IBOutlet UITableView *syncDataTable;
@property (nonatomic, weak) IBOutlet UIButton *xFerOptionButton;
@property (nonatomic, weak) IBOutlet UIButton *syncTypeButton;
@property (nonatomic, weak) IBOutlet UIButton *syncOptionButton;
@property (nonatomic, weak) IBOutlet UIButton *connectButton;
@property (nonatomic, weak) IBOutlet UIButton *disconnectButton;
@property (nonatomic, weak) IBOutlet UILabel *peerName;
@property (nonatomic, weak) IBOutlet UIButton *sendButton;
@property (nonatomic, weak) IBOutlet UIButton *packageDataButton;
@property (nonatomic, weak) IBOutlet UIButton *importFromiTunesButton;
@property (weak, nonatomic) IBOutlet UIButton *createElimMatches;
@property (weak, nonatomic) IBOutlet UIButton *viewErrorsButton;

@end

@implementation PadSyncViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    DataSync *dataSyncPackage;

    NSArray *filteredSendList;
    NSArray *receivedList;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    
    id popUp;
    
    BOOL transferSuccess;
    
    XFerOption xFerOption;
    PopUpPickerViewController *xFerOptionPicker;
    UIPopoverController *xFerOptionPopover;
    
    NSArray *syncTypeList;
    PopUpPickerViewController *syncTypePicker;
    UIPopoverController *syncTypePopover;
    
    NSArray *syncOptionList;
    PopUpPickerViewController *syncOptionPicker;
    UIPopoverController *syncOptionPopover;
    
    NSArray *importFileList;
    PopUpPickerViewController *importFileListPicker;
    UIPopoverController *importFileListPopover;
    NSString *importedFile;

    BOOL firstReceipt;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil {
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
	if (!_dataManager) {
        _dataManager = [[DataManager alloc] init];
    }
    [self setBigButtonDefaults:_xFerOptionButton];
    [self setBigButtonDefaults:_syncTypeButton];
    [self setBigButtonDefaults:_syncOptionButton];
    [self setBigButtonDefaults:_connectButton];
    [self setBigButtonDefaults:_disconnectButton];
    [self setBigButtonDefaults:_sendButton];
    [self setBigButtonDefaults:_packageDataButton];
    [self setBigButtonDefaults:_importFromiTunesButton];
    [self setBigButtonDefaults:_createElimMatches];
    dataSyncPackage = [[DataSync alloc] init:_dataManager];

    syncTypeList = [SyncMethods getSyncTypeList];
    syncOptionList = [SyncMethods getSyncOptionList];
    [_syncTypeButton setTitle:[SyncMethods getSyncTypeString:_syncType] forState:UIControlStateNormal];
    [_syncOptionButton setTitle:[SyncMethods getSyncOptionString:_syncOption] forState:UIControlStateNormal];
    xFerOption = Sending;
    [self setSendList];
    
    [_xFerOptionButton setHidden:YES];
    [_disconnectButton setHidden:YES];
    [_sendButton setHidden:YES];
    [_peerName setHidden:YES];

    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    
    if (tournamentName) {
        self.title = [NSString stringWithFormat:@"%@ Sync", tournamentName];
    }
    else {
        self.title = @"Sync";
    }
    matchTypeDictionary = [EnumerationDictionary initializeBundledDictionary:@"MatchType"];
    allianceDictionary = [EnumerationDictionary initializeBundledDictionary:@"AllianceList"];
    transferSuccess = TRUE;
}

-(void)setSendList {
    if (_syncType == SyncTeams) {
        filteredSendList = [dataSyncPackage getFilteredTeamList:_syncOption];
    }
    else if (_syncType == SyncMatchList) {
        filteredSendList = [dataSyncPackage getFilteredMatchList:_syncOption];
    }
    else if (_syncType == SyncMatchResults) {
        filteredSendList = [dataSyncPackage getFilteredResultsList:_syncOption];
    }
    else if (_syncType == SyncTournaments) {
        filteredSendList = [dataSyncPackage getFilteredTournamentList:_syncOption];
    }
}

- (IBAction)selectPackageData:(id)sender {
    NSError *error = nil;
    transferSuccess |= [dataSyncPackage packageDataForiTunes:_syncType forData:filteredSendList error:&error];
    if (error) {
        [_dataManager writeErrorMessage:error forType:[error code]];
    }
}

- (IBAction)selectAction:(id)sender {
    popUp = sender;
    if (popUp == _xFerOptionButton) {
        if (xFerOptionPicker == nil) {
            xFerOptionPicker = [[PopUpPickerViewController alloc]
                                initWithStyle:UITableViewStylePlain];
            xFerOptionPicker.delegate = self;
            xFerOptionPicker.pickerChoices = [NSMutableArray arrayWithObjects:@"Send Data", @"Receive Data", nil];
        }
        xFerOptionPopover = [[UIPopoverController alloc] initWithContentViewController:xFerOptionPicker];
        [xFerOptionPopover presentPopoverFromRect:((UIButton*)popUp).bounds inView:((UIButton*)popUp) permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (popUp == _syncTypeButton) {
        if (syncTypePicker == nil) {
            syncTypePicker = [[PopUpPickerViewController alloc] initWithStyle:UITableViewStylePlain];
            syncTypePicker.delegate = self;
            syncTypePicker.pickerChoices = syncTypeList;
        }
        if (!syncTypePopover) {
            syncTypePopover = [[UIPopoverController alloc] initWithContentViewController:syncTypePicker];
        }
        [syncTypePopover presentPopoverFromRect:((UIButton*)popUp).bounds inView:((UIButton*)popUp) permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (popUp == _syncOptionButton) {
        if (syncOptionPicker == nil) {
            syncOptionPicker = [[PopUpPickerViewController alloc]
                                initWithStyle:UITableViewStylePlain];
            syncOptionPicker.delegate = self;
            syncOptionPicker.pickerChoices = syncOptionList;
        }
        if (!syncOptionPopover) {
            syncOptionPopover = [[UIPopoverController alloc] initWithContentViewController:syncOptionPicker];
        }
        [syncOptionPopover presentPopoverFromRect:((UIButton*)popUp).bounds inView:((UIButton*)popUp) permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (popUp == _importFromiTunesButton) {
        popUp = _importFromiTunesButton;
        if (importFileListPicker == nil) {
            importFileListPicker = [[PopUpPickerViewController alloc]
                                    initWithStyle:UITableViewStylePlain];
            importFileListPicker.delegate = self;
        }
        importFileList = [dataSyncPackage getImportFileList];
        importFileListPicker.pickerChoices = [importFileList mutableCopy];
        if (!importFileListPopover) {
            importFileListPopover = [[UIPopoverController alloc] initWithContentViewController:importFileListPicker];
        }
        [importFileListPopover presentPopoverFromRect:((UIButton*)popUp).bounds inView:((UIButton*)popUp) permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

-(void)pickerSelected:(NSString *)newPick {
    if (popUp == _xFerOptionButton) {
        [xFerOptionPopover dismissPopoverAnimated:YES];
        [self selectXFerOption:newPick];
    } else if (popUp == _syncTypeButton) {
        [syncTypePopover dismissPopoverAnimated:YES];
        [self selectSyncType:newPick];
    } else if (popUp == _syncOptionButton) {
        [syncOptionPopover dismissPopoverAnimated:YES];
        [self selectSyncOption:newPick];
    } else if (popUp == _importFromiTunesButton) {
        [importFileListPopover dismissPopoverAnimated:YES];
        [self iTunesImportSelected:newPick];
    }
}

-(void)iTunesImportSelected:(NSString *)importFile {
    importFileListPicker = nil;
    importFileListPopover = nil;
    NSError *error;
    receivedList = [dataSyncPackage importiTunesSelected:importFile error:&error];
    if (error) {
        [_dataManager writeErrorMessage:error forType:[error code]];
    }

    importedFile = importFile;
    xFerOption = Receiving;
    [self checkReceivedDataType];
    [_syncDataTable reloadData];
}

-(void)selectXFerOption:(NSString *)xFerChoice {
    [_xFerOptionButton setTitle:xFerChoice forState:UIControlStateNormal];
    if ([xFerChoice isEqualToString:@"Send Data"]) {
 //       [syncController setXFerOption:Sending];
    } else if ([xFerChoice isEqualToString:@"Receive Data"]) {
//        [syncController setXFerOption:Receiving];
    }
 //   [syncController updateTableData];
}

-(void)selectSyncType:(NSString *)typeChoice {
    [_syncTypeButton setTitle:typeChoice forState:UIControlStateNormal];
    _syncType = [SyncMethods getSyncType:typeChoice];
    xFerOption = Sending;
    [self setSendList];
    [_syncDataTable reloadData];
}

-(void)selectSyncOption:(NSString *)optionChoice {
    [_syncOptionButton setTitle:optionChoice forState:UIControlStateNormal];
    _syncOption = [SyncMethods getSyncOption:optionChoice];
    [self setSendList];
    [_syncDataTable reloadData];
}

-(void)checkReceivedDataType {
    if (receivedList) {
        if ([importedFile.pathExtension compare:@"mrd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _syncType = SyncMatchResults;
        } else if ([importedFile.pathExtension compare:@"tmd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _syncType = SyncTeams;
        } else if ([importedFile.pathExtension compare:@"msd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _syncType = SyncMatchList;
        } else if ([importedFile.pathExtension compare:@"csv" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _syncType = SyncMatchList;
        } else if ([importedFile.pathExtension compare:@"pho" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _syncType = SyncPhotos;
        } else if ([importedFile.pathExtension compare:@"tnd" options:NSCaseInsensitiveSearch] == NSOrderedSame) {
            _syncType = SyncTournaments;
        }
        [_syncTypeButton setTitle:[SyncMethods getSyncTypeString:_syncType] forState:UIControlStateNormal];
    }
}

- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
}

- (void) viewWillDisappear:(BOOL)animated {
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (xFerOption == Sending) {
        return [filteredSendList count];
    } else if (xFerOption == Receiving) {
        return [receivedList count];
    }
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *identifier1 = @"Tournament";
    static NSString *identifier2 = @"Team";
    static NSString *identifier3 = @"MatchList";
    static NSString *identifier4 = @"MatchResult";
    static NSString *identifier5 = @"Photos";
    UITableViewCell *cell;
    // Set up the cell...
    if (_syncType == SyncTournaments) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier1 forIndexPath:indexPath];
        TournamentData *tournament;
        if (xFerOption == Sending) tournament = [filteredSendList objectAtIndex:indexPath.row];
        else tournament = [receivedList objectAtIndex:indexPath.row];
   //     cell = [SyncTableCells configureTournamentCell:cell forXfer:xFerOption forTournament:tournament];
    }
    else if (_syncType == SyncTeams) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier2 forIndexPath:indexPath];
        if (xFerOption == Sending) {
       //     TeamData *team = [filteredSendList objectAtIndex:indexPath.row];
     //       cell = [SyncTableCells configureTeamCell:cell forTeam:team];
        }
        else {
            NSDictionary *team = [receivedList objectAtIndex:indexPath.row];
 //           cell = [SyncTableCells configureReceivedTeamCell:cell forTeam:team];
        }
    }
    else if (_syncType == SyncMatchList) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier3 forIndexPath:indexPath];
        id match;
        if (xFerOption == Sending) match = [filteredSendList objectAtIndex:indexPath.row];
        else match = [receivedList objectAtIndex:indexPath.row];
      //  cell = [SyncTableCells configureMatchListCell:cell forXfer:(XFerOption)xFerOption forMatch:match forMatchDictionary:matchTypeDictionary forAlliances:allianceDictionary];

    }
    else if (_syncType == SyncMatchResults) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier4 forIndexPath:indexPath];
        id score;
        if (xFerOption == Sending) score = [filteredSendList objectAtIndex:indexPath.row];
        else score = [receivedList objectAtIndex:indexPath.row];
  //      cell = [SyncTableCells configureResultsCell:cell forXfer:(XFerOption)xFerOption forScore:score forMatchDictionary:matchTypeDictionary forAlliances:allianceDictionary];
    }
    else if (_syncType == SyncPhotos) {
        cell = [tableView dequeueReusableCellWithIdentifier:identifier5 forIndexPath:indexPath];
        cell = [SyncTableCells configurePhotoCell:cell forPhotoList:[receivedList objectAtIndex:indexPath.row]];
    }
    return cell;
}

-(void)setBigButtonDefaults:(UIButton *)currentButton {
    currentButton.titleLabel.font = [UIFont fontWithName:@"Helvetica" size:16.0];
    // Round button corners
    CALayer *btnLayer = [currentButton layer];
    [btnLayer setMasksToBounds:YES];
    [btnLayer setCornerRadius:10.0f];
    // Apply a 1 pixel, black border
    [btnLayer setBorderWidth:1.0f];
    [btnLayer setBorderColor:[[UIColor blackColor] CGColor]];
    // Set the button Background Color
    [currentButton setBackgroundColor:[UIColor whiteColor]];
    // Set the button Text Color
    [currentButton setTitleColor:[UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0 ]forState: UIControlStateNormal];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
