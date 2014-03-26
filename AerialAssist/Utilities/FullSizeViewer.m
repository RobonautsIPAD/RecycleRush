//
//  FullSizeViewer.m
//  AerialAssist
//
//  Created by FRC on 2/8/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "FullSizeViewer.h"

@interface FullSizeViewer ()

@end

@implementation FullSizeViewer {
    UIImageView *imageView;
    CGRect portrait;
    CGRect landscape;
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
    imageView =  [[UIImageView alloc] init];
    portrait = [[UIScreen mainScreen] bounds];
    landscape = portrait;
    landscape.size.height = portrait.size.width;
    landscape.size.width = portrait.size.height;
    UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
    if (orientation == UIDeviceOrientationPortrait || orientation == UIDeviceOrientationPortraitUpsideDown) {
        [imageView setFrame:portrait];
    }
    else {
        [imageView setFrame:landscape];
    }
    imageView.image = _fullImage;
//    imageView.contentMode = UIViewContentModeScaleAspectFill;//UIViewContentModeScaleAspectFit;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    [self.view setBackgroundColor:[UIColor greenColor]];
    [imageView setBackgroundColor:[UIColor redColor]];

  [self.view addSubview:imageView];
}

-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    switch (interfaceOrientation) {
        case UIInterfaceOrientationPortrait:
        case UIInterfaceOrientationPortraitUpsideDown:
            [imageView setFrame:portrait];
            break;
        case UIInterfaceOrientationLandscapeLeft:
        case UIInterfaceOrientationLandscapeRight:
            [imageView setFrame:portrait];
            break;
        default:
            break;
    }
    // Return YES for supported orientations
	return YES;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
