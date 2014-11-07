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
#import "SplashPageViewController.h"
#import "PhoneSplashViewController.h"
#import "TeamDataInterfaces.h"

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
    SettingsAndPreferences *settings = [[SettingsAndPreferences alloc] init];
    [settings initializeSettings];

    // Create the managed object and persistant store
    _dataManager = [[DataManager alloc] init];
    LoadCSVData *loadData = [[LoadCSVData alloc] initWithDataManager:_dataManager];
    [loadData loadCSVDataFromBundle];
    
    navigationController = (UINavigationController *)self.window.rootViewController;
    
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];

    if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
        _phoneSplashViewController = (PhoneSplashViewController *)navigationController.topViewController;
        _phoneSplashViewController.dataManager = self.dataManager;
    }
    else {
        splashPageViewController = (SplashPageViewController *)navigationController.topViewController;
        splashPageViewController.dataManager = self.dataManager;
    }
    
    NSURL *url = (NSURL *)[launchOptions valueForKey:UIApplicationLaunchOptionsURLKey];
    if (url != nil && [url isFileURL]) {
        LoadCSVData *loadData = [LoadCSVData new];
        [loadData handleOpenURL:url];
    }
    
    return YES;

}

-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url 
 sourceApplication:(NSString *)sourceApplication 
        annotation:(id)annotation {    
    NSLog(@"openURL");
    if (url != nil && [url isFileURL]) {
        NSLog(@"data manager = %@", _dataManager);
        if (!_dataManager) {
            _dataManager = [[DataManager alloc] init];
        }
        LoadCSVData *loadData = [[LoadCSVData alloc] initWithDataManager:_dataManager];
        [loadData handleOpenURL:url];
        SettingsAndPreferences *settings = [[SettingsAndPreferences alloc] init];
        [settings initializeSettings];
    }
    NSLog(@"end of openurl");
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
    NSLog(@"Resign active");
    [_dataManager saveContext];
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

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

@end
