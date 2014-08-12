//
//  SettingViewController.m
//  WantedProj
//
//  Created by JD_Acorld on 14-8-4.
//  Copyright (c) 2014年 hxy. All rights reserved.
//

#import "SettingViewController.h"
#import <opencv2/highgui/ios.h>
#import "XYTool.h"
@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource,UINavigationControllerDelegate, UIImagePickerControllerDelegate>
{
    cv::CascadeClassifier faceDetector;
}
@end

@implementation SettingViewController

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
    NSString* cascadePath = [[NSBundle mainBundle]
                             pathForResource:@"haarcascade_frontalface_alt"
                             ofType:@"xml"];
    faceDetector.load([cascadePath UTF8String]);
    self.title = @"设置";
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)showAlertViewWithText:(NSString *)text tag:(NSUInteger)tag
{
    UIAlertView *notesView = [[UIAlertView alloc] initWithTitle:@"警告" message:text delegate:nil cancelButtonTitle:@"重试" otherButtonTitles:nil, nil];
    notesView.tag = tag;
    [notesView show];
}

#pragma mark -
#pragma -mark ==== Method ====
#pragma mark -

//打开相机
-(void)addCarema
{
    //判断是否可以打开相机，模拟器此功能无法使用
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        
        UIImagePickerController * picker = [[UIImagePickerController alloc]init];
        picker.delegate = self;
        picker.allowsEditing = YES;  //是否可编辑
        picker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        //摄像头
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self presentViewController:picker animated:YES completion:^{
            [[UIApplication sharedApplication] setStatusBarHidden:YES];
        }];
    }else{
        //如果没有提示用户
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"你没有摄像头" delegate:nil cancelButtonTitle:@"Drat!" otherButtonTitles:nil];
        [alert show];
    }
}

- (void)didSwitchCameraDirection:(UISwitch *)s
{
    [[XYTool sharedXYTool] setCameraFront:s.on];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma -mark ==== Face detector ====
#pragma mark -

- (UIImage *)faceDetector:(UIImage *)targetImage
{
    //Load image with face
    UIImage* image = targetImage;
    cv::Mat faceImage;
    UIImageToMat(image, faceImage);
    
    // Convert to grayscale
    cv::Mat gray;
    cvtColor(faceImage, gray, CV_BGR2GRAY);
    
    // Detect faces
    std::vector<cv::Rect> faces;
    faceDetector.detectMultiScale(gray, faces, 1.1,
                                  2, 0|CV_HAAR_SCALE_IMAGE, cv::Size(30, 30));
    
    cv::Rect someface;
    // Draw all detected faces
    for(unsigned int i = 0; i < faces.size(); i++)
    {
        const cv::Rect& face = faces[i];
        someface = face;
        // Get top-left and bottom-right corner points
//        cv::Point tl(face.x, face.y);
//        cv::Point br = tl + cv::Point(face.width, face.height);
//        
//        // Draw rectangle around the face
//        cv::Scalar magenta = cv::Scalar(255, 0, 255);
//        cv::rectangle(faceImage, tl, br, magenta, 4, 8, 0);
    }
    
    //面部
    UIImage *result = MatToUIImage(faceImage);
    CGImageRef cgimg = CGImageCreateWithImageInRect([result CGImage], CGRectMake(someface.x, someface.y, someface.width, someface.height));
    UIImage *target = [UIImage imageWithCGImage:cgimg];
    
    CGImageRelease(cgimg);//用完一定要释放，否则内存泄露
    
    return target;
}

#pragma mark -
#pragma -mark ==== Camera Delegate ====
#pragma mark -

//拍摄完成后要执行的方法
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    //得到图片
    UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
    CGFloat fSmallImgWidth = 320.0f;
    
    BOOL bIsRotate = NO;
    switch (image.imageOrientation)
    {
        case UIImageOrientationUp:
        case UIImageOrientationDown:
        case UIImageOrientationUpMirrored:
        case UIImageOrientationDownMirrored:
        {
            bIsRotate = NO;
        }
            break;
        case UIImageOrientationLeft:
        case UIImageOrientationRight:
        case UIImageOrientationLeftMirrored:
        case UIImageOrientationRightMirrored:
        {
            bIsRotate = YES;
        }
            break;
        default:
            break;
    }
    
    CGRect rcSubRect;
    rcSubRect.origin.x = !bIsRotate ? image.size.width/8 : image.size.height/8;
    rcSubRect.origin.y = !bIsRotate ? image.size.height/8 : image.size.width/8;
    rcSubRect.size.width = !bIsRotate ? (image.size.width - image.size.width/4) : (image.size.height - image.size.height/4);
    rcSubRect.size.height = !bIsRotate ? (image.size.height - image.size.height/4) : (image.size.width - image.size.width/4);
    
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
    
    //图片存入相册
    UIImage *face = [self faceDetector:newImage];
    if (nil == face)
    {
        [self showAlertViewWithText:@"你这也叫脸？" tag:0];
    }else
    {
        [[XYTool sharedXYTool] saveFace:face];
        [self.tableView reloadData];
    }
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
    
}

//点击Cancel按钮后执行方法
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [self dismissViewControllerAnimated:YES completion:^{
        [[UIApplication sharedApplication] setStatusBarHidden:NO];
    }];
}

#pragma mark -
#pragma -mark ==== TableView Delegate & DataSource ====
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    switch (row) {
        case 0:
        {
            BOOL isFront = [[XYTool sharedXYTool] cameraIsFront];
            cell.textLabel.text = [NSString stringWithFormat:@"摄像头方向:%@",isFront ? @"前置摄像头" : @"后置摄像头"];
            UISwitch *s = [[UISwitch alloc] initWithFrame:(CGRect){0,0,51,31}];
            [s addTarget:self action:@selector(didSwitchCameraDirection:) forControlEvents:UIControlEventValueChanged];
            s.on = isFront;
            cell.accessoryView = s;
            break;
        }
        case 1:
        {
            UIImage *image = [[XYTool sharedXYTool] savedFace];
            if (image)
            {
                cell.imageView.image = image;
                cell.textLabel.textColor = [UIColor blueColor];
                cell.textLabel.text = @"您可以更换自己的头像";
            }else
            {
                cell.textLabel.textColor = [UIColor blackColor];
                cell.textLabel.text = @"请设置自己的头像";
            }
            
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    switch (row) {
        case 1:
        {
            NSLog(@"11 %@",@"11");
            [self addCarema];
            break;
        }
        default:
            break;
    }
}

@end
