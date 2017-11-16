//
//  SYEditImageCollectionViewCell.h
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^YunPaiDeleteBlock)();
typedef void(^YunPaiEditBlock)();

@interface SYEditImageCollectionViewCell : UICollectionViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIView *editView;
@property (weak, nonatomic) IBOutlet UIButton *deleBtn;
@property (weak, nonatomic) IBOutlet UIButton *editBtn;
@property (nonatomic, copy) YunPaiDeleteBlock delBlock;
@property (nonatomic, copy) YunPaiEditBlock editBlock;

@end
