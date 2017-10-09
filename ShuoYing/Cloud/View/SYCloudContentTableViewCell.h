//
//  SYCloudContentTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/6/21.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYCloudContentFrameModel;

typedef void(^HudongType)(NSInteger type);

typedef void(^SelectCommentBlock)(NSIndexPath *commmentIndexpath);

typedef void(^SelectGuanzhuBlock)(NSInteger type);

typedef void(^DeleteCommentBlock)(NSIndexPath *deleteIndexpth);

typedef void(^SelecteImageViewBlock)(NSInteger selecteIndex);//选中的图片回调

@interface SYCloudContentTableViewCell : UITableViewCell

@property (nonatomic, weak) UIView *userinfosView;

@property (nonatomic, weak) UIView *imagesView;

@property (nonatomic, weak) UIView *categaryView;

@property (nonatomic, weak) UIView *commentView;

@property (nonatomic, weak) UIView *hudongView;

/**
 初始化cell

 @param tableView tableview
 @return SYCloudContentTableViewCell
 */
+ (instancetype)cellWithTableView:(UITableView *)tableView;

- (void)zanShowAnimation;

@property (nonatomic, strong) SYCloudContentFrameModel *frameModel;

@property (nonatomic, copy) HudongType hudongType;

@property (nonatomic, copy) SelectCommentBlock selectComment;

@property (nonatomic, copy) SelectGuanzhuBlock guanzhuBlock;

@property (nonatomic, copy) DeleteCommentBlock deleteComment;

/**
 选中图片的回调
 */
@property (nonatomic, copy) SelecteImageViewBlock selecteImageView;

@property (nonatomic, weak) UIButton *zanBtn;

@property (nonatomic, weak) UIButton *guanzhuBtn;

@property (nonatomic, strong) NSNumber *uid;//回复的人的id

@end
