//
//  PadSyncViewController.m
//  AerialAssist
//
//  Created by Kylor Wang on 4/17/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "PadSyncViewController.h"
#import "DataManager.h"
#import "SyncTypeDictionary.h"
#import "SyncOptionDictionary.h"
#import "SharedSyncController.h"
#import "PopUpPickerViewController.h"

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

@end

@implementation PadSyncViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    SharedSyncController *syncController;
    
    id popUp;
    
    PopUpPickerViewController *xFerOptionPicker;
    UIPopoverController *xFerOptionPopover;
    
    SyncTypeDictionary *syncTypeDictionary;
    NSMutableArray *syncTypeList;
    PopUpPickerViewController *syncTypePicker;
    UIPopoverController *syncTypePopover;
    
    SyncOptionDictionary *syncOptionDictionary;
    NSMutableArray *syncOptionList;
    PopUpPickerViewController *syncOptionPicker;
    UIPopoverController *syncOptionPopover;
    
    BOOL firstReceipt;
    
    PopUpPickerViewController *importFileListPicker;
    UIPopoverController *importFileListPopover;
    NSArray *importFileList;
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
    [self SetBigButtonDefaults:_xFerOptionButton];
    [self SetBigButtonDefaults:_syncTypeButton];
    [self SetBigButtonDefaults:_syncOptionButton];
    [self SetBigButtonDefaults:_connectButton];
    [self SetBigButtonDefaults:_disconnectButton];
    [self SetBigButtonDefaults:_sendButton];
    [self SetBigButtonDefaults:_packageDataButton];
    [self SetBigButtonDefaults:_importFromiTunesButton];
    [self SetBigButtonDefaults:_createElimMatches];
    syncController = [SharedSyncController alloc];
    syncController.xFerOptionButton = _xFerOptionButton;
    syncController.syncTypeButton = _syncTypeButton;
    syncController.syncOptionButton = _syncOptionButton;
    syncController.connectButton = _connectButton;
    syncController.disconnectButton = _disconnectButton;
    syncController.peerName = _peerName;
    syncController.sendButton = _sendButton;
    syncController.syncDataTable = _syncDataTable;
    syncController.packageDataButton = _packageDataButton;
    syncController.importFromiTunesButton = _importFromiTunesButton;
    syncController = [syncController initWithDataManager:_dataManager];
    
    self.syncDataTable.delegate = syncController;
    self.syncDataTable.dataSource = syncController;
    
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    
    if (tournamentName) {
        self.title = [NSString stringWithFormat:@"%@ Sync", tournamentName];
    }
    else {
        self.title = @"Sync";
    }
    
    [syncController setSyncType:SyncMatchResults];
    syncTypeDictionary = [[SyncTypeDictionary alloc] init];
    syncTypeList = [[syncTypeDictionary getSyncTypes] mutableCopy];
    
    [syncController setSyncOption:SyncAllSavedSince];
    syncOptionDictionary = [[SyncOptionDictionary alloc] init];
    syncOptionList = [[syncOptionDictionary getSyncOptions] mutableCopy];
    
    [self selectXFerOption:@"Send Data"];
    [self selectSyncType:[syncTypeDictionary getSyncTypeString:SyncMatchResults]];
    [self selectSyncOption:[syncOptionDictionary getSyncOptionString:SyncAllSavedSince]];
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
        syncTypePopover = [[UIPopoverController alloc] initWithContentViewController:syncTypePicker];
        [syncTypePopover presentPopoverFromRect:((UIButton*)popUp).bounds inView:((UIButton*)popUp) permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (popUp == _syncOptionButton) {
        if (syncOptionPicker == nil) {
            syncOptionPicker = [[PopUpPickerViewController alloc]
                                initWithStyle:UITableViewStylePlain];
            syncOptionPicker.delegate = self;
            syncOptionPicker.pickerChoices = syncOptionList;
        }
        syncOptionPopover = [[UIPopoverController alloc] initWithContentViewController:syncOptionPicker];
        [syncOptionPopover presentPopoverFromRect:((UIButton*)popUp).bounds inView:((UIButton*)popUp) permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    } else if (popUp == _importFromiTunesButton) {
        popUp = _importFromiTunesButton;
        if (importFileListPicker == nil) {
            importFileListPicker = [[PopUpPickerViewController alloc]
                                    initWithStyle:UITableViewStylePlain];
            importFileListPicker.delegate = self;
        }
        importFileList = [syncController getImportFileList];
        importFileListPicker.pickerChoices = [importFileList mutableCopy];
        importFileListPopover = [[UIPopoverController alloc] initWithContentViewController:importFileListPicker];
        [importFileListPopover presentPopoverFromRect:((UIButton*)popUp).bounds inView:((UIButton*)popUp) permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (void)pickerSelected:(NSString *)newPick {
    if (popUp == _xFerOptionButton) {
        [xFerOptionPopover dismissPopoverAnimated:YES];
        xFerOptionPopover = nil;
        [self selectXFerOption:newPick];
    } else if (popUp == _syncTypeButton) {
        [syncTypePopover dismissPopoverAnimated:YES];
        syncTypePopover = nil;
        [self selectSyncType:newPick];
    } else if (popUp == _syncOptionButton) {
        [syncOptionPopover dismissPopoverAnimated:YES];
        syncOptionPopover = nil;
        [self selectSyncOption:newPick];
    } else if (popUp == _importFromiTunesButton) {
        [importFileListPopover dismissPopoverAnimated:YES];
        importFileListPicker = nil;
        importFileListPopover = nil;
        [syncController importiTunesSelected:newPick];
    }
}

-(void)selectXFerOption:(NSString *)xFerChoice {
    [_xFerOptionButton setTitle:xFerChoice forState:UIControlStateNormal];
    if ([xFerChoice isEqualToString:@"Send Data"]) {
        [syncController setXFerOption:Sending];
    } else if ([xFerChoice isEqualToString:@"Receive Data"]) {
        [syncController setXFerOption:Receiving];
    }
    [syncController updateTableData];
}

-(void)selectSyncType:(NSString *)typeChoice {
    [_syncTypeButton setTitle:typeChoice forState:UIControlStateNormal];
    for (int i = 0 ; i < [syncTypeList count] ; i++) {
        if ([typeChoice isEqualToString:[syncTypeList objectAtIndex:i]]) {
            [syncController setSyncType:i];
            break;
        }
    }
    [syncController updateTableData];
}

-(void)selectSyncOption:(NSString *)optionChoice {
    [_syncOptionButton setTitle:optionChoice forState:UIControlStateNormal];
    for (int i = 0 ; i < [syncOptionList count] ; i++) {
        if ([optionChoice isEqualToString:[syncOptionList objectAtIndex:i]]) {
            [syncController setSyncOption:i];
            break;
        }
    }
    [syncController updateTableData];
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

-(void)SetBigButtonDefaults:(UIButton *)currentButton {
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
