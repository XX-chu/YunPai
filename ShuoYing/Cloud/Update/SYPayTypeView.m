//
//  SYPayTypeView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/16.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPayTypeView.h"
#import "SYUserInfos.h"

#define LineHeight 44.0
#define TypeCount 3
static SYPayTypeView *_sharedInstance = nil;

@interface SYPayTypeView ()
{
    UIView *_contentView;
    CGFloat _contentViewHeight;
    SYUserInfos *_userinfos;
}

@end

@implementation SYPayTypeView

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        
        [self initContent];
    }
    return self;
}

- (void)initContent{
    _userinfos = [[Tool sharedInstance] getObjectWithPath:Mobile];

    
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    //alpha 0.0  白色   alpha 1 ：黑色   alpha 0～1 ：遮罩颜色，逐渐
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)]];
    
    if (_contentView == nil)
    {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight - LineHeight * TypeCount, kScreenWidth, LineHeight * TypeCount)];
        _contentView.backgroundColor = [UIColor whiteColor];
        [self addSubview:_contentView];
        //label
        UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 12, kScreenWidth, 20)];
        label.text = @"付款方式";
        label.font = [UIFont systemFontOfSize:15];
        label.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:label];
        
        UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(0, 44, kScreenWidth, 1)];
        lineView1.backgroundColor = RGB(242, 242, 242);
        [_contentView addSubview:lineView1];
        UIImageView *imageView1 = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lineView1.frame) + 9, 25, 25)];
        imageView1.image = [UIImage imageNamed:@"weixin"];
        [_contentView addSubview:imageView1];
        UILabel *label1 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView1.frame) + 10, CGRectGetMaxY(lineView1.frame) + 12, kScreenWidth - 100, 20)];
        label1.text = @"微信";
        label1.font = [UIFont systemFontOfSize:15];
        [_contentView addSubview:label1];
        UIButton *btn1 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn1.frame = CGRectMake(0, 45, kScreenWidth, 43);
        btn1.tag = 0;
        [btn1 addTarget:self action:@selector(selectedTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:btn1];
        
        
        UIView *lineView2 = [[UIView alloc] initWithFrame:CGRectMake(0, 88, kScreenWidth, 1)];
        lineView2.backgroundColor = RGB(242, 242, 242);
        [_contentView addSubview:lineView2];
        UIImageView *imageView2 = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lineView2.frame) + 9, 25, 25)];
        imageView2.image = [UIImage imageNamed:@"zhifubao"];
        [_contentView addSubview:imageView2];
        UILabel *label2 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView2.frame) + 10, CGRectGetMaxY(lineView2.frame) + 12, kScreenWidth - 100, 20)];
        label2.text = @"支付宝";
        label2.font = [UIFont systemFontOfSize:15];
        [_contentView addSubview:label2];
        UIButton *btn2 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn2.frame = CGRectMake(0, 89, kScreenWidth, 43);
        btn2.tag = 1;
        [btn2 addTarget:self action:@selector(selectedTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:btn2];
        
        
        UIView *lineView3 = [[UIView alloc] initWithFrame:CGRectMake(0, 132, kScreenWidth, 1)];
        lineView3.backgroundColor = RGB(242, 242, 242);
        [_contentView addSubview:lineView3];
        UIImageView *imageView3 = [[UIImageView alloc] initWithFrame:CGRectMake(10, CGRectGetMaxY(lineView3.frame) + 9, 25, 25)];
        imageView3.image = [UIImage imageNamed:@"login_logo"];
        [_contentView addSubview:imageView3];
        UILabel *label3 = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetMaxX(imageView3.frame) + 10, CGRectGetMaxY(lineView3.frame) + 12, kScreenWidth - 150, 20)];
        label3.text = @"我的钱包余额";
        label3.font = [UIFont systemFontOfSize:15];
        [_contentView addSubview:label3];
        UILabel *yuELabel = [[UILabel alloc] initWithFrame:CGRectMake(kScreenWidth - 100, CGRectGetMinY(label3.frame), 90, 20)];
        yuELabel.text = [NSString stringWithFormat:@"余额：¥%.2f",[_userinfos.money floatValue] / 100];
        yuELabel.textAlignment = NSTextAlignmentRight;
        yuELabel.font = [UIFont systemFontOfSize:11];
        yuELabel.textColor = RGB(157, 157, 157);
        [_contentView addSubview:yuELabel];
        
        UIButton *btn3 = [UIButton buttonWithType:UIButtonTypeCustom];
        btn3.frame = CGRectMake(0, 133, kScreenWidth, 43);
        btn3.tag = 2;
        [btn3 addTarget:self action:@selector(selectedTypeAction:) forControlEvents:UIControlEventTouchUpInside];
        [_contentView addSubview:btn3];
        
    }
    [self addSubview:_contentView];
}

- (void)selectedTypeAction:(UIButton *)sender{
    if (self.block) {
        self.block(sender.tag);
        [self dismissView];
    }
}

- (void)showInView{
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    [window addSubview:self];
    
    [_contentView setFrame:CGRectMake(0, CGRectGetMaxY(self.frame), kScreenWidth, LineHeight * TypeCount)];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 1.0;
        
        [_contentView setFrame:CGRectMake(0, CGRectGetHeight(self.frame) - LineHeight * TypeCount, kScreenWidth, LineHeight * TypeCount)];
    }];
}

- (void)dismissView{
    [_contentView setFrame:CGRectMake(0, CGRectGetHeight(self.frame) - LineHeight * TypeCount, kScreenWidth, LineHeight * TypeCount)];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.alpha = 0.0;
                         
                         [_contentView setFrame:CGRectMake(0, CGRectGetMaxY(self.frame), kScreenWidth, LineHeight * TypeCount)];
                     }
                     completion:^(BOOL finished){
                         
                         [self removeFromSuperview];
                         
                     }];
}


@end
