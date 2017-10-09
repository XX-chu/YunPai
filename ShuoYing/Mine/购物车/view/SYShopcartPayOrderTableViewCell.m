//
//  SYShopcartPayOrderTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/5/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYShopcartPayOrderTableViewCell.h"
#import "SYShopcartShangpinModel.h"

@interface SYShopcartPayOrderTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *shangpinshuxingLabel;
@property (weak, nonatomic) IBOutlet UIButton *selectePhotoBtn;


@end

@implementation SYShopcartPayOrderTableViewCell

- (void)setModel:(SYShopcartShangpinModel *)model{
    _model = model;
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,model.img_200]] placeholderImage:NoPicture];
    
    self.contentLabel.text = model.title;
    self.shangpinshuxingLabel.text = [NSString stringWithFormat:@"%@",_model.spce];
    
    float money = [model.money floatValue] / 100;
    self.priceLabel.text = [NSString stringWithFormat:@"¥%.2f",money];
    self.numLabel.text = [NSString stringWithFormat:@"X%@",[model.num stringValue]];
    if ([model.upimg integerValue] > 0) {
        self.selectePhotoView.hidden = NO;
        self.selectePhotoHeightConstaint.constant = 46;
    }else{
        self.selectePhotoView.hidden = YES;
        self.selectePhotoHeightConstaint.constant = 0;
    }
    
    if ([model.upimg integerValue] * [model.num integerValue] == [model.c_img integerValue]) {
        //已经上传完毕
        self.haveSelectePhotoCountLabel.text = @"已选好";
        self.haveSelectePhotoCountLabel.textColor = [UIColor lightGrayColor];
    }else{
        NSInteger count = [model.upimg integerValue] * [model.num integerValue] - [model.c_img integerValue];
        self.haveSelectePhotoCountLabel.text = [NSString stringWithFormat:@"还有%ld张照片没选",count];
        self.haveSelectePhotoCountLabel.textColor = NavigationColor;
    }
}
- (IBAction)selecteAction:(UIButton *)sender {
    if (self.block) {
        self.block();
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
