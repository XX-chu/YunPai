//
//  SYReportGrapherViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2017/1/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYReportGrapherViewController.h"

#import "SYReportTableViewCell.h"

@interface SYReportGrapherViewController ()<UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

{
    NSInteger _selectedRow;
    UITextView *_textView;
}

@property (nonatomic, strong) UITableView *tableView;

@property (nonatomic, strong) NSMutableArray *dataSourceArr;

@property (nonatomic, strong) UIView *footerView;

@property (nonatomic, strong) UILabel *placeHoldLabel;

@end

#define MAX_LIMIT_NUMS 500

@implementation SYReportGrapherViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"举报";
    _selectedRow = 99;
    [self.view addSubview:self.tableView];
    [self setRightbarItem];
}

- (void)setRightbarItem{
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, 44, 44);
    [btn setTitle:@"提交" forState:UIControlStateNormal];
    [btn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:15];
    [btn addTarget:self action:@selector(reportAction:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *right = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFixedSpace target:nil action:nil];
    right.width = -15;
    
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithCustomView:btn];
    
    self.navigationItem.rightBarButtonItems = @[right, item];
}

- (void)reportAction:(UIButton *)sender{

    if (_selectedRow == 99) {
        return;
    }
    
    NSString *url = [NSString stringWithFormat:@"%@%@",BaseUrl,@"/get/report.html"];
    NSDictionary *param = nil;
    if (_selectedRow == 7) {
        param = @{@"id":[self.dataSourceDic objectForKey:@"id"], @"type":[NSNumber numberWithInteger:_selectedRow + 1], @"info":_textView.text};

    }else{
        param = @{@"id":[self.dataSourceDic objectForKey:@"id"], @"type":[NSNumber numberWithInteger:_selectedRow + 1]};
    }
    
    [[SYHttpRequest sharedInstance] getDataWithUrl:url Parameter:param ResponseObject:^(NSDictionary *responseResult) {
        
        NSLog(@"举报摄影师 -- %@",responseResult);
        if ([responseResult objectForKey:@"resError"]) {
            [self showHint:@"服务器不给力，请稍后重试"];
        }else{
            if ([[responseResult objectForKey:@"result"] integerValue] == 1) {
                
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
    return 8;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *identifier = @"cell";
    SYReportTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[NSBundle mainBundle] loadNibNamed:@"SYReportTableViewCell" owner:nil options:nil][0];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    
    if (_selectedRow == indexPath.row) {
        cell.isSelectedIMG.image = [UIImage imageNamed:@"jubao_anniu_sel"];
    }else{
        cell.isSelectedIMG.image = [UIImage imageNamed:@"jubao_anniu_nor"];
    }
    
    cell.contentLabel.text = self.dataSourceArr[indexPath.row];
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    _selectedRow = indexPath.row;

    if (indexPath.row == 7) {
        [self.tableView reloadData];

        return;
    }
    [self.tableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 50;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    if (_selectedRow  == 7) {
        return 100;
    }
    return 0.000001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [UIColor whiteColor];
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(15, 15, kScreenWidth - 30, 20)];
    label.textColor = NavigationColor;
    label.text = @"请在下面的选项中选出您的举报理由:";
    label.font = [UIFont systemFontOfSize:16];
    [view addSubview:label];
    
    return view;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    if (_selectedRow == 7) {
        
        return self.footerView;
    }
    
    
    return nil;
}

#pragma mark -显示当前可输入字数/总字数
- (void)textViewDidChange:(UITextView *)textView{
    
    if ([textView.text length] == 0) {
        [self.placeHoldLabel setHidden:NO];
    }else{
        [self.placeHoldLabel setHidden:YES];
    }
    
    
    //    _liuyanHeight.constant = textView.contentSize.height;
    
    UITextRange *selectedRange = [textView markedTextRange];
    
    //获取高亮部分
    
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    
    if (selectedRange && pos) {
        
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_NUMS){
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        
        [textView setText:s];
        
    }
    
    
}


- (UITableView *)tableView{
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight - kNavigationBarHeightAndStatusBarHeight) style:UITableViewStyleGrouped];
        _tableView.backgroundColor = BackGroundColor;
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    }
    return _tableView;
}

- (NSMutableArray *)dataSourceArr{
    if (!_dataSourceArr) {
        _dataSourceArr = [NSMutableArray arrayWithCapacity:0];
        [_dataSourceArr addObject:@"侵犯了我或者他人权利"];
        [_dataSourceArr addObject:@"宣传类广告图片"];
        [_dataSourceArr addObject:@"传播黄色、淫秽、低俗图片"];
        [_dataSourceArr addObject:@"传播反人类、反政府、反社会图片"];
        [_dataSourceArr addObject:@"散播暴力、凶杀、恐怖或者教唆犯罪等图片"];
        [_dataSourceArr addObject:@"发布侮辱、诽谤或者人身攻击等图片"];
        [_dataSourceArr addObject:@"扰乱社会秩序、破坏社会稳定等图片"];
        [_dataSourceArr addObject:@"其他"];
    }
    return _dataSourceArr;
}

- (UIView *)footerView{
    if (!_footerView) {
        _footerView = [[UIView alloc] init];
        _footerView.backgroundColor = [UIColor whiteColor];
        
        UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 100)];
        textView.delegate = self;
        _textView = textView;
        [_footerView addSubview:textView];
        
        self.placeHoldLabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 5, kScreenWidth - 20, 20)];
        self.placeHoldLabel.text = @"请您输入您的举报理由";
        self.placeHoldLabel.textColor = [UIColor lightGrayColor];
        self.placeHoldLabel.font = [UIFont systemFontOfSize:13];
        [textView addSubview:self.placeHoldLabel];
    }
    return _footerView;
}

@end
