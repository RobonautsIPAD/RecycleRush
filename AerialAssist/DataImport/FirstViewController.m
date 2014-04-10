//
//  FirstViewController.m
//  AerialAssist
//
//  Created by FRC on 3/12/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "FirstViewController.h"
#import "DataManager.h"

@interface FirstViewController ()
@property (strong, nonatomic) IBOutlet UIWebView *viewWeb;
@property (strong, nonatomic) IBOutlet UIButton *btnNewParser;

@end

@implementation FirstViewController

- (id)initWithDataManager:(DataManager *)initManager {
	if ((self = [super init]))
	{
        _dataManager = initManager;
	}
	return self;
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
	// Do any additional setup after loading the view.
    NSString *fullURL = @"http://www2.usfirst.org/2014comp/events/TXHO/scheduleelim.html";
    NSURL *url = [NSURL URLWithString:fullURL];
    NSURLRequest *requestObj = [NSURLRequest requestWithURL:url];
    [_viewWeb loadRequest:requestObj];
    NSError *error;
    NSString *pageSource = [NSString stringWithContentsOfURL:url
                                                    encoding:NSASCIIStringEncoding
                                                       error:&error];
    //NSLog(@"%@", pageSource);
    NSString *exportFilePath = [[self applicationDocumentsDirectory] stringByAppendingPathComponent:@"Match Schedule.html"];
    [pageSource writeToFile:exportFilePath
                atomically:YES
                  encoding:NSUTF8StringEncoding
                     error:nil];

}


- (void) prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    [segue.destinationViewController setDataManager:_dataManager];
}

/**
 Returns the path to the application's Documents directory.
 */
- (NSString *)applicationDocumentsDirectory {
	return [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
