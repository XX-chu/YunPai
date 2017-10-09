//
//  QTShareView.m
//  ReadingClub
//
//  Created by qtkj on 16/9/29.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import "QTShareView.h"

static QTShareView *_sharedInstance = nil;

@interface QTShareView ()
{
    UIView *_contentView;
    CGFloat _shareBtnHeight;
}

@end

@implementation QTShareView

+ (instancetype)sharedInstance{
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _sharedInstance = [[self alloc] init];
    });
    return _sharedInstance;
}

- (instancetype)init{
    if (self = [super init]) {
        _shareBtnHeight = 150.0f;
        [self initContent];
    }
    return self;
}

- (void)initContent{
    self.frame = CGRectMake(0, 0, kScreenWidth, kScreenHeight);
    //alpha 0.0  白色   alpha 1 ：黑色   alpha 0～1 ：遮罩颜色，逐渐
    self.backgroundColor = [[UIColor blackColor] colorWithAlphaComponent:.6];
    self.userInteractionEnabled = YES;
    [self addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissView)]];
    
    if (_contentView == nil)
    {
        _contentView = [[UIView alloc]initWithFrame:CGRectMake(0, kScreenHeight - _shareBtnHeight, kScreenWidth, _shareBtnHeight)];
        _contentView.backgroundColor = [UIColor whiteColor];
        
        UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:_contentView.bounds byRoundingCorners:UIRectCornerTopLeft | UIRectCornerTopRight cornerRadii:CGSizeMake(10, 10)];
        CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
        maskLayer.frame = _contentView.bounds;
        maskLayer.path = maskPath.CGPath;
        _contentView.layer.mask = maskLayer;
        
        [self addSubview:_contentView];
        
        UILabel *contentLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 5, kScreenWidth, 30)];
        contentLabel.text = @"分享";
        contentLabel.font = [UIFont systemFontOfSize:16];
        contentLabel.textAlignment = NSTextAlignmentCenter;
        [_contentView addSubview:contentLabel];
        
        UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, CGRectGetMaxY(contentLabel.frame), kScreenWidth, 1)];
        lineView.backgroundColor = RGB(232, 232, 232);
        [_contentView addSubview:lineView];
        
        //添加4个按钮
        NSArray *imageArr = @[@"qq", @"qqzone", @"weixin123", @"pengyouquan"];
        
        for (int i = 0; i < 4; i++) {
            UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(i * (kScreenWidth / 4) , 31, kScreenWidth / 4, 120)];
            [btn setImage:[UIImage imageNamed:imageArr[i]]  forState:UIControlStateNormal];
            [btn addTarget:self action:@selector(shareBtn:) forControlEvents:UIControlEventTouchUpInside];
            btn.tag = i;
            [_contentView addSubview:btn];
        
        }
    }
}

- (void)shareBtn:(UIButton *)sender{
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedShareBtnWithTag:)]) {
        [_delegate didSelectedShareBtnWithTag:sender.tag];
    }
}

- (void)showInView:(UIView *)view{
    if (!view)
    {
        return;
    }
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    
    [window addSubview:self];
    [window addSubview:_contentView];
    
    [_contentView setFrame:CGRectMake(0, CGRectGetMaxY(self.frame), kScreenWidth, _shareBtnHeight)];
    
    [UIView animateWithDuration:0.3 animations:^{
        
        self.alpha = 1.0;
        
        [_contentView setFrame:CGRectMake(0, CGRectGetHeight(self.frame) - _shareBtnHeight, kScreenWidth, _shareBtnHeight)];
    }];

}

- (void)dismissView{
    [_contentView setFrame:CGRectMake(0, CGRectGetHeight(self.frame) - _shareBtnHeight, kScreenWidth, _shareBtnHeight)];
    [UIView animateWithDuration:0.3f
                     animations:^{
                         
                         self.alpha = 0.0;
                         
                         [_contentView setFrame:CGRectMake(0, CGRectGetMaxY(self.frame), kScreenWidth, _shareBtnHeight)];
                     }
                     completion:^(BOOL finished){
                         
                         [self removeFromSuperview];
                         [_contentView removeFromSuperview];
                         
                     }];
}

@end
