//
//  SYPhotoNameTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/24.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotoNameTableViewCell.h"
#import "SYPhotoNameModel.h"

@interface SYPhotoNameTableViewCell ()
@property (weak, nonatomic) IBOutlet UILabel *photoName;
@property (weak, nonatomic) IBOutlet UILabel *photoInfos;
@property (weak, nonatomic) IBOutlet UILabel *photoAddress;
@property (weak, nonatomic) IBOutlet UIButton *mapBtn;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;
@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;

@property (weak, nonatomic) IBOutlet UIImageView *miaoshuImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *miaoshuImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *miaoshuImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *miaoshuImageView4;
@property (weak, nonatomic) IBOutlet UIImageView *miaoshuImageView5;
@property (weak, nonatomic) IBOutlet UILabel *miaoshuScoreLabe;
@property (weak, nonatomic) IBOutlet UILabel *miaoshuNoScoreLabel;

@property (weak, nonatomic) IBOutlet UIImageView *wuliuImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *wuliuImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *wuliuImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *wuliuImageView4;
@property (weak, nonatomic) IBOutlet UIImageView *wuliuImageView5;
@property (weak, nonatomic) IBOutlet UILabel *wuliuScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *wuliuNoScoreLabel;

@property (weak, nonatomic) IBOutlet UIImageView *maijiaImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *maijiaImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *maijiaImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *maijiaImageView4;
@property (weak, nonatomic) IBOutlet UIImageView *maijiaImageView5;
@property (weak, nonatomic) IBOutlet UILabel *maijiaScoreLabel;
@property (weak, nonatomic) IBOutlet UILabel *maijiaNoScoreLabel;

@end

@implementation SYPhotoNameTableViewCell

- (void)setPhotoNameModel:(SYPhotoNameModel *)photoNameModel{
    _photoNameModel = photoNameModel;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_photoNameModel.img]] placeholderImage:NoPicture];
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(headImageViewSelecte:)];
    self.headerImageView.userInteractionEnabled = YES;
    [self.headerImageView addGestureRecognizer:tap];
    
    self.photoName.text = _photoNameModel.name;
    self.photoInfos.text = _photoNameModel.info;
    
    self.photoAddress.text = _photoNameModel.address;
    
    float miaoshu = [_photoNameModel.miaoshu floatValue];
    if (miaoshu < 0.0001) {
        self.miaoshuImageView1.hidden = YES;
        self.miaoshuImageView2.hidden = YES;
        self.miaoshuImageView3.hidden = YES;
        self.miaoshuImageView4.hidden = YES;
        self.miaoshuImageView5.hidden = YES;
        self.miaoshuScoreLabe.hidden = YES;
        self.miaoshuNoScoreLabel.hidden = NO;
    }else{
        self.miaoshuImageView1.hidden = NO;
        self.miaoshuImageView2.hidden = NO;
        self.miaoshuImageView3.hidden = NO;
        self.miaoshuImageView4.hidden = NO;
        self.miaoshuImageView5.hidden = NO;
        self.miaoshuScoreLabe.hidden = NO;
        self.miaoshuNoScoreLabel.hidden = YES;
        self.miaoshuScoreLabe.text = [NSString stringWithFormat:@"%.1f",miaoshu];
        if (miaoshu > 0.0 && miaoshu < 1.0) {
            
//            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.miaoshuImageView2.hidden = YES;
//            self.miaoshuImageView3.hidden = YES;
//            self.miaoshuImageView4.hidden = YES;
//            self.miaoshuImageView5.hidden = YES;
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (miaoshu >= 1.0 && miaoshu < 1.5){
//            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView2.hidden = YES;
//            self.miaoshuImageView3.hidden = YES;
//            self.miaoshuImageView4.hidden = YES;
//            self.miaoshuImageView5.hidden = YES;
            
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (miaoshu >= 1.5 && miaoshu < 2.0){
//            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.miaoshuImageView3.hidden = YES;
//            self.miaoshuImageView4.hidden = YES;
//            self.miaoshuImageView5.hidden = YES;
            
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (miaoshu >= 2.0 && miaoshu < 2.5){
//            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView3.hidden = YES;
//            self.miaoshuImageView4.hidden = YES;
//            self.miaoshuImageView5.hidden = YES;
            
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (miaoshu >= 2.5 && miaoshu < 3.0){
//            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.miaoshuImageView4.hidden = YES;
//            self.miaoshuImageView5.hidden = YES;
            
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (miaoshu >= 3.0 && miaoshu < 3.5){
//            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView4.hidden = YES;
//            self.miaoshuImageView5.hidden = YES;
            
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (miaoshu >= 3.5 && miaoshu < 4.0){
//            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.miaoshuImageView5.hidden = YES;
            
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (miaoshu >= 4.0 && miaoshu < 4.5){
//            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView5.hidden = YES;
            
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
            
        }else if (miaoshu >= 4.5 && miaoshu < 5.0){
//            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.miaoshuImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            
        }else{
            self.miaoshuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.miaoshuImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        }
    }
    
    float wuliu = [_photoNameModel.wuliu floatValue];
    if (wuliu < 0.0001) {
        self.wuliuImageView1.hidden = YES;
        self.wuliuImageView2.hidden = YES;
        self.wuliuImageView3.hidden = YES;
        self.wuliuImageView4.hidden = YES;
        self.wuliuImageView5.hidden = YES;
        self.wuliuScoreLabel.hidden = YES;
        self.wuliuNoScoreLabel.hidden = NO;
    }else{
        self.wuliuImageView1.hidden = NO;
        self.wuliuImageView2.hidden = NO;
        self.wuliuImageView3.hidden = NO;
        self.wuliuImageView4.hidden = NO;
        self.wuliuImageView5.hidden = NO;
        self.wuliuScoreLabel.hidden = NO;
        self.wuliuNoScoreLabel.hidden = YES;
        self.wuliuScoreLabel.text = [NSString stringWithFormat:@"%.1f",wuliu];
        if (wuliu > 0.0 && wuliu < 1.0) {
            
//            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.wuliuImageView2.hidden = YES;
//            self.wuliuImageView3.hidden = YES;
//            self.wuliuImageView4.hidden = YES;
//            self.wuliuImageView5.hidden = YES;
            
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (wuliu >= 1.0 && wuliu < 1.5){
//            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView2.hidden = YES;
//            self.wuliuImageView3.hidden = YES;
//            self.wuliuImageView4.hidden = YES;
//            self.wuliuImageView5.hidden = YES;
            
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (wuliu >= 1.5 && wuliu < 2.0){
//            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.wuliuImageView3.hidden = YES;
//            self.wuliuImageView4.hidden = YES;
//            self.wuliuImageView5.hidden = YES;
            
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (wuliu >= 2.0 && wuliu < 2.5){
//            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView3.hidden = YES;
//            self.wuliuImageView4.hidden = YES;
//            self.wuliuImageView5.hidden = YES;
            
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (wuliu >= 2.5 && wuliu < 3.0){
//            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.wuliuImageView4.hidden = YES;
//            self.wuliuImageView5.hidden = YES;
            
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (wuliu >= 3.0 && wuliu < 3.5){
//            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView4.hidden = YES;
//            self.wuliuImageView5.hidden = YES;
            
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (wuliu >= 3.5 && wuliu < 4.0){
//            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.wuliuImageView5.hidden = YES;
            
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (wuliu >= 4.0 && wuliu < 4.5){
//            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView5.hidden = YES;
            
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (wuliu >= 4.5 && wuliu < 5.0){
//            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.wuliuImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            
        }else{
            self.wuliuImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.wuliuImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        }
    }
    
    float fuwu = [_photoNameModel.fuwu floatValue];
    if (fuwu < 0.0001) {
        self.maijiaImageView1.hidden = YES;
        self.maijiaImageView2.hidden = YES;
        self.maijiaImageView3.hidden = YES;
        self.maijiaImageView4.hidden = YES;
        self.maijiaImageView5.hidden = YES;
        self.maijiaScoreLabel.hidden = YES;
        self.maijiaNoScoreLabel.hidden = NO;
    }else{
        self.maijiaImageView1.hidden = NO;
        self.maijiaImageView2.hidden = NO;
        self.maijiaImageView3.hidden = NO;
        self.maijiaImageView4.hidden = NO;
        self.maijiaImageView5.hidden = NO;
        self.maijiaScoreLabel.hidden = NO;
        self.maijiaNoScoreLabel.hidden = YES;
        self.maijiaScoreLabel.text = [NSString stringWithFormat:@"%.1f",fuwu];
        if (fuwu > 0.0 && fuwu < 1.0) {
            
//            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.maijiaImageView2.hidden = YES;
//            self.maijiaImageView3.hidden = YES;
//            self.maijiaImageView4.hidden = YES;
//            self.maijiaImageView5.hidden = YES;
            
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (fuwu >= 1.0 && fuwu < 1.5){
//            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView2.hidden = YES;
//            self.maijiaImageView3.hidden = YES;
//            self.maijiaImageView4.hidden = YES;
//            self.maijiaImageView5.hidden = YES;
            
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (fuwu >= 1.5 && fuwu < 2.0){
//            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.maijiaImageView3.hidden = YES;
//            self.maijiaImageView4.hidden = YES;
//            self.maijiaImageView5.hidden = YES;
            
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (fuwu >= 2.0 && fuwu < 2.5){
//            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView3.hidden = YES;
//            self.maijiaImageView4.hidden = YES;
//            self.maijiaImageView5.hidden = YES;
            
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (fuwu >= 2.5 && fuwu < 3.0){
//            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//            self.maijiaImageView4.hidden = YES;
//            self.maijiaImageView5.hidden = YES;
            
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (fuwu >= 3.0 && fuwu < 3.5){
//            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView4.hidden = YES;
//            self.maijiaImageView5.hidden = YES;
            
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (fuwu >= 3.5 && fuwu < 4.0){
//            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
            self.maijiaImageView5.hidden = YES;
        }else if (fuwu >= 4.0 && fuwu < 4.5){
//            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView5.hidden = YES;
            
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
            
        }else if (fuwu >= 4.5 && fuwu < 5.0){
//            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//            self.maijiaImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
            
        }else{
            self.maijiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
            self.maijiaImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        }
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    self.miaoshuNoScoreLabel.hidden = YES;
    self.wuliuNoScoreLabel.hidden = YES;
    self.maijiaNoScoreLabel.hidden = YES;
}

- (void)headImageViewSelecte:(UITapGestureRecognizer *)tap{
    if (self.imgBlock) {
        self.imgBlock();
    }
}

- (IBAction)mapAction:(UIButton *)sender {
    if (self.mapBlock) {
        self.mapBlock();
    }
}

- (IBAction)callAction:(UIButton *)sender {
    if (self.callblock) {
        self.callblock();
    }
}

@end
