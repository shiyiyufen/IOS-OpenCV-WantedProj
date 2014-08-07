//
//  ViewController.m
//  WantedProj
//
//  Created by JD_Acorld on 14-8-2.
//  Copyright (c) 2014年 hxy. All rights reserved.
//

#import "ViewController.h"
#import "HuntViewController.h"
#import "SettingViewController.h"
#import <QuartzCore/QuartzCore.h>

//#define  TEST 1
@interface ViewController ()

@end

@implementation ViewController

@synthesize photoCamera;

#pragma mark -
#pragma -mark ==== LifeCircle ====
#pragma mark -

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.huntBtn.layer.masksToBounds = YES;
    self.huntBtn.layer.cornerRadius = 5.0f;
    
    // Initialize camera
    photoCamera = [[CvPhotoCamera alloc]
                   initWithParentView:_adImageView];
    photoCamera.imageWidth = _adImageView.frame.size.width;
    photoCamera.imageHeight = _adImageView.frame.size.height;
    photoCamera.delegate = self;
    photoCamera.defaultAVCaptureDevicePosition =
    AVCaptureDevicePositionBack;
    photoCamera.defaultAVCaptureSessionPreset =
    AVCaptureSessionPresetPhoto;
    photoCamera.defaultAVCaptureVideoOrientation =
    AVCaptureVideoOrientationPortrait;
    
    UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.frame];
    imageView.tag = 10;
    imageView.image = [UIImage imageNamed:@"ad.png"];
    [self.view addSubview:imageView];
    
    [imageView.superview sendSubviewToBack:imageView];
    [_adImageView.superview sendSubviewToBack:_adImageView];
	// Do any additional setup after loading the view, typically from a nib.
}


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    _adImageView.hidden = YES;
    [self.navigationController setNavigationBarHidden:YES];
    
    BOOL isFront = [[XYTool sharedXYTool] cameraIsFront];
    photoCamera.defaultAVCaptureDevicePosition =  isFront ? AVCaptureDevicePositionFront : AVCaptureDevicePositionBack;
}

- (void)viewDidDisappear:(BOOL)animated
{
    [photoCamera stop];
    self.huntBtn.selected = NO;
}

- (void)dealloc
{
    photoCamera.delegate = nil;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma -mark ==== Views ====
#pragma mark -

- (UIView *)adsView
{
    return [self.view viewWithTag:10];
}

#pragma mark -
#pragma -mark ==== Action ====
#pragma mark -

- (void)skipToNextPageWithImage:(UIImage *)image
{
    HuntViewController *hunt = [[HuntViewController alloc] init];
    hunt.image = image;
    [self.navigationController pushViewController:hunt animated:YES];
}


- (IBAction)goSetting:(id)sender
{
    SettingViewController *set = [[SettingViewController alloc] init];
    [self.navigationController pushViewController:set animated:YES];
}

- (IBAction)huntNow:(UIButton *)sender
{
    
#ifdef TEST
    [self skipToNextPageWithImage:nil];
    return;
#endif
    
    if (sender.isSelected)
    {
        [photoCamera takePicture];
    }else
    {
        _adImageView.hidden = NO;
        [[self adsView].superview sendSubviewToBack:[self adsView]];
        [photoCamera start];
        [sender setSelected:YES];
    }
}

#pragma mark -
#pragma -mark ==== CvPhotoCameraDelegate ====
#pragma mark -

- (void)photoCamera:(CvPhotoCamera*)camera
      capturedImage:(UIImage *)image;
{
    [camera stop];
    CGImageRef cgimg = CGImageCreateWithImageInRect([image CGImage],_adImageView.frame);
    UIImage *target = [UIImage imageWithCGImage:cgimg];

    [self skipToNextPageWithImage:target];
}

- (void)photoCameraCancel:(CvPhotoCamera*)camera;
{
    //cancel
}


@end
