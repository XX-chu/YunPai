//
//  SYYuYueTableViewCell.h
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
@class SYYuYueModel;
@interface SYYuYueTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *nickLabel;
@property (weak, nonatomic) IBOutlet UILabel *juliLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *stars;
@property (weak, nonatomic) IBOutlet UILabel *yiwanchengLabel;
@property (weak, nonatomic) IBOutlet UILabel *xinghaoLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *zishuLabel;
@property (strong, nonatomic) IBOutletCollection(UIImageView) NSArray *zuopinS;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *imagesViewHeightConstraint;

@property (nonatomic, strong) SYYuYueModel *model;
@end
