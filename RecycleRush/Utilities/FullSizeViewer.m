//
//  FullSizeViewer.m
//  RecycleRush
//
//  Created by FRC on 2/8/14.
//  Copyright (c) 2014 FRC. All rights reserved.
//

#import "FullSizeViewer.h"

@interface FullSizeViewer ()

@end

@implementation FullSizeViewer {
    UIImageView *imageView;
    UIImage *originalImage;
    UIImageOrientation originalOrientation;
    CGRect viewSize;
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
    if (_fullImage) {
        originalImage = _fullImage;
    }
    else if (_imagePath) {
        originalImage = [UIImage imageWithContentsOfFile:_imagePath];
    }
    originalOrientation = originalImage.imageOrientation;
    imageView.contentMode = UIViewContentModeScaleAspectFit;
    // [self.view setBackgroundColor:[UIColor redColor]];
    // [imageView setBackgroundColor:[UIColor greenColor]];
    [self.view addSubview:imageView];
}

- (void)viewWillLayoutSubviews {
    viewSize = self.view.frame;
    viewSize.origin.x = 0.0;
    viewSize.origin.y = 0.0;
    viewSize.size.height = viewSize.size.height-45.0;
    [imageView setFrame:viewSize];
    //NSLog(@"viewWillLayoutSubviews");
    imageView.image = [[UIImage alloc] initWithCGImage: originalImage.CGImage
                                                 scale: 1.0
                                           orientation: originalOrientation];
    if (UIInterfaceOrientationIsLandscape(self.interfaceOrientation)) {
        //NSLog(@"Landscape");
        switch (originalOrientation) {
            case UIImageOrientationRight:
                imageView.image = [[UIImage alloc] initWithCGImage: originalImage.CGImage
                                                           scale: 1.0
                                                     orientation: UIImageOrientationUp];
                //NSLog(@"rotating");
                break;
                
            default:
                break;
        }
    }
    else {
        //NSLog(@"Portrait");
        switch (imageView.image.imageOrientation) {
            case UIImageOrientationUp:
                imageView.image = [[UIImage alloc] initWithCGImage: originalImage.CGImage
                                                             scale: 1.0
                                                       orientation: UIImageOrientationRight];
                //NSLog(@"rotating");
                break;
            case UIImageOrientationDown:
                imageView.image = [[UIImage alloc] initWithCGImage: originalImage.CGImage
                                                             scale: 1.0
                                                       orientation: UIImageOrientationRight];
                //NSLog(@"rotating");
                break;
                
            default:
                break;
        }
    }
    // NSLog(@"original orientation = %d", originalOrientation);
    // NSLog(@"size = %lf, %lf, %lf, %lf", viewSize.origin.x, viewSize.origin.y, viewSize.size.width, viewSize.size.height);

}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
    _fullImage = nil;
}

@end
