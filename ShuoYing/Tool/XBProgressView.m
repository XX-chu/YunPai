//
//  XBProgressView.m
//  ShuoYing
//
//  Created by 硕影 on 2017/2/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "XBProgressView.h"


#define WIDTH self.frame.size.width
#define HEIGHT self.frame.size.height

@implementation XBProgressView

- (instancetype)initWithFrame:(CGRect)frame
{
    if([super initWithFrame:frame])
    {
        [self initData];
    }
    return self;
}

- (instancetype)init
{
    if([super init])
    {
        [self initData];
    }
    return self;
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder
{
    if([super initWithCoder:aDecoder])
    {
        [self initData];
    }
    return self;
}

- (void)initData{
    self.backgroundColor = [UIColor whiteColor];

    self.progressWidth = 3.0;
    self.progressColor = NavigationColor;
    self.progressBackgroundColor = [UIColor lightGrayColor];
    self.percent = 0.0;
    
    self.labelbackgroundColor = [UIColor clearColor];
    self.textColor = NavigationColor;
    self.textFont = [UIFont systemFontOfSize:15];
    
    UILabel *indicaterLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, WIDTH - 30, 15)];
    indicaterLabel.text = @"图片上传中";
    indicaterLabel.font = [UIFont systemFontOfSize:15];
    [self addSubview:indicaterLabel];
    
    UILabel *tishi = [[UILabel alloc] initWithFrame:CGRectMake(15, CGRectGetMaxY(indicaterLabel.frame) + 15, 75, 15)];
    tishi.text = @"温馨提示:";
    tishi.textColor = NavigationColor;
    tishi.font = [UIFont systemFontOfSize:14];
    [self addSubview:tishi];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.numberOfLines = 0;
    contentLabel.text = @"上传原图(未做压缩处理)时间可能较长，请您耐心等待，不要离开此页面";
    contentLabel.font = [UIFont systemFontOfSize:14];
    
    CGSize maxSize = CGSizeMake(WIDTH - 30 - CGRectGetWidth(tishi.frame), 9999);
    CGSize expectSize = [contentLabel sizeThatFits:maxSize];
    contentLabel.frame = CGRectMake(CGRectGetMaxX(tishi.frame), CGRectGetMinY(tishi.frame), expectSize.width, expectSize.height);
    
    [self addSubview:contentLabel];
    
    //一共多少张图片
    self.numberLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 145, 80, 15)];
    self.numberLabel.textAlignment = NSTextAlignmentLeft;
    self.numberLabel.font = [UIFont systemFontOfSize:14];
    self.numberLabel.text = [NSString stringWithFormat:@"%d%d",0,0];
    [self addSubview:self.numberLabel];
}

- (void)layoutSubviews
{
    [super addSubview:self.centerLabel];
    self.centerLabel.backgroundColor = self.labelbackgroundColor;
    self.centerLabel.textColor = self.textColor;
    self.centerLabel.font = self.textFont;
    [self addSubview:self.centerLabel];
}

#pragma mark -- 画进度条

- (void)drawRect:(CGRect)rect
{
    //获取当前画布
    CGContextRef context = UIGraphicsGetCurrentContext();
    
//    CGContextSetShouldAntialias(context, YES);
    //画一条直线
    CGContextMoveToPoint(context, 15, 120);
    CGContextAddLineToPoint(context, WIDTH - 15, 120);
    //画线的宽度
    CGContextSetLineWidth(context, 15.0);
    //画线的颜色
    CGFloat components[] = {242.0/255,242.0/255,242.0/255,1.0f};
    CGContextSetStrokeColor(context, components);
    
    //绘制路径
    CGContextStrokePath(context);
    
    if(self.percent)
    {
        CGContextRef context1 = UIGraphicsGetCurrentContext();

        //画一条直线
        CGContextMoveToPoint(context1, 15, 120);
        CGContextAddLineToPoint(context1, (WIDTH - 30) * self.percent + 15, 120);
        //画线的宽度
        CGContextSetLineWidth(context1, 15.0);
        //画线的颜色
        CGFloat components1[] = {71.0/255,205.0/255,188.0/255,1.0f};
        CGContextSetStrokeColor(context1, components1);
        
        //绘制路径
        CGContextStrokePath(context1);
    }
}

- (void)setPercent:(float)percent
{
    if(self.percent < 0) return;
    
    _percent = percent;
    
    [self setNeedsDisplay];
}

- (UILabel *)centerLabel
{
    if(!_centerLabel)
    {
        _centerLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIDTH - 80, 145, 65, 15)];
//        _centerLabel.center = CGPointMake(WIDTH/2, HEIGHT/2);
        _centerLabel.textAlignment = NSTextAlignmentRight;
    }
    return _centerLabel;
}


@end
