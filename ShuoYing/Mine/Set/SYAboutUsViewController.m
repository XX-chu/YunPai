//
//  SYAboutUsViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYAboutUsViewController.h"

#import "SYJianJieViewController.h"
#import "SYXieYiViewController.h"
@interface SYAboutUsViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *bundleVersionLabel;
@property (weak, nonatomic) IBOutlet UITableView *tableView;



@end

@implementation SYAboutUsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"关于我们";
    self.bundleVersionLabel.text = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleShortVersionString"];
    [self.tableView setTableFooterView:[[UIView alloc] initWithFrame:CGRectZero]];
    
    self.tableView.backgroundColor = BackGroundColor;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row == 0) {
        SYJianJieViewController *jianjie = [[SYJianJieViewController alloc] initWithNibName:@"SYJianJieViewController" bundle:nil];
        [self.navigationController pushViewController:jianjie animated:YES];
    }else{
        SYXieYiViewController *xieyi = [[SYXieYiViewController alloc] init];
        [self.navigationController pushViewController:xieyi animated:YES];
    }
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        cell.backgroundColor = BackGroundColor;
        cell.textLabel.font = [UIFont systemFontOfSize:15];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (indexPath.row == 0) {
        cell.textLabel.text = @"云拍简介";
    }else{
        cell.textLabel.text = @"用户协议";
    }
    
    return cell;
}

@end
