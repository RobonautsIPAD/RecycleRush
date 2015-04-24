//
//  DetailedTransferViewController.m
//  RecycleRush
//
//  Created by FRC on 4/13/15.
//  Copyright (c) 2015 FRC. All rights reserved.
//

#import "DetailedTransferViewController.h"
#import "UIDefaults.h"
#import "DataManager.h"
#import "ConnectionUtility.h"
#import "FileIOMethods.h"
#import "Packet.h"
#import "DataSync.h"
#import "TeamScore.h"
#import "ScoreAccessors.h"
#import "MatchAccessors.h"
#import "LNNumberpad.h"


@interface DetailedTransferViewController ()
@property (weak, nonatomic) IBOutlet UIButton *requestFromButton;
@property (weak, nonatomic) IBOutlet UIButton *sendToButton;
@property (weak, nonatomic) IBOutlet UITextField *getMatchText;
@property (weak, nonatomic) IBOutlet UITextField *sendMatchText;
@property (weak, nonatomic) IBOutlet UIButton *requestMatchButton;
@property (weak, nonatomic) IBOutlet UIButton *requestMatchPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMatchButton;
@property (weak, nonatomic) IBOutlet UIButton *sendMatchPhotoButton;
@property (weak, nonatomic) IBOutlet UIButton *requestAllianceButton;
@property (weak, nonatomic) IBOutlet UIButton *sendAllianceButton;
@property (weak, nonatomic) IBOutlet UIButton *requestTypeButton;
@property (weak, nonatomic) IBOutlet UIButton *sendTypeButton;

@end

@implementation DetailedTransferViewController {
    NSUserDefaults *prefs;
    NSString *tournamentName;
    NSString *deviceName;
    BlueToothType bluetoothRole;
	GKSession *session;
    NSDictionary *matchTypeDictionary;
    NSDictionary *allianceDictionary;
    id popUp;
    DataSync *dataSyncPackage;
    UIColor *buttonColor;
    
    NSArray *allianceList;
    PopUpPickerViewController *alliancePicker;
    UIPopoverController *alliancePopover;

    NSMutableDictionary *peerList;
    NSMutableArray *clientList;
    PopUpPickerViewController *devicePicker;
    UIPopoverController *devicePopover;

    NSArray *matchTypeList;
    PopUpPickerViewController *matchTypePicker;
    UIPopoverController *matchTypePickerPopover;
}

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

-(void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    prefs = [NSUserDefaults standardUserDefaults];
    tournamentName = [prefs objectForKey:@"tournament"];
    deviceName = [prefs objectForKey:@"deviceName"];
    bluetoothRole = [[prefs objectForKey:@"bluetooth"] intValue];
    
    if (tournamentName) {
        self.title = [NSString stringWithFormat:@"%@ Sync", tournamentName];
    }
    else {
        self.title = @"Detailed Transfer";
    }
    dataSyncPackage = [[DataSync alloc] init:_dataManager];
    matchTypeDictionary = _dataManager.matchTypeDictionary;
    allianceDictionary = _dataManager.allianceDictionary;
    if (bluetoothRole == Master) {
        session = _connectionUtility.matchMakingServer.session;
    }
    else {
        session = _connectionUtility.matchMakingClient.session;
    }
    
    [UIDefaults setBigButtonDefaults:_requestFromButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_requestAllianceButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_sendToButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_sendAllianceButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_requestMatchButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_requestMatchPhotoButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_sendMatchButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_sendMatchPhotoButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_requestTypeButton withFontSize:nil];
    [UIDefaults setBigButtonDefaults:_sendTypeButton withFontSize:nil];
    _getMatchText.inputView = [LNNumberpad defaultLNNumberpad];
    _sendMatchText.inputView = [LNNumberpad defaultLNNumberpad];

    allianceList = [NSArray arrayWithObjects:@"Red 1", @"Red 2", @"Red 3", @"Blue 1", @"Blue 2", @"Blue 3", nil];
    [self buildClientList];
    [_sendToButton setTitle:[clientList objectAtIndex:0] forState:UIControlStateNormal];
    [_requestFromButton setTitle:[clientList objectAtIndex:0] forState:UIControlStateNormal];
   
    // Set the notification to receive information after data is received via bluetooth
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(dataReceived:) name:@"ReceivedData" object:nil];
    // Set the notification to receive information after a client had connected or disconnected
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateClientStatus:) name:@"clientStatusChanged" object:nil];
    buttonColor = [UIColor colorWithRed:(0.0/255) green:(0.0/255) blue:(120.0/255) alpha:1.0];
}

- (IBAction)requestButtonPressed:(id)sender {
    NSNumber *matchType = [MatchAccessors getMatchTypeFromString:_requestTypeButton.titleLabel.text fromDictionary:matchTypeDictionary];
    NSNumber *alliance = [MatchAccessors getAllianceStation:_requestAllianceButton.titleLabel.text fromDictionary:allianceDictionary];
    NSNumber *matchNumber = [NSNumber numberWithInt:[_getMatchText.text intValue]];
    Packet *packet;
    if (sender == _requestMatchButton) {
        packet = [Packet packetWithType:PacketTypeMatchRequest];
    }
    else {
        packet = [Packet packetWithType:PacketTypePhotoRequest];
    }
    [packet setDataDictionary:[NSDictionary dictionaryWithObjectsAndKeys:matchType, @"MatchType", matchNumber, @"MatchNumber", alliance, @"Alliance", nil]];
    NSString *receiver = _requestFromButton.titleLabel.text;
    [_connectionUtility sendPacketToClient:packet forClient:[peerList objectForKey:receiver] inSession:session];
}

- (IBAction)sendButtonPressed:(id)sender {
    // Check sender
    NSString *allianceString = _sendAllianceButton.titleLabel.text;
    NSString *matchTypeString = _sendTypeButton.titleLabel.text;
    NSNumber *matchNumber = [NSNumber numberWithInt:[_sendMatchText.text intValue]];
    TeamScore *score = [ScoreAccessors getScoreRecord:matchNumber forType:[MatchAccessors getMatchTypeFromString:matchTypeString fromDictionary:matchTypeDictionary] forAlliance:[MatchAccessors getAllianceStation:allianceString fromDictionary:allianceDictionary] forTournament:tournamentName fromDataManager:_dataManager];
    NSString *receiver = [peerList objectForKey:_sendToButton.titleLabel.text];
    if (sender == _sendMatchButton) {
        // If match, go fetch the match, package and send
        if (score) {
            [dataSyncPackage bluetoothDataTranfer:[NSArray arrayWithObject:score] toPeers:_sendToButton.titleLabel.text forConnection:_connectionUtility inSession:session];
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"%@ Match %@, %@ not found", matchTypeString, matchNumber, allianceString];
            [self alertMessage:msg];
        }
    }
    else if (sender == _sendMatchPhotoButton) {
        if (score.fieldPhotoName) {
            dispatch_async(dispatch_get_global_queue( DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
                [dataSyncPackage bluetoothDataTranfer:[NSArray arrayWithObject:score.fieldPhotoName] toPeers:receiver forConnection:_connectionUtility inSession:session];
            });
        }
        else {
            NSString *msg = [NSString stringWithFormat:@"%@ Match %@, %@ photo not found", matchTypeString, matchNumber, allianceString];
            [self alertMessage:msg];
        }
    }
}

- (IBAction)deviceButtonSelection:(id)sender {
    UIButton *pressedButton = (UIButton *)sender;
    if (sender == _requestFromButton || sender == _sendToButton) {
        if (devicePicker == nil) {
            devicePicker = [[PopUpPickerViewController alloc]
                            initWithStyle:UITableViewStylePlain];
            devicePicker.delegate = self;
            devicePicker.pickerChoices = clientList;
            devicePopover = [[UIPopoverController alloc]
                             initWithContentViewController:devicePicker];
        }
        [devicePopover presentPopoverFromRect:pressedButton.bounds inView:pressedButton
                     permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (IBAction)allianceButtonSelection:(id)sender {
    popUp = sender;
    UIButton *pressedButton = (UIButton *)sender;
    if (sender == _requestAllianceButton || sender == _sendAllianceButton) {
        if (alliancePicker == nil) {
            alliancePicker = [[PopUpPickerViewController alloc]
                              initWithStyle:UITableViewStylePlain];
            alliancePicker.delegate = self;
            alliancePicker.pickerChoices = allianceList;
            alliancePopover = [[UIPopoverController alloc]
                               initWithContentViewController:alliancePicker];
        }
        [alliancePopover presentPopoverFromRect:pressedButton.bounds inView:pressedButton
                       permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
    }
}

- (IBAction)matchTypeSelection:(id)sender {
    UIButton *PressedButton = (UIButton*)sender;
    popUp = PressedButton;
    if (!matchTypeList) matchTypeList = [FileIOMethods initializePopUpList:@"MatchType"];
    if (matchTypePicker == nil) {
        matchTypePicker = [[PopUpPickerViewController alloc]
                           initWithStyle:UITableViewStylePlain];
        matchTypePicker.delegate = self;
        matchTypePicker.pickerChoices = matchTypeList;
    }
    if (!matchTypePickerPopover) {
        matchTypePickerPopover = [[UIPopoverController alloc]
                                  initWithContentViewController:matchTypePicker];
    }
    [matchTypePickerPopover presentPopoverFromRect:PressedButton.bounds inView:PressedButton
                          permittedArrowDirections:UIPopoverArrowDirectionAny animated:YES];
}

-(void)pickerSelected:(NSString *)newPick {
    // NSLog(@"Picker = %@", newPick);
    if (popUp == _requestFromButton) {
        [devicePopover dismissPopoverAnimated:YES];
        [self newDevice:newPick];
    } else if (popUp == _sendToButton) {
        [devicePopover dismissPopoverAnimated:YES];
        [self newDevice:newPick];
    } else if (popUp == _requestAllianceButton) {
        [alliancePopover dismissPopoverAnimated:YES];
        [self newAlliance:newPick];
    } else if (popUp == _sendAllianceButton) {
        [alliancePopover dismissPopoverAnimated:YES];
        [self newAlliance:newPick];
    } else if (popUp == _requestTypeButton) {
        [matchTypePickerPopover dismissPopoverAnimated:YES];
        [self newMatchType:newPick];
    } else if (popUp == _sendTypeButton) {
        [matchTypePickerPopover dismissPopoverAnimated:YES];
        [self newMatchType:newPick];
    }
}


-(void)newDevice:(NSString *)device {
    NSUInteger index = [clientList indexOfObject:device];
    if (index == NSNotFound) return;
    UIButton *pressedButton = (UIButton *)popUp;
    [pressedButton setTitle:device forState:UIControlStateNormal];
}

-(void)newAlliance:(NSString *)alliance {
    NSUInteger index = [allianceList indexOfObject:alliance];
    if (index == NSNotFound) return;
    UIButton *pressedButton = (UIButton *)popUp;
    [pressedButton setTitle:alliance forState:UIControlStateNormal];
}

-(void)newMatchType:(NSString *)matchType {
    NSUInteger index = [matchTypeList indexOfObject:matchType];
    if (index == NSNotFound) return;
    UIButton *pressedButton = (UIButton *)popUp;
    [pressedButton setTitle:matchType forState:UIControlStateNormal];
}

-(void)buildClientList {
    if (bluetoothRole == Master) {
        NSUInteger connectedClients = [_connectionUtility.matchMakingServer connectedClientCount];
        if (connectedClients) {
            peerList = [[NSMutableDictionary alloc] init];
            for (int i=0; i<connectedClients; i++) {
                NSString *peer = [_connectionUtility.matchMakingServer peerIDForConnectedClientAtIndex:i];
                [peerList setObject:peer forKey:[_connectionUtility.matchMakingServer displayNameForPeerID:peer]];
            }
            clientList = [[peerList allKeys] mutableCopy];
            if (connectedClients > 1) {
                [clientList sortUsingSelector:@selector(localizedCaseInsensitiveCompare:)];
            }
            [_sendToButton setUserInteractionEnabled:TRUE];
            [_requestFromButton setUserInteractionEnabled:TRUE];
            [_sendMatchButton setHidden:FALSE];
            [_sendMatchPhotoButton setHidden:FALSE];
            [_requestMatchButton setHidden:FALSE];
            [_requestMatchPhotoButton setHidden:FALSE];
        }
        else {
            clientList = [[NSMutableArray alloc] initWithObjects:@"No Clients", nil];
            [_sendToButton setTitle:@"No Clients" forState:UIControlStateNormal];
            [_sendToButton setUserInteractionEnabled:FALSE];
            [_requestFromButton setUserInteractionEnabled:FALSE];
/*            [_sendMatchButton setHidden:TRUE];
            [_sendMatchPhotoButton setHidden:TRUE];
            [_requestMatchButton setHidden:TRUE];
            [_requestMatchPhotoButton setHidden:TRUE];*/
            [_sendMatchButton setHidden:FALSE];
            [_sendMatchPhotoButton setHidden:FALSE];
            [_requestMatchButton setHidden:FALSE];
            [_requestMatchPhotoButton setHidden:FALSE];
        }
    }
    else {
     //   [_sendButton setHidden:FALSE];
    }
}

-(void)updateClientStatus:(NSNotification *)notification {
    if (bluetoothRole == Scouter) {
/*        [self setClientStatus];
        NSDictionary *dictionary = [notification userInfo];
        NSNumber *connectionMessage = [dictionary objectForKey:@"status"];
        if ([connectionMessage intValue] == ClientConnect) {
            if ([_autoConnectButton isSelected]) {
                [prefs setObject:serverName forKey:@"serverName"];
            }
        }
        [_connectedDeviceButton setHidden:TRUE];*/
    }
    else {
        NSDictionary *dictionary = [notification userInfo];
        NSNumber *connectionMessage = [dictionary objectForKey:@"Message"];
        NSString *peerID = [dictionary objectForKey:@"PeerID"];
        if ([connectionMessage intValue] == ClientDisconnect) {
            if ([peerID isEqualToString:_requestFromButton.titleLabel.text]) {
                [_requestFromButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [_requestMatchButton setHidden:TRUE];
                [_requestMatchPhotoButton setHidden:TRUE];
            }
            if ([peerID isEqualToString:_sendToButton.titleLabel.text]) {
                [_sendToButton setTitleColor:[UIColor grayColor] forState:UIControlStateNormal];
                [_sendMatchButton setHidden:TRUE];
                [_sendMatchPhotoButton setHidden:TRUE];
            }
        }
        else {
            if ([peerID isEqualToString:_requestFromButton.titleLabel.text]) {
                [_requestFromButton setTitleColor:buttonColor forState:UIControlStateNormal];
                [_requestMatchButton setHidden:FALSE];
                [_requestMatchPhotoButton setHidden:FALSE];
            }
            if ([peerID isEqualToString:_sendToButton.titleLabel.text]) {
                [_sendToButton setTitleColor:buttonColor forState:UIControlStateNormal];
                [_sendMatchButton setHidden:FALSE];
                [_sendMatchPhotoButton setHidden:FALSE];
            }
        }
    }
}

-(void)dataReceived:(NSNotification *)notification {
    NSLog(@"%@", notification);
//    NSDictionary *dictionary = [notification userInfo];
 /*   if (![dictionary objectForKey:@"Error"]) {
        [recordsReceived addObject:dictionary];
    }
    nRecordsReceived++;
    if (nRecordsReceived == nRecordsSent) {
        displayList = recordsReceived;
        [_syncDataTable reloadData];
    }*/
}
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string {
    //    if (textField != _foulTextField)  return YES;
    NSString *resultingString = [textField.text stringByReplacingCharactersInRange: range withString: string];
    // This allows backspace
    if ([resultingString length] == 0) {
        return true;
    }
    
    NSInteger holder;
    NSScanner *scan = [NSScanner scannerWithString: resultingString];
    
    return [scan scanInteger: &holder] && [scan isAtEnd];
}

-(void)alertMessage:(NSString *)msg {
    UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Transfer Problem"
                                                      message:msg
                                                     delegate:nil
                                            cancelButtonTitle:@"Ok"
                                            otherButtonTitles:nil];
    [prompt setAlertViewStyle:UIAlertViewStyleDefault];
    [prompt show];
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
