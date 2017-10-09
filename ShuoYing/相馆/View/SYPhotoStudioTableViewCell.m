//
//  SYPhotoStudioTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/3/23.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotoStudioTableViewCell.h"
#import "SYPhotoStudioModel.h"

@interface SYPhotoStudioTableViewCell ()
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *photoStudioName;
@property (weak, nonatomic) IBOutlet UILabel *wupingfenLabel;
@property (weak, nonatomic) IBOutlet UIView *youPingfenView;
@property (weak, nonatomic) IBOutlet UILabel *photoStudioType;
@property (weak, nonatomic) IBOutlet UILabel *juliLabel;

@property (weak, nonatomic) IBOutlet UIImageView *starImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView4;
@property (weak, nonatomic) IBOutlet UIImageView *starImageView5;
@property (weak, nonatomic) IBOutlet UILabel *fenshuLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starImageViewWidthConstraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starImageViewWidthConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starImageViewWidthConstraint3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starImageViewWidthConstraint4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starImageViewWidthConstraint5;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starSpaceConstraint1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starSpaceConstraint2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starSpaceConstraint3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *starSpaceConstraint4;

@end

@implementation SYPhotoStudioTableViewCell

- (void)setPhotoStudioModel:(SYPhotoStudioModel *)photoStudioModel{
    _photoStudioModel = photoStudioModel;
    
    [self.headImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl, _photoStudioModel.head]] placeholderImage:[UIImage imageNamed:@"shangchuan_wode_wutupian"]];
    
    self.photoStudioName.text = _photoStudioModel.name;
    
    self.photoStudioType.text = _photoStudioModel.type;
    
    self.juliLabel.text = [NSString stringWithFormat:@"距您%.1fkm",[_photoStudioModel.juli floatValue]];

    if (!_photoStudioModel.ping || _photoStudioModel.ping == nil || [_photoStudioModel.ping isKindOfClass:[NSNull class]] || [_photoStudioModel.ping floatValue] == 0.0) {
        self.youPingfenView.hidden = YES;
        self.wupingfenLabel.hidden = NO;
        self.wupingfenLabel.text = @"暂无评分";
    }else{
        self.youPingfenView.hidden = NO;
        self.wupingfenLabel.hidden = YES;
        float pingfen = [_photoStudioModel.ping floatValue];
        self.fenshuLabel.text = [NSString stringWithFormat:@"%.1f",pingfen];

        if (pingfen > 0.0 && pingfen < 1.0) {
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.starImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.starImageViewWidthConstraint2.constant = 0;
//            self.starImageViewWidthConstraint3.constant = 0;
//            self.starImageViewWidthConstraint4.constant = 0;
//            self.starImageViewWidthConstraint5.constant = 0;
//            self.starSpaceConstraint1.constant = 0;
//            self.starSpaceConstraint2.constant = 0;
//            self.starSpaceConstraint3.constant = 0;
//            self.starSpaceConstraint4.constant = 0;
        }else if (pingfen >= 1.0 && pingfen < 1.5){
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageViewWidthConstraint2.constant = 0;
//            self.starImageViewWidthConstraint3.constant = 0;
//            self.starImageViewWidthConstraint4.constant = 0;
//            self.starImageViewWidthConstraint5.constant = 0;
//            self.starSpaceConstraint1.constant = 0;
//            self.starSpaceConstraint2.constant = 0;
//            self.starSpaceConstraint3.constant = 0;
//            self.starSpaceConstraint4.constant = 0;
        }else if (pingfen >= 1.5 && pingfen < 2.0){
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.starImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.starImageViewWidthConstraint2.constant = 15;
//            self.starImageViewWidthConstraint3.constant = 0;
//            self.starImageViewWidthConstraint4.constant = 0;
//            self.starImageViewWidthConstraint5.constant = 0;
//            self.starSpaceConstraint1.constant = 2;
//            self.starSpaceConstraint2.constant = 0;
//            self.starSpaceConstraint3.constant = 0;
//            self.starSpaceConstraint4.constant = 0;
        }else if (pingfen >= 2.0 && pingfen < 2.5){
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageViewWidthConstraint2.constant = 15;
//            self.starImageViewWidthConstraint3.constant = 0;
//            self.starImageViewWidthConstraint4.constant = 0;
//            self.starImageViewWidthConstraint5.constant = 0;
//            self.starSpaceConstraint1.constant = 2;
//            self.starSpaceConstraint2.constant = 0;
//            self.starSpaceConstraint3.constant = 0;
//            self.starSpaceConstraint4.constant = 0;
        }else if (pingfen >= 2.5 && pingfen < 3.0){
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.starImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.starImageViewWidthConstraint2.constant = 15;
//            self.starImageViewWidthConstraint3.constant = 15;
//            self.starImageViewWidthConstraint4.constant = 0;
//            self.starImageViewWidthConstraint5.constant = 0;
//            self.starSpaceConstraint1.constant = 2;
//            self.starSpaceConstraint2.constant = 2;
//            self.starSpaceConstraint3.constant = 0;
//            self.starSpaceConstraint4.constant = 0;
        }else if (pingfen >= 3.0 && pingfen < 3.5){
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.starImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageViewWidthConstraint2.constant = 15;
//            self.starImageViewWidthConstraint3.constant = 15;
//            self.starImageViewWidthConstraint4.constant = 0;
//            self.starImageViewWidthConstraint5.constant = 0;
//            self.starSpaceConstraint1.constant = 2;
//            self.starSpaceConstraint2.constant = 2;
//            self.starSpaceConstraint3.constant = 0;
//            self.starSpaceConstraint4.constant = 0;
        }else if (pingfen >= 3.5 && pingfen < 4.0){
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.starImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.starImageViewWidthConstraint2.constant = 15;
//            self.starImageViewWidthConstraint3.constant = 15;
//            self.starImageViewWidthConstraint4.constant = 15;
//            self.starImageViewWidthConstraint5.constant = 0;
//            self.starSpaceConstraint1.constant = 2;
//            self.starSpaceConstraint2.constant = 2;
//            self.starSpaceConstraint3.constant = 2;
//            self.starSpaceConstraint4.constant = 0;
        }else if (pingfen >= 4.0 && pingfen < 4.5){
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageViewWidthConstraint2.constant = 15;
//            self.starImageViewWidthConstraint3.constant = 15;
//            self.starImageViewWidthConstraint4.constant = 15;
//            self.starImageViewWidthConstraint5.constant = 0;
//            self.starSpaceConstraint1.constant = 2;
//            self.starSpaceConstraint2.constant = 2;
//            self.starSpaceConstraint3.constant = 2;
//            self.starSpaceConstraint4.constant = 0;
        }else if (pingfen >= 4.5 && pingfen < 5.0){
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.starImageViewWidthConstraint2.constant = 15;
//            self.starImageViewWidthConstraint3.constant = 15;
//            self.starImageViewWidthConstraint4.constant = 15;
//            self.starImageViewWidthConstraint5.constant = 15;
//            self.starSpaceConstraint1.constant = 2;
//            self.starSpaceConstraint2.constant = 2;
//            self.starSpaceConstraint3.constant = 2;
//            self.starSpaceConstraint4.constant = 2;
        }else{
            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.starImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            
//            self.starImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.starImageViewWidthConstraint2.constant = 15;
//            self.starImageViewWidthConstraint3.constant = 15;
//            self.starImageViewWidthConstraint4.constant = 15;
//            self.starImageViewWidthConstraint5.constant = 15;
//            self.starSpaceConstraint1.constant = 2;
//            self.starSpaceConstraint2.constant = 2;
//            self.starSpaceConstraint3.constant = 2;
//            self.starSpaceConstraint4.constant = 2;
        }
    }
    
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.youPingfenView.hidden = YES;
    self.wupingfenLabel.hidden = YES;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
