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
    
    items_ = @[@"臭爆了",@"长相太耗内存",@"太磕碜",@"被猪亲过",@"长相原始",@"太粗糙"];
    
    [self.navigationController setNavigationBarHidden:YES animated:YES];
    
    _printerImageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
    [self.view addSubview:_printerImageView];
    
    PostcardPrinter::Parameters params;
    
    // Load image with face
    UIImage* image = nil;
    if (self.image == NULL)
    {
        self.image = [UIImage imageNamed:@"lena.jpg"];
    }
    image = [self.image rescaleImageToSize:CGSizeMake(512, 512)];
    
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
        _printerImageView.image = MatToUIImage(postcard);
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

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    [self.navigationController setNavigationBarHidden:!self.navigationController.navigationBarHidden animated:YES];
}

@end
