//
//  SYNewAlbumViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/29.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYNewAlbumViewController.h"

@interface SYNewAlbumViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    UITextField *_textField;
    NSURLSessionTask *_dataTask;
}

@property (nonatomic, strong) UITableView *tableView;

@end

@implementation SYNewAlbumViewController
- (void)viewWillAppear:(BOOL)animated{
    [self setRightBarButtonItem];
    [super viewWillAppear:animated];
    
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    self.navigationItem.rightBarButtonItem = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"新建相册";
    [self.view addSubview:self.tableView];
}

- (void)setRightBarButtonItem{
    UIButton *btn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 40, 40)];
    [btn setTitle:@"保存" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [btn setTitleEdgeInsets:UIEdgeInsetsMake(0, 10, 0, -10)];
    [btn addTarget:self action:@selector(saveAction:) forControlEvents:UIControlEventTouchUpInside];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    UIBarButtonItem *baritem = [[UIBarButtonItem alloc] initWithCustomView:btn];
    self.navigationItem.rightBarButtonItem = baritem;
}

- (void)saveAction:(UIButton *)sender{
    if (_textField.text.length == 0) {
        return;
    }
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/my/newfile.html"];
    NSDictionary *param = @{@"token":UserToken, @"file":_textField.text};
    _dataTask = [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"获取上传-我的-所有相册目录 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                [self.navigationController popViewControllerAnimated:YES];
                [self showHint:[responseResult objectForKey:@"msg"]];
            }else{
                if ([responseResult objectForKey:@"msg"]) {
                    [self showHint:[responseResult objectForKey:@"msg"]];
                }
            }
        }
    }];
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
        
    }
    UITextField *textField = [[UITextField alloc] initWithFrame:CGRectMake(15, 7, kScreenWidth - 30, 30)];
    _textField = textField;
    textField.placeholder = @"标题";
    [cell.contentView addSubview:textField];
    
    return cell;
}

#pragma mark - layzLoad
- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - 64) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.backgroundColor = BackGroundColor;
    }
    return _tableView;
}

@end
