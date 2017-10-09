//
//  UIImageView+ZCDownload.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/19.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
//进度条imageView
typedef void  (^ZCDownloadCompletedBlock)(UIImage *image, NSError *error);

@interface UIImageView (ZCDownload)
/*
 *异步下载图片带进度条
 *url 图片下载地址
 *completedBlock 下载完成调用的block
 */
- (void)zcSetImageAnimationWithURL:(NSURL *)url completed:(ZCDownloadCompletedBlock)completedBlock;

@end
