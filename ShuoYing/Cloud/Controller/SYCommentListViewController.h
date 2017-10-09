//
//  SYCommentListViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/7/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYCloudContentFrameModel;
@interface SYCommentListViewController : UIViewController

@property (nonatomic, strong) NSNumber *cloudID;

@property (nonatomic, strong) SYCloudContentFrameModel *frameModel;

@property (nonatomic, strong) NSNumber *uid;//回复人的uid
@end
