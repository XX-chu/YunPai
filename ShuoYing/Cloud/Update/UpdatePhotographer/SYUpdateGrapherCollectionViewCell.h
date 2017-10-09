//
//  SYUpdateGrapherCollectionViewCell.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/12.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SYUpdateGrapherCollectionViewCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *phoneLabel;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IMGHeightContraint;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *IMGWidthConstraint;
@end
