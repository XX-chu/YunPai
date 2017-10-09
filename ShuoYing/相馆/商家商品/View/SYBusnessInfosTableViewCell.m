//
//  SYBusnessInfosTableViewCell.m
//  ShuoYing
//
//  Created by 硕影 on 2017/4/26.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBusnessInfosTableViewCell.h"
#import "SDCycleScrollView.h"
#import "SYBusnessInfosModel.h"
@interface SYBusnessInfosTableViewCell ()<SDCycleScrollViewDelegate, XLPhotoBrowserDelegate, XLPhotoBrowserDatasource>
{
    NSArray *_imgs;
}
@property (weak, nonatomic) IBOutlet UIView *bannerView;
@property (weak, nonatomic) IBOutlet UILabel *shangpinName;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UIButton *callBtn;

@property (nonatomic, strong) SDCycleScrollView *bannerView1;

@property (weak, nonatomic) IBOutlet UILabel *addressLabel;
@property (weak, nonatomic) IBOutlet UIButton *addressBtn;

@end

@implementation SYBusnessInfosTableViewCell

- (void)setInfosModel:(SYBusnessInfosModel *)infosModel{
    _infosModel = infosModel;
    _imgs = _infosModel.imgs;
    [self.bannerView addSubview:self.bannerView1];
    NSMutableArray *imagesArr = [NSMutableArray arrayWithCapacity:0];
    for (NSString *str in _imgs) {
        NSString *imgUrl = [NSString stringWithFormat:@"%@%@",ImgUrl,str];
        [imagesArr addObject:imgUrl];
    }
    self.bannerView1.imageURLStringsGroup = imagesArr;
    
    self.shangpinName.text = _infosModel.title;
    if ([_infosModel.line integerValue] == 1) {
        //线上
        NSString *price = [NSString stringWithFormat:@"¥%@    原价¥%@",_infosModel.money_min,_infosModel.fee_min];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:price
        ];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, _infosModel.money_min.length + 1)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0xff5b01) range:NSMakeRange(0, _infosModel.money_min.length + 1)];
        
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 3)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x828282) range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 3)];
        [attStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 3)];
        [attStr addAttribute:NSBaselineOffsetAttributeName value:@(0) range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 3)];
        [attStr addAttribute:NSStrokeColorAttributeName value:HexRGB(0x828282) range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 3)];
        self.priceLabel.attributedText = attStr;
        
    }else{
        NSString *price = [NSString stringWithFormat:@"¥%@    门市价¥%@",_infosModel.money_min,_infosModel.fee_min];
        NSMutableAttributedString *attStr = [[NSMutableAttributedString alloc] initWithString:price
                                             ];
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:16] range:NSMakeRange(0, _infosModel.money_min.length + 1)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0xff5b01) range:NSMakeRange(0, _infosModel.money_min.length + 1)];
        
        [attStr addAttribute:NSFontAttributeName value:[UIFont systemFontOfSize:12] range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 4)];
        [attStr addAttribute:NSForegroundColorAttributeName value:HexRGB(0x828282) range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 4)];
        [attStr addAttribute:NSStrikethroughStyleAttributeName value:@(NSUnderlineStyleSingle) range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 4)];
        [attStr addAttribute:NSBaselineOffsetAttributeName value:@(0) range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 4)];

        [attStr addAttribute:NSStrokeColorAttributeName value:HexRGB(0x828282) range:NSMakeRange(_infosModel.money_min.length + 5, _infosModel.fee_min.length + 4)];
        self.priceLabel.attributedText = attStr;
        
        self.addressLabel.text = _infosModel.address;
    }
}

- (void)awakeFromNib {
    [super awakeFromNib];
    
}

- (IBAction)callAction:(UIButton *)sender {
    if (self.callBlock) {
        self.callBlock();
    }
}
- (IBAction)addressAction:(UIButton *)sender {
    if (self.addressBlock) {
        self.addressBlock();
    }
}

#pragma mark - SDCycleScrollViewDelegate

- (void)cycleScrollView:(SDCycleScrollView *)cycleScrollView didSelectItemAtIndex:(NSInteger)index
{
    XLPhotoBrowser *brower = [XLPhotoBrowser showPhotoBrowserWithCurrentImageIndex:index imageCount:_imgs.count datasource:self];
    
    brower.browserStyle = XLPhotoBrowserStylePageControl;
    brower.currentPageDotColor = NavigationColor;
}

- (NSURL *)photoBrowser:(XLPhotoBrowser *)browser highQualityImageURLForIndex:(NSInteger)index{
    return [NSURL URLWithString:[NSString stringWithFormat:@"%@%@",ImgUrl,_imgs[index]]];
}

- (SDCycleScrollView *)bannerView1{
    if (!_bannerView1) {
        _bannerView1 = [SDCycleScrollView cycleScrollViewWithFrame:CGRectMake(0, 0, kScreenWidth, 189) delegate:self placeholderImage:NoPicture];
        _bannerView1.pageControlAliment = SDCycleScrollViewPageContolAlimentCenter;
        _bannerView1.currentPageDotColor = NavigationColor;
        _bannerView1.autoScrollTimeInterval = 4;
    }
    return _bannerView1;
}

@end
