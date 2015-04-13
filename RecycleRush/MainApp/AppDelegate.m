//
//  AppDelegate.m
// Robonauts Scouting
//
//  Created by FRC on 1/11/13.
//  Copyright (c) 2013 FRC. All rights reserved.
//

#import "AppDelegate.h"
#import "LoadCSVData.h"
#import "SettingsAndPreferences.h"
#import "DataManager.h"
#import "ConnectionUtility.h"
#import "FileIOMethods.h"
#import "SplashPageViewController.h"
#import "PhoneSplashViewController.h"
#import "TabletInputErrorViewController.h"

@interface TabletErrorSegue : UIStoryboardSegue
@end

@implementation TabletErrorSegue

- (void)perform {
    // our custom segue is being fired, push the tablet error view controller
    UINavigationController *sourceViewController = self.sourceViewController;
    TabletInputErrorViewController *destinationViewController = self.destinationViewController;
    [sourceViewController pushViewController:destinationViewController animated:YES];
}

@end

@interface AppDelegate()
@property (nonatomic, strong) TabletErrorSegue *tabletErrorSegue;

@end

@implementation AppDelegate

@synthesize window = _window;
@synthesize navigationController;
@synthesize splashPageViewController;
@synthesize phoneSplashViewController = _phoneSplashViewController;
@synthesize dataManager = _dataManager;
@synthesize loadDataFromBundle;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
//#define DEBUG_MODE
#ifdef DEBUG_MODE
    NSNotificationCenter *center = [NSNotificationCenter defaultCenter];
    [center addObserverForName:nil
                        object:nil
                         queue:nil
                    usingBlock:^(NSNotification *notification)
    {
        NSLog(@"%@, message = %@", notification.name, [notification userInfo]);
    }];
#endif

    NSLog(@"didFinishLaunchingWithOptions");
    BOOL inputError = FALSE;
    SettingsAndPreferences *settings = [[SettingsAndPreferences alloc] init];
    [settings initializeSettings];

    // Create the managed object and persistant store
    _dataManager = [[DataManager alloc] init];
    if (_connectionUtility == nil) {
        _connectionUtility = [[ConnectionUtility alloc] init:_dataManager];
    }
    [_connectionUtility autoConnect];
    LoadCSVData *loadData = [[LoadCSVData alloc] initWithDataManager:_dataManager];
    inputError = [loadData loadCSVDataFromBundle];
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if (url != nil && [url isFileURL]) {
        LoadCSVData *loadData = [LoadCSVData new];
        inputError |= [loadData handleOpenURL:url];
    }

    // Customization for different devices and iOS versions
    UIDevice *thisDevice = [UIDevice currentDevice];
    UIUserInterfaceIdiom *hardware = [thisDevice userInterfaceIdiom];
    float sysVersion = [[thisDevice systemVersion] floatValue];
    // Common to all devices and iOS versions
    navigationController = (UINavigationController *)self.window.rootViewController;
    self.navigationController.navigationBar.translucent = NO;
    [self.navigationController.navigationBar setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                           [UIColor colorWithRed:255.0/255.0 green:190.0/255.0 blue:0.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                                           [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],UITextAttributeTextShadowColor,
                                                           [NSValue valueWithUIOffset:UIOffsetMake(0, 1)],
                                                           UITextAttributeTextShadowOffset,
                                                           [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], UITextAttributeFont, nil]];
#ifdef __IPHONE_7_0
    if (sysVersion < 7) {
        // iOS 6
        [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
    }
    else {
        // iOS 7 and higher
        // Color of the navigation bar button text
        [[UIBarButtonItem appearance] setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:
                                                              [UIColor colorWithRed:255.0/255.0 green:190.0/255.0 blue:0.0/255.0 alpha:1.0], UITextAttributeTextColor,
                                                              [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8],UITextAttributeTextShadowColor,
                                                              [NSValue valueWithUIOffset:UIOffsetMake(2, 1)],
                                                              UITextAttributeTextShadowOffset,
                                                              [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:18.0], UITextAttributeFont, nil] forState:UIControlStateNormal];
        // The color of the entire navigation bar
        [[UINavigationBar appearance] setBarTintColor:[UIColor blackColor]];
        // The color of the arrow thingy for the back button
        [[UINavigationBar appearance] setTintColor:[UIColor colorWithRed:255.0/255.0 green:190.0/255.0 blue:0.0/255.0 alpha:1.0]];
    }
#else
    // iOS 6
    [[UINavigationBar appearance] setTintColor:[UIColor blackColor]];
#endif

    if (hardware == UIUserInterfaceIdiomPhone) {
        _phoneSplashViewController = (PhoneSplashViewController *)navigationController.topViewController;
        _phoneSplashViewController.dataManager = self.dataManager;
        _phoneSplashViewController.connectionUtility = self.connectionUtility;
    }
    else {
        splashPageViewController = (SplashPageViewController *)navigationController.topViewController;
        splashPageViewController.dataManager = self.dataManager;
        splashPageViewController.connectionUtility = self.connectionUtility;
        if (inputError) {
            TabletInputErrorViewController *errorViewController = [[self.navigationController storyboard] instantiateViewControllerWithIdentifier:@"TableInputErrorViewController"];
            [errorViewController setDataManager:_dataManager];
            self.tabletErrorSegue = [[TabletErrorSegue alloc] initWithIdentifier:@"TableInputErrorViewController"
                                                                          source:self.navigationController
                                                                     destination:errorViewController];
            [self.tabletErrorSegue perform];
        }
    }
    
    return YES;
}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url
 sourceApplication:(NSString *)sourceApplication
        annotation:(id)annotation {
    NSLog(@"openURL");
    if (url != nil && [url isFileURL]) {
        if (!_dataManager) {
            _dataManager = [[DataManager alloc] init];
        }
        if (_connectionUtility == nil) {
            _connectionUtility = [[ConnectionUtility alloc] init:_dataManager];
        }
        LoadCSVData *loadData = [[LoadCSVData alloc] initWithDataManager:_dataManager];
        BOOL inputError = [loadData handleOpenURL:url];
        SettingsAndPreferences *settings = [[SettingsAndPreferences alloc] init];
        [settings initializeSettings];
        if (inputError) {
            TabletInputErrorViewController *errorViewController = [[self.navigationController storyboard] instantiateViewControllerWithIdentifier:@"TableInputErrorViewController"];
            [errorViewController setDataManager:_dataManager];
            self.tabletErrorSegue = [[TabletErrorSegue alloc] initWithIdentifier:@"TableInputErrorViewController"
                                                                source:self.navigationController
                                                           destination:errorViewController];
            
            [self.tabletErrorSegue perform];
        }
    }
    NSLog(@"end of openurl");
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Resign active");
    [_dataManager saveContext];
    [_connectionUtility disconnectOnResign];
    
   // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
    NSLog(@"Enter background");
    [_dataManager saveContext];
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
    NSLog(@"Enter Foreground");
    [_connectionUtility autoConnect];
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application
{
    NSLog(@"Did Terminate");
    // Saves changes in the application's managed object context before the application terminates.
    [_dataManager saveContext];
}

@end
