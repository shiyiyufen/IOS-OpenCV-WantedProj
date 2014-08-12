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

- (void)image:(UIImage *)image didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInfo

{
    
    NSString *msg = nil;
    
    if(error != NULL)
        
    {
        
        msg = @"保存图片失败";
        
    }
    
    else
        
    {
        
        msg = @"保存图片成功";
        
    }
    
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"保存图片结果提示"
                          
                                                    message:msg
                          
                                                   delegate:self
                          
                                          cancelButtonTitle:@"确定"
                          
                                          otherButtonTitles:nil];
    
    [alert show];
    
}

- (void)photoCamera:(CvPhotoCamera*)camera
      capturedImage:(UIImage *)image;
{
    [camera stop];
    
//    UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
    CGFloat fSmallImgWidth = 300.0f;
    
    BOOL bIsRotate = NO;
    switch (image.imageOrientation)
    {
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        {
            bIsRotate = NO;
            //            NSLog(@"UP [%d]", image.imageOrientation);
        }
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        {
            bIsRotate = YES;
            //            NSLog(@"LEFT [%d]", image.imageOrientation);
        }
            break;
        default:
            break;
    }
    
    CGFloat byte = (float)image.size.width / 320;
    CGFloat byteHeight = image.size.height / byte;
    UIWindow *window = [[UIApplication sharedApplication] keyWindow];
    CGFloat byteOrginY = (byteHeight - _adImageView.frame.size.height) / 2;
    
    CGRect rcSubRect;
    rcSubRect.origin.x = (!bIsRotate ? _adImageView.frame.origin.x : (byteHeight - _adImageView.bounds.size.height) / 2) * byte;
    rcSubRect.origin.y = (!bIsRotate ? (byteHeight - _adImageView.bounds.size.height) / 2 : _adImageView.frame.origin.x) * byte;
    rcSubRect.size.width = _adImageView.frame.size.width * byte;
    rcSubRect.size.height = rcSubRect.size.width;
    
    CGImageRef subImageRef = CGImageCreateWithImageInRect(image.CGImage, rcSubRect);
    CGRect smallBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(smallBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, smallBounds, subImageRef);
    UIImage* smallImage = [UIImage imageWithCGImage:subImageRef scale:1.0f orientation:image.imageOrientation];
    UIGraphicsEndImageContext();
    
    CGFloat objectWidth = !bIsRotate ? smallBounds.size.width : smallBounds.size.height;
    CGFloat objectHeight = !bIsRotate ? smallBounds.size.height : smallBounds.size.width;
    CGFloat scaledHeight = floorf(objectHeight / (objectWidth / fSmallImgWidth));
    CGSize newSize = CGSizeMake(fSmallImgWidth, scaledHeight);
    UIGraphicsBeginImageContext(newSize);
    // Tell the old image to draw in this new context, with the desired
    // new size
    [smallImage drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Get the new image from the context
    UIImage* newImage = UIGraphicsGetImageFromCurrentImageContext();
    // End the context
    UIGraphicsEndImageContext();
    
//    CGFloat byte = (float)image.size.width / 320.0;
//    
//    CGRect imageRect = CGRectMake(_adImageView.frame.origin.x    * byte,
//                                  _adImageView.frame.origin.y    * byte,
//                                  _adImageView.frame.size.width  * byte,
//                                  _adImageView.frame.size.height * byte);
//    
//    CGImageRef imageRef = CGImageCreateWithImageInRect([image CGImage], imageRect);
//    UIImage *result1 = [UIImage imageWithCGImage:imageRef];
//    UIImage *result = [UIImage imageWithCGImage:imageRef
//                                          scale:image.scale
//                                    orientation:image.imageOrientation];
//    CGImageRelease(imageRef);

    [self skipToNextPageWithImage:newImage];
}

- (void)photoCameraCancel:(CvPhotoCamera*)camera;
{
    //cancel
}


@end
