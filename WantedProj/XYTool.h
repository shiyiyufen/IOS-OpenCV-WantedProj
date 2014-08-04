//
//  XYTool.h
//  WantedProj
//
//  Created by JD_Acorld on 14-8-4.
//  Copyright (c) 2014年 hxy. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface XYTool : NSObject

+ (XYTool *)sharedXYTool;

- (BOOL)cameraIsFront;
- (void)setCameraFront:(BOOL)front;
@end
