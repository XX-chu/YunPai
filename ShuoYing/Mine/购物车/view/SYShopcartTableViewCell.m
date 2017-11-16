//
//  SYShopcartTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/3.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYShopcartTableViewCell.h"
#import "SYShopcartShangpinModel.h"

@interface SYShopcartTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *selectedImageView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *yuanjiaLabel;
@property (weak, nonatomic) IBOutlet UIButton *deleteBtn;
@property (weak, nonatomic) IBOutlet UILabel *shangpinshuxingLabel;

@property (weak, nonatomic) IBOutlet UIButton *addBtn;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *minutBtn;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBtnConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *addBtnWidthConstraint;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *countLabelWidthConstraint;
@property (weak, nonatomic) IBOutlet UILabel *shixiaoLabel;

@end

@implementation SYShopcartTableViewCell

- (void)setShangpinModel:(SYShopcartShangpinModel *)shangpinModel{
    _shangpinModel = shangpinModel;
    if ([shangpinModel.state integerValue] == 0) {
        //失效
        self.selectedImageView.hidden = YES;
        self.shixiaoLabel.hidden = NO;
        //加减删除按钮不能用
        [self.addBtn setUserInteractionEnabled:NO];
        [self.minutBtn setUserInteractionEnabled:NO];
    }else{
        self.selectedImageView.hidden = NO;
        self.shixiaoLabel.hidden = YES;
        [self.addBtn setUserInteractionEnabled:YES];
        [self.minutBtn setUserInteractionEnabled:YES];
        [self.deleteBtn setUserInteractionEnabled:YES];
    }
    if ([shangpinModel.isSelected boolValue]) {
        self.selectedImageView.image = [UIImage imageNamed:@"gouwuche_icon_sel"];
    }else{
        self.selectedImageView.image = [UIImage imageNamed:@"gouwuche_icon_nor"];
    }
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,shangpinModel.img_200]] placeholderImage:NoPicture];
    
    self.contentLabel.text = shangpinModel.title;
    self.shangpinshuxingLabel.text = [NSString stringWithFormat:@"%@",shangpinModel.spce];
    float money = [shangpinModel.money floatValue] / 100;
    self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",money];
    
    float fee = [shangpinModel.fee floatValue] / 100;
    self.yuanjiaLabel.text = [NSString stringWithFormat:@"原价¥%.2f",fee];
    
    self.countLabel.text = [shangpinModel.num stringValue];
}

- (void)setIsEdit:(BOOL)isEdit{
    _isEdit = isEdit;
    if (isEdit) {
        self.selectedImageView.hidden = NO;
        self.shixiaoLabel.hidden = YES;
        [self.addBtn setUserInteractionEnabled:NO];
        [self.minutBtn setUserInteractionEnabled:NO];
    }else{
        if ([self.shangpinModel.state integerValue] == 0) {
            //失效
            self.selectedImageView.hidden = YES;
            self.shixiaoLabel.hidden = NO;
            //加减删除按钮不能用
            [self.addBtn setUserInteractionEnabled:NO];
            [self.minutBtn setUserInteractionEnabled:NO];
        }else{
            self.selectedImageView.hidden = NO;
            self.shixiaoLabel.hidden = YES;
            [self.addBtn setUserInteractionEnabled:YES];
            [self.minutBtn setUserInteractionEnabled:YES];
            [self.deleteBtn setUserInteractionEnabled:YES];
        }

    }
    
}

- (IBAction)deleteAction:(UIButton *)sender {
    if (self.deleteBlock) {
        self.deleteBlock(1);
    }
}

- (IBAction)addAction:(UIButton *)sender {
    if (self.addBlock) {
        self.addBlock(1);
    }
}

- (IBAction)minutAction:(UIButton *)sender {
    if (self.minutBlock) {
        self.minutBlock(1);
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.deleteBtn.hidden = YES;
    if (kScreenWidth > 320 && kScreenWidth < 374) {
        //5s
        self.addBtnConstraint.constant = 20;
        self.addBtnConstraint.constant = 30;
        self.countLabelWidthConstraint.constant = 40;
        self.contentLabel.font = [UIFont systemFontOfSize:11];
        
    }else if (kScreenWidth >= 374 && kScreenWidth < 413){
        self.addBtnConstraint.constant = 25;
        self.addBtnConstraint.constant = 35;
        self.countLabelWidthConstraint.constant = 50;
        self.contentLabel.font = [UIFont systemFontOfSize:13];
    }else if (kScreenWidth >= 413){
        self.addBtnConstraint.constant = 30;
        self.addBtnConstraint.constant = 40;
        self.countLabelWidthConstraint.constant = 56;
        self.contentLabel.font = [UIFont systemFontOfSize:15];
    }
    
    [self.deleteBtn setAdjustsImageWhenHighlighted:NO];
    [self.addBtn setAdjustsImageWhenHighlighted:NO];
    [self.minutBtn setAdjustsImageWhenHighlighted:NO];
    
    self.selectedImageView.hidden = NO;
    self.shixiaoLabel.hidden = YES;
    self.shixiaoLabel.layer.cornerRadius = 5;
    self.shixiaoLabel.backgroundColor = HexRGB(0xa2a2a2);
    self.shixiaoLabel.layer.masksToBounds = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
