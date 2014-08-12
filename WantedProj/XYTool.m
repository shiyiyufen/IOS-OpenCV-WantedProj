//
//  XYTool.m
//  WantedProj
//
//  Created by JD_Acorld on 14-8-4.
//  Copyright (c) 2014年 hxy. All rights reserved.
//

#import "XYTool.h"
#define DEFAULTS [NSUserDefaults standardUserDefaults]
#define CarmeraDirection @"CarmeraDirection"
#define FaceKey @"face"

@implementation XYTool
+ (XYTool *)sharedXYTool
{
    static XYTool *tool_ = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        tool_ = [[XYTool alloc] init];
    });
    return tool_;
}


- (BOOL)cameraIsFront
{
    NSUserDefaults *defaults = DEFAULTS;
    return [defaults boolForKey:CarmeraDirection];
}

- (void)setCameraFront:(BOOL)front
{
    NSUserDefaults *defaults = DEFAULTS;
    [defaults setBool:front forKey:CarmeraDirection];
    [defaults synchronize];
}

- (void)saveFace:(UIImage *)face
{
    if (NULL == face) return;
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"avatar.png"] ;
    NSData *data = UIImagePNGRepresentation(face);
    if([data writeToFile:path atomically:YES])
   {
       NSLog(@"保存成功！");
   }
}

- (UIImage *)savedFace
{
    NSString *path = [NSTemporaryDirectory() stringByAppendingPathComponent:@"avatar.png"] ;
    return [UIImage imageWithContentsOfFile:path];
}

@end
