//
//  TeamDataInterfaces.m
// Robonauts Scouting
//
//  Created by FRC on 5/2/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "TeamDataInterfaces.h"
#import "DataManager.h"
#import "TeamData.h"
#import "TournamentData.h"
#import "Photo.h"
#import "TournamentDataInterfaces.h"
#import "Regional.h"

@implementation TeamDataInterfaces
@synthesize dataManager = _dataManager;
@synthesize teamDataAttributes = _teamDataAttributes;
@synthesize teamDataProperties = _teamDataProperties;

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
}

-(TeamData *)addTeam:(NSNumber *)teamNumber forName:(NSString *)teamName forTournament:(NSString *)tournamentName {
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    NSUserDefaults *prefs = [NSUserDefaults standardUserDefaults];
    
    NSLog(@"addTeam - need to add saveBy and saved values");
    
    // Check to make sure tournament exists, if not, error out
    TournamentData *tournamentRecord = [[[TournamentDataInterfaces alloc] initWithDataManager:_dataManager] getTournament:tournamentName];
    if (!tournamentRecord) {
        NSString *msg = [NSString stringWithFormat:@"Tournament %@ does not exist", tournamentName];
        UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Add Alert"
                                                          message:msg
                                                         delegate:nil
                                                cancelButtonTitle:@"Ok"
                                                otherButtonTitles:nil];
        [prompt setAlertViewStyle:UIAlertViewStyleDefault];
        [prompt show];
        return nil;
    }

    TeamData *teamRecord = [self getTeam:teamNumber];
    if (teamRecord) {
        // If team already exists, add it to the tournament
        NSArray *allTournaments = [teamRecord.tournament allObjects];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", tournamentRecord.name];
        NSArray *list = [allTournaments filteredArrayUsingPredicate:pred];
        if (![list count]) {
             NSLog(@"Adding Tournament");
            [teamRecord addTournamentObject:tournamentRecord];
        }
        else {
            NSLog(@"Tournament Exists, count = %d", [list count]);
            NSLog(@"Add Team %@ already exists", teamNumber);
            NSString *msg = [NSString stringWithFormat:@"%@ already exists in this tournament", teamNumber];
            UIAlertView *prompt  = [[UIAlertView alloc] initWithTitle:@"Team Add Alert"
                                                              message:msg
                                                             delegate:nil
                                                    cancelButtonTitle:@"Ok"
                                                    otherButtonTitles:nil];
            [prompt setAlertViewStyle:UIAlertViewStyleDefault];
            [prompt show];
            teamRecord = nil;
        }

        teamRecord.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
        teamRecord.savedBy = [prefs objectForKey:@"deviceName"];
       return teamRecord;
    }
    else {
        // If team does not exist, add it and add it to the tournament
        teamRecord = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                                             inManagedObjectContext:_dataManager.managedObjectContext];
        [teamRecord setValue:teamNumber forKey:@"number"];
        [teamRecord setValue:teamName forKey:@"name"];
        [teamRecord addTournamentObject:tournamentRecord];
        teamRecord.saved = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];
        teamRecord.savedBy = [prefs objectForKey:@"deviceName"];
        return teamRecord;
    }
}

-(AddRecordResults)createTeamFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *teamNumber;
    TeamData *team;
    AddRecordResults results = DB_ADDED;

    if (![data count]) return DB_ERROR;
    
    // For now, I am going to only allow it to work if the team number is in the first column
    if (![[headers objectAtIndex:0] isEqualToString:@"Team Number"]) {
        return DB_ERROR;
    }
    teamNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    // NSLog(@"Found team number = %@", teamNumber);
    team = [self getTeam:teamNumber];
    if (team) {
        // NSLog(@"createTeamFromFile:Team %@ already exists", teamNumber);
        // NSLog(@"Team = %@", team);
        results = DB_MATCHED;
    }
    else {
        team = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                                                       inManagedObjectContext:_dataManager.managedObjectContext];
        [team setValue:teamNumber forKey:@"number"];
    }
    if (!_teamDataProperties) _teamDataProperties = [[team entity] propertiesByName];
    for (int i=1; i<[data count]; i++) {
        [self setTeamValue:team forHeader:[headers objectAtIndex:i] withValue:[data objectAtIndex:i] withProperties:_teamDataProperties];
    }
    //    NSLog(@"Team = %@", team);
    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        results = DB_ERROR;
    }
    return results;
}

-(void)setTeamValue:(TeamData *)team forHeader:header withValue:data withProperties:(NSDictionary *)properties {

    id value = [properties valueForKey:header];
    if (!value) {
        value = [self checkAlternateKeys:properties forEntry:header];
    }
    if ([value isKindOfClass:[NSRelationshipDescription class]]) {
        NSRelationshipDescription *destination = [value inverseRelationship];
        if ([destination.entity.name isEqualToString:@"TournamentData"]) {
            // Check to make sure that the tournament exists in the TournamentData db
            TournamentData *tournamentRecord = [[[TournamentDataInterfaces alloc] initWithDataManager:_dataManager] getTournament:data];
            if (tournamentRecord) {
                // NSLog(@"Found = %@", tournamentRecord.name);
                // Check to make sure this team does not already have this tournament
                NSArray *allTournaments = [team.tournament allObjects];
                NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", tournamentRecord.name];
                NSArray *list = [allTournaments filteredArrayUsingPredicate:pred];
                if (![list count]) {
                    // NSLog(@"Adding Tournament");
                    // NSLog(@"Team before T add = %@", team);
                    [team addTournamentObject:tournamentRecord];
                    // NSLog(@"Team after T add = %@", team);
                }
                else {
                    // NSLog(@"Tournament Exists, count = %d", [list count]);
                }
            }
        }
    }
    else if ([value isKindOfClass:[NSAttributeDescription class]]) {
        [self setAttributeValue:team forValue:data forAttribute:value];
    }
}

-(AddRecordResults)addTeamHistoryFromFile:(NSMutableArray *)headers dataFields:(NSMutableArray *)data {
    NSNumber *teamNumber;
    TeamData *team;
    AddRecordResults results = DB_ADDED;
    
    if (![data count]) return DB_ERROR;
    
    // For now, I am going to only allow it to work if the team number is in the first column
    // and the header is Team History
    if (![[headers objectAtIndex:0] isEqualToString:@"Team History"]) {
        return DB_ERROR;
    }
    teamNumber = [NSNumber numberWithInt:[[data objectAtIndex: 0] intValue]];
    team = [self getTeam:teamNumber];
    
    // Team doesn't exist, return error
    if (!team) return DB_ERROR;

    // NSLog(@"Team History for %@", teamNumber);
    NSString *week = [data objectAtIndex:1];

    // Week is not the first field after team number or is blank, return error
    if (!week || [week isEqualToString:@""]) return DB_ERROR;
        
    NSNumber *weekNumber = [NSNumber numberWithInt:[[data objectAtIndex: 1] intValue]];

    // Check to see if this regional data already exists in the db
    if ([self getRegionalRecord:team forWeek:weekNumber]) return DB_MATCHED;
    
    // Create the regional record and add the data to it.
    Regional *regionalRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Regional"
                                         inManagedObjectContext:_dataManager.managedObjectContext];
    // NSLog(@"Adding week = %@", weekNumber);
    regionalRecord.reg1 = [NSNumber numberWithInt:[weekNumber intValue]];
    NSDictionary *attributes = [[regionalRecord entity] attributesByName];
    for (int i=2; i<[data count]; i++) {
        [self setRegionalValue:regionalRecord forHeader:[headers objectAtIndex:i] withValue:[data objectAtIndex:i] withProperties:attributes];
    }
    // NSLog(@"Regional = %@", regionalRecord);

    [team addRegionalObject:regionalRecord];

    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
        results = DB_ERROR;
    }

    return results;
}

-(void)setRegionalValue:(Regional *)regional forHeader:(NSString *)header withValue:(NSString *)data withProperties:(NSDictionary *)properties {

    id value = [properties valueForKey:header];
    if (!value) {
        value = [self checkAlternateKeys:properties forEntry:header];
    }

    [self setAttributeValue:regional forValue:data forAttribute:value];
}

-(id)checkAlternateKeys:(NSDictionary *)keyList forEntry:header {
    for (NSString *item in keyList) {
        if( [item caseInsensitiveCompare:header] == NSOrderedSame ) {
            return [keyList valueForKey:item];
        }
        NSString *list = [[[keyList objectForKey:item] userInfo] objectForKey:@"key"];
        NSArray *allKeys = [list componentsSeparatedByString:@", "];
        for (int i=0; i<[allKeys count]; i++) {
            if( [[allKeys objectAtIndex:i] caseInsensitiveCompare:header] == NSOrderedSame ) {
                return [keyList valueForKey:item];
            }
        }
    }
    return NULL;
}

-(void)setAttributeValue:record forValue:data forAttribute:(id) attribute {
    NSAttributeType attributeType = [attribute attributeType];
    if (attributeType == NSInteger16AttributeType || attributeType == NSInteger32AttributeType || attributeType == NSInteger64AttributeType) {
        [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSFloatAttributeType || attributeType == NSDoubleAttributeType || attributeType == NSDecimalAttributeType) {
        [record setValue:[NSNumber numberWithFloat:[data floatValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSBooleanAttributeType) {
        [record setValue:[NSNumber numberWithInt:[data intValue]] forKey:[attribute name]];
    }
    else if (attributeType == NSStringAttributeType) {
        [record setValue:data forKey:[attribute name]];
    }
}

-(NSData *)packageTeamForXFer:(TeamData *)team {
    NSMutableArray *keyList = [NSMutableArray array];
    NSMutableArray *valueList = [NSMutableArray array];
    if (!_teamDataAttributes) _teamDataAttributes = [[team entity] attributesByName];
    for (NSString *item in _teamDataAttributes) {
        if ([team valueForKey:item] && [team valueForKey:item] != [[_teamDataAttributes valueForKey:item] valueForKey:@"defaultValue"]) {
            NSLog(@"%@ = %@, not equal to default = %@", item, [team valueForKey:item], [[_teamDataAttributes valueForKey:item] valueForKey:@"defaultValue"]);
            [keyList addObject:item];
            [valueList addObject:[team valueForKey:item]];
        }
    }

    NSArray *allTournaments = [team.tournament allObjects];
    NSMutableArray *tournamentNames = [NSMutableArray array];
    for (int i=0; i<[allTournaments count]; i++) {
        [tournamentNames addObject:[[allTournaments objectAtIndex:i] valueForKey:@"name"]];
    }
    [keyList addObject:@"tournament"];
    [valueList addObject:tournamentNames];

/*
    NSArray *allRegionals = [team.regional allObjects];
    NSMutableArray *regionalData = [NSMutableArray array];
    for (int i=0; i<[allRegionals count]; i++) {
        [tournamentNames addObject:[[allRegionals objectAtIndex:i] valueForKey:@"name"]];
    }
    [keyList addObject:allRegionals];
    [valueList addObject:[team valueForKey:@"regional"]];
*/
    NSArray *allPhotos = [team.photoList allObjects];
    if ([allPhotos count]) {
        NSMutableArray *photoDates = [NSMutableArray array];
        for (int i=0; i<[allPhotos count]; i++) {
            NSDate *date = [[allPhotos objectAtIndex:i] valueForKey:@"photoDate"];
            if (date) {
                [photoDates addObject:[[allPhotos objectAtIndex:i] valueForKey:@"photoDate"]];
            }
        }
        [keyList addObject:@"photoList"];
        [valueList addObject:photoDates];
    }
    NSDictionary *dictionary = [NSDictionary dictionaryWithObjects:valueList forKeys:keyList];
    NSData *myData = [NSKeyedArchiver archivedDataWithRootObject:dictionary];
    
    return myData;
}

-(TeamData *)unpackageTeamForXFer:(NSData *)xferData {
    NSDictionary *myDictionary = (NSDictionary*) [NSKeyedUnarchiver unarchiveObjectWithData:xferData];
    //     Assign unpacked data to the team record
    //     Return team record
    NSNumber *teamNumber = [myDictionary objectForKey:@"number"];
    if (!teamNumber) return nil;
    
    TeamData *teamRecord = [self getTeam:teamNumber];
    if (!teamRecord) {
        teamRecord = [NSEntityDescription insertNewObjectForEntityForName:@"TeamData"
                                             inManagedObjectContext:_dataManager.managedObjectContext];
        [teamRecord setValue:teamNumber forKey:@"number"];
    }
    // Create the property dictionary if it hasn't been created yet
    if (!_teamDataProperties) _teamDataProperties = [[teamRecord entity] propertiesByName];

    // Cycle through each object in the transfer data dictionary
    NSLog(@"unpackage team data add check for default values");
    for (NSString *key in myDictionary) {
        if ([key isEqualToString:@"number"]) continue; // We have already processed team number
        if ([key isEqualToString:@"primePhoto"]) continue; // The assetURL is not transferrable
        if ([key isEqualToString:@"primePhotoDate"]) {
            // Only do something with the prime photo date if there is not photo already
            if (!teamRecord.primePhoto && !teamRecord.primePhotoDate) {
                [teamRecord setValue:[myDictionary objectForKey:key] forKey:key];
                [self photoLookUp];
                NSLog(@"Enumerate to get the photo");
            }
            continue;
        }
        // if key is property, branch to photoList or tournamentList to decode
        id value = [_teamDataProperties valueForKey:key];
        if ([value isKindOfClass:[NSAttributeDescription class]]) {
            [teamRecord setValue:[myDictionary objectForKey:key] forKey:key];
        }
        else {   // This is a relationship property
            NSRelationshipDescription *destination = [value inverseRelationship];
            if ([destination.entity.name isEqualToString:@"TournamentData"]) {
                // NSLog(@"T dictionary = %@", [myDictionary objectForKey:key]);
                for (int i=0; i<[[myDictionary objectForKey:key] count]; i++) {
                    [self addTournamentToTeam:teamRecord forTournament:[[myDictionary objectForKey:key] objectAtIndex:i]];
                }
             }
            else if ([destination.entity.name isEqualToString:@"Photo"]) {
                [self syncPhotoList:teamRecord forSender:[myDictionary objectForKey:key]];
            }
        }
    }
    teamRecord.received = [NSNumber numberWithFloat:CFAbsoluteTimeGetCurrent()];

    NSError *error;
    if (![_dataManager.managedObjectContext save:&error]) {
        NSLog(@"Whoops, couldn't save: %@", [error localizedDescription]);
    }
    
    return teamRecord;
}

-(void)syncPhotoList:(TeamData *)destinationTeam forSender:(NSArray *)senderList {
    NSLog(@"Destination team = %@", destinationTeam.number);
    NSLog(@"Sender list = %@", [senderList objectAtIndex:0]);
    NSArray *allPhotos = [destinationTeam.photoList allObjects];
    if ([allPhotos count]) {
        Photo *photoRecord;
        for (int i=0; i<[senderList count]; i++) {
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"photoDate = %@", [senderList objectAtIndex:i]];
            NSArray *photo = [allPhotos filteredArrayUsingPredicate:pred];
            if ([photo count]) continue;
            photoRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:_dataManager.managedObjectContext];
            photoRecord.photoDate = [senderList objectAtIndex:i];
            [destinationTeam addPhotoListObject:photoRecord];
            NSLog(@"Add enumeration for transferred photo");
            [self photoLookUp];
        }
    }
    else {
        // There are no photos currently. Add them all
        for (int i=0; i<[senderList count]; i++) {
            Photo *photoRecord = [NSEntityDescription insertNewObjectForEntityForName:@"Photo" inManagedObjectContext:_dataManager.managedObjectContext];
            photoRecord.photoDate = [senderList objectAtIndex:i];
            [destinationTeam addPhotoListObject:photoRecord];
            NSLog(@"Add enumeration for transferred photo");
            [self photoLookUp];
        }
    }
}

-(void)photoLookUp {
    NSLog(@"Start photo look up");

  dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
      sleep(5);
/* UIImage * imageToSave = nil;
 UIImage * editedImage = (UIImage *)[info objectForKey:UIImagePickerControllerEditedImage];
 if (editedImage) imageToSave = editedImage;
 else imageToSave = (UIImage *)[info objectForKey:UIImagePickerControllerOriginalImage];
 
 UIImage * finalImageToSave = imageToSave;
 
 ALAssetsLibrary * assetsLibrary = [[ALAssetsLibrary alloc] init];
 [assetsLibrary writeImageToSavedPhotosAlbum:finalImageToSave.CGImage
 orientation:(ALAssetOrientation)finalImageToSave.imageOrientation
 completionBlock:nil];*/
 });
    NSLog(@"End photo look up");
}

-(void)addTournamentToTeam:(TeamData *)team forTournament:(NSString *)tournamentName {
    NSLog(@"Team = %@, Tourney = %@", team.number, tournamentName);
    // Check to make sure that the tournament exists in the TournamentData db
    TournamentData *tournamentRecord = [[[TournamentDataInterfaces alloc] initWithDataManager:_dataManager] getTournament:tournamentName];
    if (tournamentRecord) {
        // NSLog(@"Found = %@", tournamentRecord.name);
        // Check to make sure this team does not already have this tournament
        NSArray *allTournaments = [team.tournament allObjects];
        NSPredicate *pred = [NSPredicate predicateWithFormat:@"name = %@", tournamentRecord.name];
        NSArray *list = [allTournaments filteredArrayUsingPredicate:pred];
        if (![list count]) {
            // NSLog(@"Adding Tournament");
            // NSLog(@"Team before T add = %@", team);
            [team addTournamentObject:tournamentRecord];
            // NSLog(@"Team after T add = %@", team);
        }
        else {
            // NSLog(@"Tournament Exists, count = %d", [list count]);
        }
    }
}

-(Regional *)getRegionalRecord:(TeamData *)team forWeek:(NSNumber *)week {
    NSArray *regionalList = [team.regional allObjects];
    // Store the week in reg1 because I forgot to add a week spot in the database
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"reg1 = %@", week];
    NSArray *list = [regionalList filteredArrayUsingPredicate:pred];
    
    if ([list count]) return [list objectAtIndex:0];
    else return Nil;
}

-(TeamData *)getTeam:(NSNumber *)teamNumber {
    TeamData *team;
    
    // NSLog(@"Searching for team = %@", teamNumber);
    NSError *error;
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"number == %@", teamNumber];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if(!teamData) {
        NSLog(@"Karma disruption error");
        return Nil;
    }
    else {
        if([teamData count] > 0) {  // Team Exists
            team = [teamData objectAtIndex:0];
            // NSLog(@"Team %@ exists", team.number);
            return team;
        }
        else {
            return Nil;
        }
    }
}

-(NSArray *)getTeamListTournament:(NSString *)tournament {
    NSError *error;
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    // Add the search for tournament name
    NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament.name = %@",  tournament];
    [fetchRequest setPredicate:pred];
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    NSSortDescriptor *sortByNumber = [NSSortDescriptor sortDescriptorWithKey:@"number" ascending:YES];
    NSArray *sortedTeams = [teamData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sortByNumber]];
    return sortedTeams;
}

-(void)setTeamDefaults:(TeamData *)blankTeam {
    blankTeam.number = [NSNumber numberWithInt:0];
    blankTeam.name = @"";
    blankTeam.climbLevel = [NSNumber numberWithInt:-1];
    blankTeam.driveTrainType = [NSNumber numberWithInt:-1];
//    blankTeam.history = @"";
    blankTeam.intake = [NSNumber numberWithInt:-1];
//    blankTeam.climbSpeed = [NSNumber numberWithFloat:0.0];
    blankTeam.notes = @"";
    blankTeam.wheelDiameter = [NSNumber numberWithFloat:0.0];
    blankTeam.cims = [NSNumber numberWithInt:0];
    blankTeam.minHeight = [NSNumber numberWithFloat:0.0];
    blankTeam.maxHeight = [NSNumber numberWithFloat:0.0];
//    blankTeam.shooterHeight = [NSNumber numberWithFloat:0.0];
//    blankTeam.pyramidDump = [NSNumber numberWithInt:-1];
    blankTeam.saved = [NSNumber numberWithInt:0];
}

- (void)dealloc
{
    _dataManager = nil;
    _teamDataAttributes = nil;
    _teamDataProperties = nil;
    _regionalDictionary = nil;
#ifdef TEST_MODE
	NSLog(@"dealloc %@", self);

#endif
}

#ifdef TEST_MODE
-(void)testTeamInterfaces {
    NSLog(@"Testing Team Interfaces");
    NSError *error;
    if (!_dataManager) {
        _dataManager = [DataManager new];
    }
    
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription
                                   entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRequest setEntity:entity];
    NSSortDescriptor *numberDescriptor = [[NSSortDescriptor alloc] initWithKey:@"number" ascending:YES];
    NSArray *sortDescriptors = [[NSArray alloc] initWithObjects:numberDescriptor, nil];
    [fetchRequest setSortDescriptors:sortDescriptors];
    NSArray *teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];

    NSLog(@"Total Teams = %d", [teamData count]);
    NSSortDescriptor *sorter = [NSSortDescriptor sortDescriptorWithKey:@"driveTrainType" ascending:YES];
    teamData = [teamData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    
    int prev_int = -99;
    BOOL firstTime = TRUE;
    int counter = 0;
    for (int i=0; i<[teamData count]; i++) {
        int driveType = [[[teamData objectAtIndex:i] valueForKey:@"driveTrainType"] intValue];
        // NSLog(@"%d\t%d", i+1, driveType);
        if (driveType == prev_int) {
            counter++;
        }
        else {
            if (!firstTime) {
                NSLog(@"%d\tDrive Type = %d", counter, prev_int);
            }
            firstTime = FALSE;
            counter = 1;
            prev_int = driveType;
        }
    }
    NSLog(@"%d\tDrive Type = %d", counter, prev_int);

    sorter = [NSSortDescriptor sortDescriptorWithKey:@"intake" ascending:YES];
    teamData = [teamData sortedArrayUsingDescriptors:[NSArray arrayWithObject:sorter]];
    prev_int = -99;
    firstTime = TRUE;
    for (int i=0; i<[teamData count]; i++) {
        int intake = [[[teamData objectAtIndex:i] valueForKey:@"intake"] intValue];
        // NSLog(@"%d\t%d", i+1, intake);
        if (intake == prev_int) {
            counter++;
        }
        else {
            if (!firstTime) {
                NSLog(@"%d\tIntake Type = %d", counter, prev_int);
            }
            firstTime = FALSE;
            counter = 1;
            prev_int = intake;
        }
    }
    NSLog(@"%d\tIntake Type = %d", counter, prev_int);

    NSFetchRequest *fetchRegionals = [[NSFetchRequest alloc] init];
    NSEntityDescription *regionalEntity = [NSEntityDescription
                                             entityForName:@"Regional" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchRegionals setEntity:regionalEntity];
    NSArray *regionalData = [_dataManager.managedObjectContext executeFetchRequest:fetchRegionals error:&error];
    if (regionalData) NSLog(@"History records = %d", [regionalData count]);
    else NSLog(@"History records = 0");

    NSFetchRequest *fetchTournaments = [[NSFetchRequest alloc] init];
    NSEntityDescription *tournamentEntity = [NSEntityDescription
                                   entityForName:@"TournamentData" inManagedObjectContext:_dataManager.managedObjectContext];
    [fetchTournaments setEntity:tournamentEntity];
    NSArray *tournamentData = [_dataManager.managedObjectContext executeFetchRequest:fetchTournaments error:&error];
    
    if (tournamentData) {
        NSLog(@"Total Tournaments = %d", [tournamentData count]);
        for (int i=0; i<[tournamentData count]; i++) {
            NSString *tournament = [[tournamentData objectAtIndex:i] valueForKey:@"name"];
            entity = [NSEntityDescription entityForName:@"TeamData" inManagedObjectContext:_dataManager.managedObjectContext];
            [fetchRequest setEntity:entity];
            // Add the search for tournament name
            NSPredicate *pred = [NSPredicate predicateWithFormat:@"ANY tournament.name = %@",  tournament];
            [fetchRequest setPredicate:pred];
            teamData = [_dataManager.managedObjectContext executeFetchRequest:fetchRequest error:&error];
            if (teamData) NSLog(@"Teams in tournament %@ = %d", tournament, [teamData count]);
            else NSLog(@"Teams in tournament %@ = 0", tournament);
        }
    }
    else {
        NSLog(@"Total Tournaments = 0");
    }
    
}
#endif


@end
