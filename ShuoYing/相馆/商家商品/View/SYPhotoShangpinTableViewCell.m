//
//  SYPhotoShangpinTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/24.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotoShangpinTableViewCell.h"
#import "SYProductListModel.h"

@interface SYPhotoShangpinTableViewCell ()

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *shangpinName;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *yuanjiaPriceLabel;
@property (weak, nonatomic) IBOutlet UILabel *yimaiLabel;

@end

@implementation SYPhotoShangpinTableViewCell

- (void)setModel:(SYProductListModel *)model{
    _model = model;
    
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_model.img_200]] placeholderImage:NoPicture options:SDWebImageProgressiveDownload progress:^(NSInteger receivedSize, NSInteger expectedSize, NSURL * _Nullable targetURL) {
        
    } completed:^(UIImage * _Nullable image, NSError * _Nullable error, SDImageCacheType cacheType, NSURL * _Nullable imageURL) {
        
    }];
    
    
    self.shangpinName.text = _model.title;
    
    self.priceLabel.text = [NSString stringWithFormat:@"¥%@",_model.money];
    

    NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] init];
    if ([_model.line integerValue] == 1) {
        //线上
        attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"原价¥%@",_model.fee]];
    }else{
        attStr = [[NSMutableAttributedString alloc] initWithString:[NSString stringWithFormat:@"门市价¥%@",_model.fee]];
    }
    [attStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlinePatternSolid | NSUnderlineStyleSingle) range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSBaselineOffsetAttributeName value:@(0) range:NSMakeRange(0, attStr.length)];
    [attStr addAttribute:NSStrikethroughColorAttributeName value:[UIColor colorWithRed:138/255.0 green:138/255.0 blue:138/255.0 alpha:1] range:NSMakeRange(0, attStr.length)];
    self.yuanjiaPriceLabel.attributedText = attStr;
    
    NSInteger num = [_model.num integerValue];
    self.yimaiLabel.text = [NSString stringWithFormat:@"已售%ld",num];
    
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
