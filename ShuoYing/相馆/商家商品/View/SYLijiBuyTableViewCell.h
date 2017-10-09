//
//  SYLijiBuyTableViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYLijiBuyTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *shangpinName;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *numLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *hejiLabel;
@property (weak, nonatomic) IBOutlet UILabel *shangpinShuxingLabel;

@property (weak, nonatomic) IBOutlet UIView *selectePhotoView;
@property (weak, nonatomic) IBOutlet UIButton *selectePhotoBtn;
@property (weak, nonatomic) IBOutlet UILabel *haveSelectePhotoCountLabel;

@end
