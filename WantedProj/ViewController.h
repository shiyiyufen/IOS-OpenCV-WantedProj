//
//  ViewController.h
//  WantedProj
//
//  Created by JD_Acorld on 14-8-2.
//  Copyright (c) 2014年 hxy. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <opencv2/highgui/ios.h>
@interface ViewController : UIViewController<CvPhotoCameraDelegate>
{
    CvPhotoCamera* photoCamera;
    UIImageView* resultView;
}

@property (nonatomic, strong) CvPhotoCamera* photoCamera;

@property (weak, nonatomic) IBOutlet UIImageView *adImageView;

@property (weak, nonatomic) IBOutlet UIButton *huntBtn;
- (IBAction)goSetting:(id)sender;

- (IBAction)huntNow:(id)sender;
@end
