//
//  SYOrderInfosTableViewCell.h
//  ShuoYing
//
//  Created by chu on 2017/11/10.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^HaveSelectePhotoBlock)();

@interface SYOrderInfosTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *shangpinNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *shuxingLabel;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (weak, nonatomic) IBOutlet UIButton *haveSlecteBtn;
@property (nonatomic, copy) HaveSelectePhotoBlock block;
@end
