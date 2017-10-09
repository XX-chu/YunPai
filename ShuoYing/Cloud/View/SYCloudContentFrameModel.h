//
//  SYCloudContentFrameModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/6/21.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SYCloudModel;
@interface SYCloudContentFrameModel : NSObject

/**
 用户详情的Frame
 */
@property (nonatomic, assign) CGRect userinfoFrame;

/**
 图片的Frame
 */
@property (nonatomic, assign) CGRect imagesFrame;

/**
 分类的Frame
 */
@property (nonatomic, assign) CGRect categaryFrame;

/**
 评论的Frame
 */
@property (nonatomic, assign) CGRect commentFrame;

/**
 互动的Frame
 */
@property (nonatomic, assign) CGRect hudongFrame;

/**
 cell高度
 */
@property (nonatomic, assign) CGFloat cellHeight;

/**
 数据模型
 */
@property (nonatomic, strong) SYCloudModel *cloudModel;

@end
