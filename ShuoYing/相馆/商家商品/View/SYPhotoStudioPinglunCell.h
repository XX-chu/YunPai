//
//  SYPhotoStudioPinglunCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/24.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYCommentModel;
typedef void(^YouYongSelecte)();
typedef void(^WuYongSelecte)();
@interface SYPhotoStudioPinglunCell : UITableViewCell

@property (nonatomic, strong) SYCommentModel *commemtModel;

@property (nonatomic, copy) YouYongSelecte youyongBlock;

@property (nonatomic, copy) WuYongSelecte wuyongBlock;

@end
