//
//  SelectAlert.m
//  SelectAlertDemo
//
//  Created by apple on 2016/11/24.
//  Copyright © 2016年 周兴. All rights reserved.
//

#import "SelectAlert.h"

@interface SelectAlertCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *selImageVIew;
@end

@implementation SelectAlertCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self addSubview:self.titleLabel];
        [self addSubview:self.selImageVIew];
    }
    return self;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.textColor = [UIColor blackColor];
        _titleLabel.font = [UIFont systemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UIImageView *)selImageVIew{
    if (!_selImageVIew) {
        _selImageVIew = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"jubao_anniu_nor"]];
    }
    return _selImageVIew;
}


- (void)layoutSubviews {
    [super layoutSubviews];
    _titleLabel.frame = CGRectMake(15, 0, self.frame.size.width - 25, self.frame.size.height);
    
    _selImageVIew.frame = CGRectMake(self.frame.size.width - 15 - 10 , 13, 15, 15);
}

@end


@interface SelectAlert ()

@property (nonatomic, assign) BOOL showCloseButton;//是否显示关闭按钮
@property (nonatomic, strong) UIView *alertView;//弹框视图
@property (nonatomic, strong) UITableView *selectTableView;//选择列表

@end

@implementation SelectAlert
{
    float alertHeight;//弹框整体高度，默认250
    float buttonHeight;//按钮高度，默认40
}

+ (SelectAlert *)showWithTitle:(NSString *)title
                        titles:(NSArray *)titles
                   selectIndex:(SelectIndex)selectIndex
                   selectValue:(SelectValue)selectValue
               showCloseButton:(BOOL)showCloseButton {
    SelectAlert *alert = [[SelectAlert alloc] initWithTitle:title titles:titles selectIndex:selectIndex selectValue:selectValue showCloseButton:showCloseButton];
    return alert;
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = NavigationColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _titleLabel;
}

- (UIView *)alertView {
    if (!_alertView) {
        _alertView = [[UIView alloc] init];
        _alertView.backgroundColor = [UIColor whiteColor];
        _alertView.layer.cornerRadius = 8;
        _alertView.layer.masksToBounds = YES;
    }
    return _alertView;
}

- (UIButton *)closeButton {
    if (!_closeButton) {
        _closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _closeButton.backgroundColor = [UIColor colorWithRed:235/255.0 green:235/255.0 blue:235/255.0 alpha:1];
        [_closeButton setTitle:@"关闭" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor colorWithRed:0 green:127/255.0 blue:1 alpha:1] forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UITableView *)selectTableView {
    if (!_selectTableView) {
        _selectTableView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStyleGrouped];
        _selectTableView.delegate = self;
        _selectTableView.dataSource = self;
        _selectTableView.bounces = NO;
    }
    return _selectTableView;
}

- (instancetype)initWithTitle:(NSString *)title titles:(NSArray *)titles selectIndex:(SelectIndex)selectIndex selectValue:(SelectValue)selectValue showCloseButton:(BOOL)showCloseButton {
    if (self = [super init]) {
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        alertHeight = [UIScreen mainScreen].bounds.size.height / 2;
        buttonHeight = 40;
        self.haveSeletedIndex = 9999;
        self.titleLabel.text = title;
        _titles = titles;
        _selectIndex = [selectIndex copy];
        _selectValue = [selectValue copy];
        _showCloseButton = showCloseButton;
        [self addSubview:self.alertView];
        [self.alertView addSubview:self.titleLabel];
        [self.alertView addSubview:self.selectTableView];
        if (_showCloseButton) {
            [self.alertView addSubview:self.closeButton];
        }
        [self initUI];
        
        [self show];
    }
    return self;
}

- (void)show {
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.alertView.alpha = 0.0;
    [UIView animateWithDuration:0.05 animations:^{
        self.alertView.alpha = 1;
    }];
}

- (void)initUI {
    self.alertView.frame = CGRectMake(30, ([UIScreen mainScreen].bounds.size.height-alertHeight)/2.0, [UIScreen mainScreen].bounds.size.width-60, alertHeight);
    self.titleLabel.frame = CGRectMake(15, 0, _alertView.frame.size.width - 15, buttonHeight);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, buttonHeight, self.alertView.frame.size.width, 1)];
    lineView.backgroundColor = NavigationColor;
    [self.alertView addSubview:lineView];
    
    float reduceHeight = buttonHeight;
    if (_showCloseButton) {
        self.closeButton.frame = CGRectMake(0, _alertView.frame.size.height-buttonHeight, _alertView.frame.size.width, buttonHeight);
        reduceHeight = buttonHeight*2;
    }
    self.selectTableView.frame = CGRectMake(0, buttonHeight + 1, _alertView.frame.size.width, _alertView.frame.size.height-reduceHeight - 1);
}


#pragma UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return _titles.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section{
    return 0.00001f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section{
    return 0.0001;
}

- (UIView *)tableView:(UITableView *)tableView viewForFooterInSection:(NSInteger)section{
    UIView *view = [[UIView alloc] init];
    return view;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    float real = (alertHeight - buttonHeight)/(float)_titles.count;
    if (_showCloseButton) {
        real = (alertHeight - buttonHeight*2)/(float)_titles.count;
    }
    return real<=40?40:real;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectcell"];
    if (!cell) {
        cell = [[SelectAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectcell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    cell.titleLabel.text = _titles[indexPath.row];
    if (indexPath.row == self.haveSeletedIndex) {
        cell.selImageVIew.image = [UIImage imageNamed:@"jubao_anniu_sel"];
    }else{
        cell.selImageVIew.image = [UIImage imageNamed:@"jubao_anniu_nor"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (self.selectIndex) {
        self.selectIndex(indexPath.row);
    }
    if (self.selectValue) {
        self.selectValue(_titles[indexPath.row]);
    }
    
    [self closeAction];
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint pt = [touch locationInView:self];
    if (!CGRectContainsPoint([self.alertView frame], pt) && !_showCloseButton) {
        [self closeAction];
    }
}

- (void)closeAction {
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)dealloc {
//    NSLog(@"SelectAlert被销毁了");
}

#pragma mark -设置cell分割线顶格

-(void)viewDidLayoutSubviews
{
    if ([self.selectTableView respondsToSelector:@selector(setSeparatorInset:)]) {
        [self.selectTableView setSeparatorInset:UIEdgeInsetsMake(0,0,0,0)];
    }
    
    if ([self.selectTableView respondsToSelector:@selector(setLayoutMargins:)]) {
        [self.selectTableView setLayoutMargins:UIEdgeInsetsMake(0,0,0,0)];
    }
}

- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    
    if ([cell respondsToSelector:@selector(setSeparatorInset:)]) {
        [cell setSeparatorInset:UIEdgeInsetsZero];
    }
    
    if ([cell respondsToSelector:@selector(setLayoutMargins:)]) {
        [cell setLayoutMargins:UIEdgeInsetsZero];
    }
    
}

@end
