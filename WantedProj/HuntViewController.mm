//
//  HuntViewController.m
//  WantedProj
//
//  Created by JD_Acorld on 14-8-2.
//  Copyright (c) 2014年 hxy. All rights reserved.
//

#import "HuntViewController.h"
#import "PostcardPrinter.hpp"
#import "opencv2/highgui/ios.h"
#import "RTLabel.h"
#import "Utility.h"
@interface UIImage (Scale)
- (UIImage *)rescaleImageToSize:(CGSize)size;
@end

@implementation UIImage(Scale)

- (UIImage *)rescaleImageToSize:(CGSize)size
{
	CGRect rect = CGRectMake(0.0, 0.0, size.width, size.height);
	UIGraphicsBeginImageContext(rect.size);
	[self drawInRect:rect];  // scales image to rect
	UIImage *resImage = UIGraphicsGetImageFromCurrentImageContext();
	UIGraphicsEndImageContext();
	return resImage;
}

@end

@interface HuntViewController ()
{
    NSArray *items_;
    cv::CascadeClassifier faceDetector;
}
@property (nonatomic, strong) RTLabel *label;
@property (nonatomic, strong) UIImageView *printerImageView;
@end

@implementation HuntViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self config];
    
    if ([self compare])
    {
        //绘制好的东西
    }else
    {
        //通缉
        [self drawCriminal];
    }
}

- (void)config
{
    items_ = @[@"臭爆了",@"长相太耗内存",@"太磕碜",@"被猪亲过",@"长相原始",@"太粗糙"];
    if (self.image == NULL)
    {
        self.image = [UIImage imageNamed:@"lena.jpg"];
    }
    NSString* cascadePath = [[NSBundle mainBundle]
                             pathForResource:@"haarcascade_frontalface_alt"
                             ofType:@"xml"];
    faceDetector.load([cascadePath UTF8String]);
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    self.view.backgroundColor = [UIColor whiteColor];
}

- (UIImageView *)printerImageView
{
    if (_printerImageView == NULL)
    {
        _printerImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
        [self.view addSubview:_printerImageView];
    }
    return _printerImageView;
}

#pragma mark -
#pragma -mark ==== 绘制罪犯 ====
#pragma mark -

- (void)drawCriminal
{
    PostcardPrinter::Parameters params;
    
    // Load image with face
    UIImage* image = [self.image rescaleImageToSize:CGSizeMake(512, 512)];
    
    // Convert to grayscale
    UIImageToMat(image, params.face);
    
    // Load image with texture
    image = [UIImage imageNamed:@"texture.jpg"];
    UIImageToMat(image, params.texture);
    cvtColor(params.texture, params.texture, CV_RGBA2RGB);
    
    // Load image with text
    image = [UIImage imageNamed:@"text.png"];
    UIImageToMat(image, params.text, true);
    
    // Create PostcardPrinter class
    PostcardPrinter postcardPrinter(params);
    
    // Print postcard, and measure printing time
    cv::Mat postcard;
    int64 timeStart = cv::getTickCount();
    postcardPrinter.print(postcard);
    int64 timeEnd = cv::getTickCount();
    float durationMs =
    1000.f * float(timeEnd - timeStart) / cv::getTickFrequency();
    NSLog(@"Printing time = %.3fms", durationMs);
    
    if (!postcard.empty())
    {
//        _printerImageView.image = MatToUIImage(postcard);
    }
    
    [self drawText];
}

- (void)drawText
{
    _label = [[RTLabel alloc] initWithFrame:(CGRect){20,self.view.bounds.size.height * 3 / 4 - 30,280,100}];
    _label.textAlignment = RTTextAlignmentCenter;
    _label.font = [UIFont boldSystemFontOfSize:18];
    int index = rand() % 6;
    NSString *text = items_[index];
    _label.text = [NSString stringWithFormat:@"<font size=14 weight:bold>囚犯因</font><font size=18 color='#d72127'> %@ </font><font size=14>犯罪在逃，现全球通缉。各缔约国警方应全力协助，同时对提供线索，缉拿有功者给予 </font><font size=18 color='#f8e23d'> %@ </font><font size=14>元奖励，特此公告！</font>",text,@"2000W"];
    [self.view addSubview:_label];
    self.title = text;
}

#pragma mark -
#pragma -mark ==== 头像检索和匹配 ====
#pragma mark -

- (BOOL)compare
{
    UIImage *orgin = [self faceDetector:self.image];
    UIImage *target = [UIImage imageNamed:@"avatar.png"];
    if (orgin && target)
    {
        IplImage *img1 = [Utility CreateIplImageFromUIImage:orgin];
        IplImage *img2 = [Utility CreateIplImageFromUIImage:target];
        int result = CompareHist(img1, img2);
        NSLog(@"Two image is equal: %@",result ? @"YES" : @"NO");
        return result;
    }
    return NO;
}

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
        cv::Point tl(face.x, face.y);
        cv::Point br = tl + cv::Point(face.width, face.height);
        
        // Draw rectangle around the face
        cv::Scalar magenta = cv::Scalar(255, 0, 255);
        cv::rectangle(faceImage, tl, br, magenta, 4, 8, 0);
    }
    
    //面部
    CGImageRef cgimg = CGImageCreateWithImageInRect([image CGImage], CGRectMake(someface.x, someface.y, someface.width, someface.height));
    UIImage *target = [UIImage imageWithCGImage:cgimg];
//    self.avatarImageView.image = target;
    CGImageRelease(cgimg);//用完一定要释放，否则内存泄露
    // Show resulting image
    self.printerImageView.image = MatToUIImage(faceImage);
    return target;
}

//画直方图用
int HistogramBins = 256;
float HistogramRange1[2]={0,255};
float *HistogramRange[1]={&HistogramRange1[0]};
int CompareHist(IplImage* image1, IplImage* image2)
{
    IplImage* srcImage;
    IplImage* targetImage;
    if (image1->nChannels != 1) {
        srcImage = cvCreateImage(cvSize(image1->width, image1->height), image1->depth, 1);
        cvCvtColor(image1, srcImage, CV_BGR2GRAY);
    } else {
        srcImage = image1;
    }
    
    if (image2->nChannels != 1) {
        targetImage = cvCreateImage(cvSize(image2->width, image2->height), srcImage->depth, 1);
        cvCvtColor(image2, targetImage, CV_BGR2GRAY);
    } else {
        targetImage = image2;
    }
    
    CvHistogram *Histogram1 = cvCreateHist(1, &HistogramBins, CV_HIST_ARRAY,HistogramRange);
    CvHistogram *Histogram2 = cvCreateHist(1, &HistogramBins, CV_HIST_ARRAY,HistogramRange);
    
    cvCalcHist(&srcImage, Histogram1);
    cvCalcHist(&targetImage, Histogram2);
    
    cvNormalizeHist(Histogram1, 1);
    cvNormalizeHist(Histogram2, 1);
    
    // CV_COMP_CHISQR,CV_COMP_BHATTACHARYYA这两种都可以用来做直方图的比较，值越小，说明图形越相似
    double chisqr = cvCompareHist(Histogram1, Histogram2, CV_COMP_CHISQR);
    double bhattacharyya = cvCompareHist(Histogram1, Histogram2, CV_COMP_BHATTACHARYYA);
    printf("CV_COMP_CHISQR : %.4f\n", chisqr);
    printf("CV_COMP_BHATTACHARYYA : %.4f\n", cvCompareHist(Histogram1, Histogram2, bhattacharyya));
    
    
    // CV_COMP_CORREL, CV_COMP_INTERSECT这两种直方图的比较，值越大，说明图形越相似
    double correl = cvCompareHist(Histogram1, Histogram2, CV_COMP_CORREL);
    double intersect = cvCompareHist(Histogram1, Histogram2, CV_COMP_INTERSECT);
    
    printf("CV_COMP_CORREL : %.4f\n", correl);
    printf("CV_COMP_INTERSECT : %.4f\n", intersect);
    
    cvReleaseHist(&Histogram1);
    cvReleaseHist(&Histogram2);
    if (image1->nChannels != 1) {
        cvReleaseImage(&srcImage);
    }
    if (image2->nChannels != 1) {
        cvReleaseImage(&targetImage);
    }
    
    if (chisqr + bhattacharyya < 0.2 && correl + intersect > 1.8)
    {
        return 1;
    }
    return 0;
}

#pragma mark -
#pragma -mark ==== Touch ====
#pragma mark -

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

@end
