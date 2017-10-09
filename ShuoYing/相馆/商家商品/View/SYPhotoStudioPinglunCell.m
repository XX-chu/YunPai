//
//  SYPhotoStudioPinglunCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/24.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYPhotoStudioPinglunCell.h"
#import "SYCommentModel.h"
#import "XLPhotoBrowser.h"
@interface SYPhotoStudioPinglunCell ()<XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>

{
    NSArray *_img_min;
}

@property (weak, nonatomic) IBOutlet UIImageView *headerImageView;
@property (weak, nonatomic) IBOutlet UILabel *usernameLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;

@property (weak, nonatomic) IBOutlet UIImageView *pingjiaImageView1;
@property (weak, nonatomic) IBOutlet UIImageView *pingjiaImageView2;
@property (weak, nonatomic) IBOutlet UIImageView *pingjiaImageView3;
@property (weak, nonatomic) IBOutlet UIImageView *pingjiaImageView4;
@property (weak, nonatomic) IBOutlet UIImageView *pingjiaImageView5;
@property (weak, nonatomic) IBOutlet UILabel *pingjiaScoreLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pingjiaImageViewConstraintWidth1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pingjiaImageViewConstraintWidth2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pingjiaImageViewConstraintWidth3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pingjiaImageViewConstraintWidth4;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pingjiaImageViewConstraintWidth5;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *space1;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *space2;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *space3;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *space4;

@property (weak, nonatomic) IBOutlet UILabel *pinglunLabel;

@property (weak, nonatomic) IBOutlet UIView *pinglunPictureView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *pinglunPictureConstraintHeight;

@property (weak, nonatomic) IBOutlet UILabel *youyongLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *youyongConstraintWidth;

@property (weak, nonatomic) IBOutlet UILabel *wuyongLabel;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *wuyongConstraintWidth;


@end

@implementation SYPhotoStudioPinglunCell

- (void)setCommemtModel:(SYCommentModel *)commemtModel{
    _commemtModel = commemtModel;
    _img_min = _commemtModel.img_min;
    [self.headerImageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_commemtModel.head]] placeholderImage:NoPicture];
    self.usernameLabel.text = _commemtModel.nick;
    self.timeLabel.text = _commemtModel.date;
    
    float pingfen = [_commemtModel.ping floatValue];
    [self shezhipingfenWithFloat:pingfen];
    
    self.pinglunLabel.text = _commemtModel.info;
    
    if (_commemtModel.img_200.count > 0) {
        //图片宽度
        CGFloat pictureWidth = (kScreenWidth - 65 - 14 - 26) / 3;
        self.pinglunPictureConstraintHeight.constant = pictureWidth;
        if (_commemtModel.img_200.count < 4) {
            for (int i = 0 ; i < _commemtModel.img_200.count; i++) {
                UIImageView *imageView = [[UIImageView alloc] initWithFrame:CGRectMake(pictureWidth * i + i * 13, 0, pictureWidth, pictureWidth)];
                [imageView sd_setImageWithURL:[NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_commemtModel.img_200[i]]] placeholderImage:NoPicture];
                imageView.tag = i;
                UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapPicture:)];
                [imageView addGestureRecognizer:tap];
                imageView.userInteractionEnabled = YES;
                [self.pinglunPictureView addSubview:imageView];
            }
        }
        
    }else{
        self.pinglunPictureConstraintHeight.constant = 0;
    }
    
    NSString *youyongStr = [NSString stringWithFormat:@"有用%@",[_commemtModel.you stringValue]];
    self.youyongLabel.text = youyongStr;
    CGSize maxSize = [self.youyongLabel sizeThatFits:CGSizeMake(MAXFLOAT, 29)];
    if (maxSize.width > 46) {
        self.youyongConstraintWidth.constant = maxSize.width + 10;
    }else{
        self.youyongConstraintWidth.constant = 46;
    }
    if ([_commemtModel.isSelecteYou boolValue]) {
        self.youyongLabel.layer.borderColor = NavigationColor.CGColor;
        self.youyongLabel.layer.borderWidth = 1;
        self.youyongLabel.textColor = NavigationColor;
    }
    
    NSString *wuyongStr = [NSString stringWithFormat:@"无用%@",[_commemtModel.wu stringValue]];
    self.wuyongLabel.text = wuyongStr;
    CGSize maxSize1 = [self.wuyongLabel sizeThatFits:CGSizeMake(MAXFLOAT, 29)];
    if (maxSize1.width > 46) {
        self.wuyongConstraintWidth.constant = maxSize1.width + 10;
    }else{
        self.wuyongConstraintWidth.constant = 46;
    }
    if ([_commemtModel.isSelecteWu boolValue]) {
        self.wuyongLabel.layer.borderColor = NavigationColor.CGColor;
        self.wuyongLabel.layer.borderWidth = 1;
        self.wuyongLabel.textColor = NavigationColor;
    }
    
}

- (void)tapPicture:(UITapGestureRecognizer *)tap{
    if (_img_min.count > 0) {
        NSInteger count = _img_min.count;
        
        // 快速创建并进入浏览模式
        XLPhotoBrowser *browser = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:tap.view.tag imageCount:count datasource:self];
        
        browser.browserStyle = XLPhotoBrowserStyleIndexLabel;///< 修改底部pagecontrol的样式为系统样式,默认是弹性动画的样式
    }
    
}

#pragma mark    -   XLPhotoBrowserDatasource

/**
 *  返回指定位置的高清图片URL
 *
 *  @param browser 浏览器
 *  @param index   位置索引
 *
 *  @return 返回高清大图索引
 */
- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index
{
    NSString *imageUrl = _img_min[index];
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,imageUrl]];
}

#pragma mark    -   XLPhotoBrowserDelegate

- (void)photoBrowser:(XLPhotoBrowser *)browser clickActionSheetIndex:(NSInteger)actionSheetindex currentImageIndex:(NSInteger)currentImageIndex
{
    
}


- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
    self.headerImageView.layer.cornerRadius = 20;
    self.headerImageView.layer.masksToBounds = YES;
    
    self.youyongLabel.layer.cornerRadius = 14.5;
    self.youyongLabel.layer.masksToBounds = YES;
    self.youyongLabel.layer.borderColor = RGB(207, 207, 207).CGColor;
    self.youyongLabel.layer.borderWidth = 1;
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(youyongtap:)];
    [self.youyongLabel addGestureRecognizer:tap];
    self.youyongLabel.userInteractionEnabled = YES;

    
    self.wuyongLabel.layer.cornerRadius = 14.5;
    self.wuyongLabel.layer.masksToBounds = YES;
    self.wuyongLabel.layer.borderColor = RGB(207, 207, 207).CGColor;
    self.wuyongLabel.layer.borderWidth = 1;
    UITapGestureRecognizer *tap1 = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(wuyongtap:)];
    [self.wuyongLabel addGestureRecognizer:tap1];
    self.wuyongLabel.userInteractionEnabled = YES;
}

- (void)youyongtap:(UITapGestureRecognizer *)tap{
    if (self.youyongBlock) {
        self.youyongBlock();
    }
    self.wuyongLabel.userInteractionEnabled = NO;
    self.youyongLabel.userInteractionEnabled = NO;
}

- (void)wuyongtap:(UITapGestureRecognizer *)tap{
    if (self.wuyongBlock) {
        self.wuyongBlock();
    }
    self.wuyongLabel.userInteractionEnabled = NO;
    self.youyongLabel.userInteractionEnabled = NO;
}

- (void)shezhipingfenWithFloat:(float)pingfen{

    self.pingjiaScoreLabel.text = [NSString stringWithFormat:@"%.1f",pingfen];
    
    if (pingfen > 0.0 && pingfen < 1.0) {
        
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//        self.pingjiaImageViewConstraintWidth2.constant = 0;
//        self.pingjiaImageViewConstraintWidth3.constant = 0;
//        self.pingjiaImageViewConstraintWidth4.constant = 0;
//        self.pingjiaImageViewConstraintWidth5.constant = 0;
//        self.space1.constant = 0;
//        self.space2.constant = 0;
//        self.space3.constant = 0;
//        self.space4.constant = 0;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
        
    }else if (pingfen >= 1.0 && pingfen < 1.5){
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageViewConstraintWidth2.constant = 0;
//        self.pingjiaImageViewConstraintWidth3.constant = 0;
//        self.pingjiaImageViewConstraintWidth4.constant = 0;
//        self.pingjiaImageViewConstraintWidth5.constant = 0;
//        self.space1.constant = 0;
//        self.space2.constant = 0;
//        self.space3.constant = 0;
//        self.space4.constant = 0;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
        
    }else if (pingfen >= 1.5 && pingfen < 2.0){
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//        self.pingjiaImageViewConstraintWidth2.constant = 12;
//        self.pingjiaImageViewConstraintWidth3.constant = 0;
//        self.pingjiaImageViewConstraintWidth4.constant = 0;
//        self.pingjiaImageViewConstraintWidth5.constant = 0;
//        self.space1.constant = 4;
//        self.space2.constant = 0;
//        self.space3.constant = 0;
//        self.space4.constant = 0;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
        
    }else if (pingfen >= 2.0 && pingfen < 2.5){
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageViewConstraintWidth2.constant = 12;
//        self.pingjiaImageViewConstraintWidth3.constant = 0;
//        self.pingjiaImageViewConstraintWidth4.constant = 0;
//        self.pingjiaImageViewConstraintWidth5.constant = 0;
//        self.space1.constant = 4;
//        self.space2.constant = 0;
//        self.space3.constant = 0;
//        self.space4.constant = 0;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
        
    }else if (pingfen >= 2.5 && pingfen < 3.0){
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//        self.pingjiaImageViewConstraintWidth2.constant = 12;
//        self.pingjiaImageViewConstraintWidth3.constant = 12;
//        self.pingjiaImageViewConstraintWidth4.constant = 0;
//        self.pingjiaImageViewConstraintWidth5.constant = 0;
//        self.space1.constant = 4;
//        self.space2.constant = 4;
//        self.space3.constant = 0;
//        self.space4.constant = 0;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
        
    }else if (pingfen >= 3.0 && pingfen < 3.5){
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageViewConstraintWidth2.constant = 12;
//        self.pingjiaImageViewConstraintWidth3.constant = 12;
//        self.pingjiaImageViewConstraintWidth4.constant = 0;
//        self.pingjiaImageViewConstraintWidth5.constant = 0;
//        self.space1.constant = 4;
//        self.space2.constant = 4;
//        self.space3.constant = 0;
//        self.space4.constant = 0;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"pingjia_nor"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
        
    }else if (pingfen >= 3.5 && pingfen < 4.0){
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//        self.pingjiaImageViewConstraintWidth2.constant = 12;
//        self.pingjiaImageViewConstraintWidth3.constant = 12;
//        self.pingjiaImageViewConstraintWidth4.constant = 12;
//        self.pingjiaImageViewConstraintWidth5.constant = 0;
//        self.space1.constant = 4;
//        self.space2.constant = 4;
//        self.space3.constant = 4;
//        self.space4.constant = 0;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
        
    }else if (pingfen >= 4.0 && pingfen < 4.5){
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageViewConstraintWidth2.constant = 12;
//        self.pingjiaImageViewConstraintWidth3.constant = 12;
//        self.pingjiaImageViewConstraintWidth4.constant = 12;
//        self.pingjiaImageViewConstraintWidth5.constant = 0;
//        self.space1.constant = 4;
//        self.space2.constant = 4;
//        self.space3.constant = 4;
//        self.space4.constant = 0;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"pingjia_nor"];
        
    }else if (pingfen >= 4.5 && pingfen < 5.0){
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
//        self.pingjiaImageViewConstraintWidth2.constant = 12;
//        self.pingjiaImageViewConstraintWidth3.constant = 12;
//        self.pingjiaImageViewConstraintWidth4.constant = 12;
//        self.pingjiaImageViewConstraintWidth5.constant = 12;
//        self.space1.constant = 4;
//        self.space2.constant = 4;
//        self.space3.constant = 4;
//        self.space4.constant = 4;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji_half"];
        
    }else{
//        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji"];
//        self.pingjiaImageViewConstraintWidth2.constant = 12;
//        self.pingjiaImageViewConstraintWidth3.constant = 12;
//        self.pingjiaImageViewConstraintWidth4.constant = 12;
//        self.pingjiaImageViewConstraintWidth5.constant = 12;
//        self.space1.constant = 4;
//        self.space2.constant = 4;
//        self.space3.constant = 4;
//        self.space4.constant = 4;
        
        self.pingjiaImageView1.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView2.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView3.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView4.image = [UIImage imageNamed:@"PhotoShop_xingji"];
        self.pingjiaImageView5.image = [UIImage imageNamed:@"PhotoShop_xingji"];
    }
}

@end
