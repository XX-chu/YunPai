//
//  SYMessageInfosViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/17.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMessageInfosViewController.h"
#import "SYMessageInfosTableViewCell.h"
#import "SYMessageModel.h"
#import "UILabel+YBAttributeTextTapAction.h"

@interface SYMessageInfosViewController ()<YBAttributeTapActionDelegate>

{
    NSString *_msg;
}

@end

@implementation SYMessageInfosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"消息详情";
    _msg = @"";
    [self getData];
}

- (void)loadSubViews{
    UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight)];
    scrollView.backgroundColor = BackGroundColor;
    [self.view addSubview:scrollView];
    
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    [scrollView addSubview:view];
    
    NSRange phoneRange = [self jiequPhone:_msg];
    NSLog(@"phoneRange.length - %lu",(unsigned long)phoneRange.length);
    NSString *label_text1 = _msg;
    NSMutableAttributedString *attributedString1 = [[NSMutableAttributedString alloc]initWithString:label_text1];
    [attributedString1 addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:15] range:phoneRange];
    [attributedString1 addAttribute:NSForegroundColorAttributeName value:[UIColor blueColor] range:phoneRange];
    
    UILabel *contentLabel = [[UILabel alloc] init];
    contentLabel.text = _msg;
    if (phoneRange.length > 0) {
        contentLabel.attributedText = attributedString1;
        NSString *str11 = [_msg substringWithRange:phoneRange];
        [contentLabel yb_addAttributeTapActionWithStrings:@[str11] delegate:self];
    }
    
    contentLabel.font = [UIFont systemFontOfSize:15];
    contentLabel.numberOfLines = 0;
    CGSize maxSize = [contentLabel sizeThatFits:CGSizeMake(kScreenWidth - 10, MAXFLOAT)];
    contentLabel.frame = CGRectMake(10, 15, kScreenWidth - 20, maxSize.height);
    [view addSubview:contentLabel];
    view.frame = CGRectMake(0, 30, kScreenWidth, CGRectGetHeight(contentLabel.frame) + 30);
    scrollView.contentSize = CGSizeMake(0, CGRectGetHeight(view.frame) + 60);
    
}


//delegate
- (void)yb_attributeTapReturnString:(NSString *)string range:(NSRange)range index:(NSInteger)index
{
    NSLog(@"打电话");
    NSMutableString* str=[[NSMutableString alloc] initWithFormat:@"telprompt://%@",string];
    
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:str]];
}

- (NSRange)jiequPhone:(NSString *)str{
    NSLog(@"str - %@",str);
    NSRange phoneRange;
    //获取字符串中的电话号码
    NSString *regulaStr = @"1\\d{10}";
    NSRange stringRange = NSMakeRange(0, str.length);
    NSError *error;
    NSRegularExpression *regexps = [NSRegularExpression regularExpressionWithPattern:regulaStr options:0 error:&error];
    if (!error && regexps != nil) {
        NSRange range = [regexps rangeOfFirstMatchInString:str options:0 range:stringRange];
        NSLog(@"range.length - %lu",range.length);
        return range;

    }
    return phoneRange;
}

- (void)getData{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/user/info.html"];
    NSDictionary *param = @{@"token":UserToken, @"id":self.model.messageID};
    __weak typeof(self)weakself = self;
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"消息列表 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [weakself showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                _msg = [[responseResult objectForKey:@"data"] objectForKey:@"msg"];
                [self loadSubViews];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [weakself showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}


@end
