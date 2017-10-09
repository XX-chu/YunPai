//
//  QTShareView.h
//  ReadingClub
//
//  Created by qtkj on 16/9/29.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QTShareViewDelegate <NSObject>
/*
    tag值对应的分享平台
    1.QQ
    2.空间
    3.微信
    4.朋友圈
 */
@required
- (void)didSelectedShareBtnWithTag:(NSInteger)tag;

@end

@interface QTShareView : UIView

@property (nonatomic, weak) id<QTShareViewDelegate>delegate;

+ (instancetype)sharedInstance;

- (void)showInView:(UIView *)view;

- (void)dismissView;

@end
