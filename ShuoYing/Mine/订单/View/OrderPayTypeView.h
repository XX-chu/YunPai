//
//  OrderPayTypeView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^zhifubaoBlock)();
typedef void(^weixinBlock)();
typedef void(^yueBlock)();
@interface OrderPayTypeView : UIView<UIWebViewDelegate>

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *backviewToBottom;
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *fukuanTypeViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *weixinViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *zhifubaoViewHeight;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *yueViewHeight;
@property (weak, nonatomic) IBOutlet UIButton *weixinBtn;
@property (weak, nonatomic) IBOutlet UIButton *zhifubaoBtn;
@property (weak, nonatomic) IBOutlet UIButton *yueBtn;
@property (weak, nonatomic) IBOutlet UIButton *dismissBtn;
@property (weak, nonatomic) IBOutlet UILabel *moneyLabel;

@property (nonatomic, copy)zhifubaoBlock zhifubao;
@property (nonatomic, copy)weixinBlock weixin;
@property (nonatomic, copy)yueBlock yue;


- (void)show;
- (void)dismiss;

@end
