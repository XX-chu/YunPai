//
//  SYCommentViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/6/30.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"
@class SYCloudContentFrameModel;
@interface SYCommentViewController : SYBaseViewController

@property (nonatomic, strong) NSNumber *cloudID;

@property (nonatomic, strong) SYCloudContentFrameModel *frameModel;

@property (nonatomic, strong) NSIndexPath *selecteCommentIndexpath;

@property (nonatomic, strong) NSNumber *pid;//回复人的id

@property (nonatomic, copy) NSString *name;//回复人的名字
@end
