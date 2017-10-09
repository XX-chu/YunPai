//
//  SYAddressTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYAddressTableViewCell.h"
#import "SYAddressModel.h"

@implementation SYAddressTableViewCell

- (void)setAddressModel:(SYAddressModel *)addressModel{
    _addressModel = addressModel;
    
    self.nameLabel.text = _addressModel.name;
    NSString *zone = [_addressModel.zone stringByReplacingOccurrencesOfString:@" " withString:@""];
    NSString *address = _addressModel.address;
    self.addressLabel.text = [NSString stringWithFormat:@"%@%@",zone,address];
    self.phoneLabel.text = _addressModel.tel;
    
    [self.editBtn setTitle:@"编辑" forState:UIControlStateNormal];
    [self.editBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    
    [self.deleteBtn setTitle:@"删除" forState:UIControlStateNormal];
    [self.deleteBtn setTitleColor:NavigationColor forState:UIControlStateNormal];
    
    if ([_addressModel.state integerValue] == 1) {
        //默认地址
        [self.isDefauleBtn setTitle:@"默认地址" forState:UIControlStateSelected];
        [self.isDefauleBtn setTitleColor:NavigationColor forState:UIControlStateSelected];
        self.isDefauleBtn.selected = YES;
    }else{
        [self.isDefauleBtn setTitle:@"设为默认" forState:UIControlStateNormal];
        [self.isDefauleBtn setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
        self.isDefauleBtn.selected = NO;
    }
}

- (IBAction)editAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedEditOrDeleteBtn:)]) {
        [_delegate didSelectedEditOrDeleteBtn:sender];
        
    }
}

- (IBAction)deleteAction:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedEditOrDeleteBtn:)]) {
        [_delegate didSelectedEditOrDeleteBtn:sender];
    }
}

- (IBAction)isDefaultBtn:(UIButton *)sender {
    if (_delegate && [_delegate respondsToSelector:@selector(didSelectedIsDefaultBtn:)]) {
        [_delegate didSelectedIsDefaultBtn:sender];
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.selectionStyle = UITableViewCellSelectionStyleNone;

}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
