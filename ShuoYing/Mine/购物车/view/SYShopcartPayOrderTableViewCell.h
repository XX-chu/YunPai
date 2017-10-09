//
//  SYShopcartPayOrderTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/4.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYShopcartShangpinModel;
typedef void(^SeletePhotoBlock)();
@interface SYShopcartPayOrderTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UILabel *haveSelectePhotoCountLabel;
@property (nonatomic, strong) SYShopcartShangpinModel *model;
@property (weak, nonatomic) IBOutlet UIView *selectePhotoView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *selectePhotoHeightConstaint;
@property (nonatomic, copy) SeletePhotoBlock block;
@end
