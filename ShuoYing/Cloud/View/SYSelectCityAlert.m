//
//  SYSelectCityAlert.m
//  ShuoYing
//
//  Created by 硕影 on 2017/2/20.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYSelectCityAlert.h"

@interface SelectCityAlertCell : UITableViewCell

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIImageView *selImageVIew;
@end

@implementation SelectCityAlertCell

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

@interface SYSelectCityAlert ()<UITableViewDelegate,UITableViewDataSource>

{
    float alertHeight;//弹框整体高度，默认250
    float buttonHeight;//按钮高度，默认40
    
    BOOL _isCity;//是否选择了省

    NSInteger _selectedProvince;//选择的省的下标
    NSInteger _selectedCity;//选择市的下标
    
    
    NSDictionary *_valueDic;
    
    NSDictionary *_lastTimeSelectedValue;
}

@property (nonatomic, strong) UIView *alertView;//弹框视图
@property (nonatomic, strong) UITableView *selectTableView;//选择列表

@property (nonatomic, strong) UILabel *titleLabel;

@property (nonatomic, strong) UIButton *closeButton;

@property (nonatomic, strong) UIButton *nextButton;

@property (nonatomic, strong) UIButton *actionButton;

@property (nonatomic, strong) NSMutableArray *titles;



@end

@implementation SYSelectCityAlert

+ (SYSelectCityAlert *)showWithTitle:(NSString *)title
                              titles:(NSArray *)titles
                         selectIndex:(SelectCityValue)selectIndex
               lastTimeSelectedValue:(NSDictionary *)lastTimeSelectedValue{
    SYSelectCityAlert *alert = [[SYSelectCityAlert alloc] initWithTitle:title titles:titles selectValue:selectIndex lastTimeSelectedValue:lastTimeSelectedValue];
    
    return alert;
}

- (instancetype)initWithTitle:(NSString *)title titles:(NSArray *)titles selectValue:(SelectCityValue)selectValue lastTimeSelectedValue:(NSDictionary *)lastTimeSelectedValue{
    if (self = [super init]) {
        _selectedProvince = 0;
        _selectedCity = 0;
        self.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:.4];
        alertHeight = [UIScreen mainScreen].bounds.size.height / 2;
        buttonHeight = 40;
        
        self.selecteValue = selectValue;
        _lastTimeSelectedValue = lastTimeSelectedValue;
        
        if (lastTimeSelectedValue != nil && lastTimeSelectedValue.count > 0) {
            NSString *province = [lastTimeSelectedValue objectForKey:@"province"];
            for (int i = 0; i < titles.count; i++) {
                NSDictionary *provinceDic = titles[i];
                if ([province isEqualToString:[provinceDic objectForKey:@"prov"]]) {
                    _selectedProvince = i;
                    break;
                }
            }
        }
        self.titleLabel.text = title;
        [self.titles addObjectsFromArray:titles];
        
        [self addSubview:self.alertView];
        [self.alertView addSubview:self.titleLabel];
        [self.alertView addSubview:self.selectTableView];
        
        [self.alertView addSubview:self.closeButton];
        [self.alertView addSubview:self.nextButton];
        
        [self initUI];
        
        [self show];
    }
    return self;
}

- (void)initUI {
    self.alertView.frame = CGRectMake(30, ([UIScreen mainScreen].bounds.size.height-alertHeight)/2.0, [UIScreen mainScreen].bounds.size.width-60, alertHeight);
    self.titleLabel.frame = CGRectMake(0, 0, _alertView.frame.size.width, buttonHeight);
    
    UIView *lineView = [[UIView alloc] initWithFrame:CGRectMake(0, buttonHeight, self.alertView.frame.size.width, 1)];
    lineView.backgroundColor = NavigationColor;
    [self.alertView addSubview:lineView];
    
    float reduceHeight = buttonHeight;

    self.selectTableView.frame = CGRectMake(0, buttonHeight + 1, _alertView.frame.size.width, _alertView.frame.size.height-reduceHeight * 2 - 1);
    
    
    UIView *lineView0 = [[UIView alloc] initWithFrame:CGRectMake(0, _alertView.frame.size.height-buttonHeight - 1, _alertView.frame.size.width, 1)];
    lineView0.backgroundColor = RGB(234, 234, 234);
    [self.alertView addSubview:lineView0];
    
    self.closeButton.frame = CGRectMake(0, _alertView.frame.size.height-buttonHeight + 1, (_alertView.frame.size.width - 1) / 2, buttonHeight - 1);
    reduceHeight = buttonHeight*2;
    
    UIView *lineView1 = [[UIView alloc] initWithFrame:CGRectMake(_alertView.frame.size.width / 2, _alertView.frame.size.height-buttonHeight + 1, 1, buttonHeight - 1)];
    lineView1.backgroundColor = RGB(234, 234, 234);
    [self.alertView addSubview:lineView1];
    
    self.nextButton.frame = CGRectMake(_alertView.frame.size.width / 2 + 1, _alertView.frame.size.height-buttonHeight + 1, (_alertView.frame.size.width - 1) / 2, buttonHeight - 1);
    
    self.actionButton.frame = CGRectMake(_alertView.frame.size.width / 2 + 1, _alertView.frame.size.height-buttonHeight + 1, (_alertView.frame.size.width - 1) / 2, buttonHeight - 1);
}

- (void)show {
    self.frame = CGRectMake(0, 0, [UIScreen mainScreen].bounds.size.width, [UIScreen mainScreen].bounds.size.height);
    [[UIApplication sharedApplication].keyWindow addSubview:self];
    
    self.alertView.alpha = 0.0;
    [UIView animateWithDuration:0.05 animations:^{
        self.alertView.alpha = 1;
    }];
}

#pragma UITableViewDelegate
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (_isCity) {
        return [[self.titles[_selectedProvince] objectForKey:@"city"] count];
    }else{
        return self.titles.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 40;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.000001;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.000001;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    SelectCityAlertCell *cell = [tableView dequeueReusableCellWithIdentifier:@"selectCitycell"];
    if (!cell) {
        cell = [[SelectCityAlertCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"selectCitycell"];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
    }
    
    cell.selImageVIew.image = [UIImage imageNamed:@"jubao_anniu_nor"];
    cell.titleLabel.text = @"";
    
    if (_isCity) {
        
        cell.titleLabel.text = [self.titles[_selectedProvince] objectForKey:@"city"][indexPath.row];
        if (indexPath.row == _selectedCity) {
            cell.selImageVIew.image = [UIImage imageNamed:@"jubao_anniu_sel"];
        }else{
            cell.selImageVIew.image = [UIImage imageNamed:@"jubao_anniu_nor"];
        }
        
    }else{
        if (indexPath.row == _selectedProvince) {
            cell.selImageVIew.image = [UIImage imageNamed:@"jubao_anniu_sel"];
        }else{
            cell.selImageVIew.image = [UIImage imageNamed:@"jubao_anniu_nor"];
        }
        cell.titleLabel.text = [self.titles[indexPath.row] objectForKey:@"prov"];
        
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (_isCity) {
        _selectedCity = indexPath.row;
        
        [self.selectTableView reloadData];
    }else{
        _selectedProvince = indexPath.row;
        
        [self.selectTableView reloadData];
    }

}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
//    UITouch *touch = [touches anyObject];
//    CGPoint pt = [touch locationInView:self];
//    if (!CGRectContainsPoint([self.alertView frame], pt) && !_showCloseButton) {
//        [self closeAction];
//    }
}

- (void)closeAction {
    [UIView animateWithDuration:0.1 animations:^{
        self.alpha = 0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

- (void)nextAction{
    if (_lastTimeSelectedValue != nil && _lastTimeSelectedValue.count > 0) {
        NSArray *cityArr = [self.titles[_selectedProvince] objectForKey:@"city"];
        for (int i = 0; i < cityArr.count; i++) {
            NSString *cityStr = cityArr[i];
            if ([[_lastTimeSelectedValue objectForKey:@"city"] isEqualToString:cityStr]) {
                _selectedCity = i;
                break;
            }
        }
    }
    
    _isCity = !_isCity;
    [self.selectTableView reloadData];
    [self.alertView addSubview:self.actionButton];
    [self.nextButton removeFromSuperview];
    
    _valueDic = @{@"province":[self.titles[_selectedProvince] objectForKey:@"prov"]};
}

- (void)doneAction{
    _valueDic = @{@"province":[self.titles[_selectedProvince] objectForKey:@"prov"], @"city":[self.titles[_selectedProvince] objectForKey:@"city"][_selectedCity]};
    [self closeAction];
    
    self.selecteValue(_valueDic);
    
    
}

- (UILabel *)titleLabel {
    if (!_titleLabel) {
        _titleLabel = [[UILabel alloc] init];
        _titleLabel.backgroundColor = [UIColor whiteColor];
        _titleLabel.textColor = NavigationColor;
        _titleLabel.font = [UIFont boldSystemFontOfSize:16];
        _titleLabel.textAlignment = NSTextAlignmentCenter;
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
        _closeButton.backgroundColor = [UIColor whiteColor];
        [_closeButton setTitle:@"取消" forState:UIControlStateNormal];
        [_closeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        _closeButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_closeButton addTarget:self action:@selector(closeAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _closeButton;
}

- (UIButton *)nextButton{
    if (!_nextButton) {
        _nextButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _nextButton.backgroundColor = [UIColor whiteColor];
        [_nextButton setTitle:@"确定" forState:UIControlStateNormal];
        [_nextButton setTitleColor:NavigationColor forState:UIControlStateNormal];
        _nextButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_nextButton addTarget:self action:@selector(nextAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _nextButton;
}

- (UIButton *)actionButton{
    if (!_actionButton) {
        _actionButton = [UIButton buttonWithType:UIButtonTypeCustom];
        _actionButton.backgroundColor = [UIColor whiteColor];
        [_actionButton setTitle:@"确定" forState:UIControlStateNormal];
        [_actionButton setTitleColor:NavigationColor forState:UIControlStateNormal];
        _actionButton.titleLabel.font = [UIFont systemFontOfSize:17];
        [_actionButton addTarget:self action:@selector(doneAction) forControlEvents:UIControlEventTouchUpInside];
    }
    return _actionButton;
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

- (NSMutableArray *)titles{
    if (!_titles) {
        _titles = [NSMutableArray arrayWithCapacity:0];
    }
    return _titles;
}

@end
