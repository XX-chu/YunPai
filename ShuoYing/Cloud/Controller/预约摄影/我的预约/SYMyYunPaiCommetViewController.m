//
//  SYMyYunPaiCommetViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMyYunPaiCommetViewController.h"
#import "SYTouSuYunPaiShiViewController.h"
@interface SYMyYunPaiCommetViewController ()
{
    NSInteger _chengpianCount;
    NSInteger _fenggeCount;
    NSInteger _guochengCount;
}
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *yiwanchengLabel;
@property (weak, nonatomic) IBOutlet UILabel *xinghaoLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *stars;

@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *chengpianStars;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *fenggeStars;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *guochengStars;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeightConstraint;
@property (weak, nonatomic) IBOutlet UIButton *commitBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;

@end

@implementation SYMyYunPaiCommetViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    self.title = @"评价";
    _chengpianCount = 0;
    _fenggeCount = 0;
    _guochengCount = 0;
    
    self.contentViewHeightConstraint.constant = kScreenHeight;
    self.commitBtn.layer.cornerRadius = 5;
    self.commitBtn.layer.masksToBounds = YES;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, self.model.head]] placeholderImage:NoPicture];
    self.nickLabel.text = self.model.nick;
    self.yiwanchengLabel.text = [NSString stringWithFormat:@"摄影师：%@",self.model.name];
    self.xinghaoLabel.text = [NSString stringWithFormat:@"联系电话：%@",self.model.tel];
    
    for (int i = 0; i < self.stars.count; i++) {
        UIImageView *imgView = self.stars[i];
        if (i > [self.model.ping integerValue] - 1) {
            imgView.image = [UIImage imageNamed:@"pingjia_nor"];
        }else{
            imgView.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        }
    }
}

- (IBAction)chengpianAction:(UIButton *)sender {
    NSInteger tag = sender.tag;
    _chengpianCount = tag + 1;
    for (int i = 0; i < self.chengpianStars.count; i++) {
        UIButton *btn = self.chengpianStars[i];
        if (i < tag + 1) {
            [btn setBackgroundImage:[UIImage imageNamed:@"pingjia_sel"] forState:UIControlStateNormal];
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"pingjia_nor"] forState:UIControlStateNormal];
        }
    }
}
- (IBAction)fenggeAction:(UIButton *)sender {
    NSInteger tag = sender.tag;
    _fenggeCount = tag + 1;

    for (int i = 0; i < self.fenggeStars.count; i++) {
        UIButton *btn = self.fenggeStars[i];
        if (i < tag + 1) {
            [btn setBackgroundImage:[UIImage imageNamed:@"pingjia_sel"] forState:UIControlStateNormal];
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"pingjia_nor"] forState:UIControlStateNormal];
        }
    }
}

- (IBAction)guochengAction:(UIButton *)sender {
    NSInteger tag = sender.tag;
    _guochengCount = tag + 1;

    for (int i = 0; i < self.guochengStars.count; i++) {
        UIButton *btn = self.guochengStars[i];
        if (i < tag + 1) {
            [btn setBackgroundImage:[UIImage imageNamed:@"pingjia_sel"] forState:UIControlStateNormal];
        }else{
            [btn setBackgroundImage:[UIImage imageNamed:@"pingjia_nor"] forState:UIControlStateNormal];
        }
    }
    
}
- (IBAction)commitComment:(UIButton *)sender {
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/masters/ping.html"];
    NSDictionary *param = @{@"id":self.model.orderid, @"token":UserToken, @"ping1":[NSNumber numberWithInteger:_chengpianCount], @"ping2":[NSNumber numberWithInteger:_fenggeCount],@"ping3":[NSNumber numberWithInteger:_guochengCount]};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"评价 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                for (id vc in self.navigationController.viewControllers) {
                    if ([vc isKindOfClass:NSClassFromString(@"SYYuYueViewController")]) {
                        [self.navigationController popToViewController:vc animated:YES];
                        break;
                    }
                }
                [self showHint:[responseResult objectForKey:@"msg"]];

            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}
- (IBAction)tousuAction:(UIButton *)sender {
    SYTouSuYunPaiShiViewController *tousu = [[SYTouSuYunPaiShiViewController alloc] init];
    tousu.orderid = self.model.orderid;
    [self.navigationController pushViewController:tousu animated:YES];
}


@end
