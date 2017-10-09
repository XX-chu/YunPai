//
//  SYSettingViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYSettingViewController.h"

#import "SYAboutUsViewController.h"
#import "SYFeedbackViewController.h"
#import "SYLoginViewController.h"


@interface SYSettingViewController ()<UITableViewDelegate, UITableViewDataSource>

{
    NSURLSessionTask *_dataTask;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, copy) NSArray *contentArr;

@end

@implementation SYSettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"设置";
    self.contentArr = @[@"客服电话", @"关于我们", @"意见反馈", @"版本更新"];
    [self.view addSubview:self.tableView];
    NSLog(@"%@",self.navigationController.viewControllers);
}

#pragma mark - UITableViewDelegate

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 3;
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identirier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identirier];
//    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleValue1 reuseIdentifier:identirier];
    }
    cell.textLabel.text = self.contentArr[indexPath.row];
    cell.textLabel.font = [UIFont systemFontOfSize:15];
    if (indexPath.row == 3) {
        cell.detailTextLabel.text = @"已是最新版本";
        cell.detailTextLabel.font = [UIFont systemFontOfSize:13];
    }
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    
    return 200;
    
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{

        UIView *view = [[UIView alloc] init];
        view.backgroundColor = BackGroundColor;
        
        UIButton *signOut = [[UIButton alloc] initWithFrame:CGRectMake(40, 160, kScreenWidth - 80, 40)];
        signOut.layer.cornerRadius = 5;
        signOut.layer.masksToBounds = YES;
        [signOut setBackgroundImage:[UIImage imageWithColor:NavigationColor Size:signOut.frame.size] forState:UIControlStateNormal];
        [signOut setAdjustsImageWhenHighlighted:NO];
        [signOut setTitle:@"退出登录" forState:UIControlStateNormal];
        [signOut setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        [signOut addTarget:self action:@selector(signOutAction) forControlEvents:UIControlEventTouchUpInside];
        [view addSubview:signOut];
        return view;

}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        [self getKeFuCallWithTableView:tableView];
    }else if (indexPath.row == 1) {
        SYAboutUsViewController *about = [[SYAboutUsViewController alloc] initWithNibName:@"SYAboutUsViewController" bundle:nil];
        [self.navigationController pushViewController:about animated:YES];
    }else if (indexPath.row == 2) {
        SYFeedbackViewController *feedback = [[SYFeedbackViewController alloc] initWithNibName:@"SYFeedbackViewController" bundle:nil];
        [self.navigationController pushViewController:feedback animated:YES];
    }else if (indexPath.row == 3) {
        
    }else{
    
    }
}

- (void)signOutAction{
    NSUserDefaults *us = [NSUserDefaults standardUserDefaults];
    [us removeObjectForKey:@"token"];
    [us removeObjectForKey:@"mobile"];
    [us removeObjectForKey:@"LoginStatus"];
    [us synchronize];
    
    SYLoginViewController *login = [[SYLoginViewController alloc] initWithNibName:@"SYLoginViewController" bundle:nil];
    login.isFromLogout = YES;
    [self.navigationController pushViewController:login animated:YES];
    

//    if ([self.navigationController.viewControllers[0] isKindOfClass:[UITabBarController class]]) {
//        [(UITabBarController *)self.navigationController.viewControllers[0] setSelectedIndex:0];
//    }
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"LoginOut" object:nil];

}



#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64)];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = BackGroundColor;
        [_tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    }
    
    return _tableView;
}

- (void)viewWillLayoutSubviews{
    if ([self.tableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.tableView setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
    if ([self.tableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.tableView setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath{
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsMake(0, 0, 0, 0)];
    }
    if ([cell respondsToSelector:@selector(setAccessoryType:)]) {
        [cell setAccessoryType:UITableViewCellAccessoryDisclosureIndicator];
    }
    if ([cell respondsToSelector:@selector(setSelectionStyle:)]) {
        [cell setSelectionStyle:UITableViewCellSelectionStyleNone];
    }
}

#pragma mark - GetNetwork
- (void)getKeFuCallWithTableView:(UITableView *)tableView{
    tableView.userInteractionEnabled = NO;
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/call.html"];
    
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:nil ResponseObject:^(NSDictionary *responseResult) {
        tableView.userInteractionEnabled = YES;
        NSLog(@"客服电话 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
//                [self showActionSheetWithPhone:[responseResult objectForKey:@"call"]];
                NSString *number = [responseResult objectForKey:@"call"];// 此处读入电话号码
                // NSString *num = [[NSString alloc]initWithFormat:@"tel://%@",number]; //number为号码字符串 如果使用这个方法结束电话之后会进入联系人列表
                
                NSString *num = [[NSString alloc]initWithFormat:@"telprompt://%@",number]; //而这个方法则打电话前先弹框 是否打电话 然后打完电话之后回到程序中 网上说这个方法可能不合法 无法通过审核
                [[UIApplication sharedApplication] openURL:[NSURL URLWithString:num]]; //拨号
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (void)showActionSheetWithPhone:(NSString *)phone{
    UIAlertController *alertVC = [UIAlertController alertControllerWithTitle:@"客服电话" message:phone preferredStyle:UIAlertControllerStyleActionSheet];
    UIAlertAction *alert1 = [UIAlertAction actionWithTitle:@"呼叫" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    UIAlertAction *alert2 = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        
    }];
    
    [alertVC addAction:alert1];
    [alertVC addAction:alert2];
    
    [self presentViewController:alertVC animated:YES completion:nil];
}

@end
