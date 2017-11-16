//
//  SYMyYunPaiShopViewController.m
//  ShuoYing
//
//  Created by chu on 2017/11/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYMyYunPaiShopViewController.h"
#import "SYYunPaiKeHuViewController.h"
#import "SYYunPaiShopEditViewController.h"
@interface SYMyYunPaiShopViewController ()
{
    NSNumber *_work;
}
@property (weak, nonatomic) IBOutlet UISwitch *reciveOrder;

@end

@implementation SYMyYunPaiShopViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"我的云拍店";
    [self panduanshifoujiedan];
    [self getSet];
}

- (void)panduanshifoujiedan{
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    NSNumber *work = [us objectForKey:[NSString stringWithFormat:@"%@work",Mobile]];
    if (work) {
        if ([work integerValue] == 0) {
            //不接单
            self.reciveOrder.on = NO;
        }else{
            //接单
            self.reciveOrder.on = YES;
        }
    }
}

- (IBAction)jieDan:(UISwitch *)sender {
    NSDictionary *param = nil;
    if (sender.on) {
        NSLog(@"开");
        param = @{@"token":UserToken, @"work":@1};
    }else {
        NSLog(@"关");
        param = @{@"token":UserToken, @"work":@0};

    }
    
    [SVProgressHUD show];
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/master/set.html"];
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"获取云拍师设置 -- %@",responseResult);
        [SVProgressHUD dismiss];
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
            sender.on = !sender.on;
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self showHint:[responseResult objectForKey:@"msg"]];
                
            }else{
                if ([responseResult objectForKey:@"msg"] && ![[responseResult objectForKey:@"msg"] isKindOfClass:[NSNull class]]) {
                    sender.on = !sender.on;

                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (IBAction)editShop:(UIButton *)sender {
    SYYunPaiShopEditViewController *edit = [[SYYunPaiShopEditViewController alloc] init];
    [self.navigationController pushViewController:edit animated:YES];
}

- (IBAction)myKeHu:(UIButton *)sender {
    SYYunPaiKeHuViewController *kehu = [[SYYunPaiKeHuViewController alloc] init];
    [self.navigationController pushViewController:kehu animated:YES];
}

/**
 获取店铺设置
 */
- (void)getSet{
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/master/sel.html"];
    NSDictionary *param = @{@"token":UserToken};
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        NSLog(@"获取云拍师设置 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                NSNumber *work = [[responseResult objectForKey:@"data"] objectForKey:@"work"];
                NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
                [us setObject:work forKey:[NSString stringWithFormat:@"%@work",Mobile]];
                [us synchronize];
                _work = work;
                [self panduanshifoujiedan];
            }else{
                
            }
        }
    }];
}


@end
