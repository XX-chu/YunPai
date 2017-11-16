//
//  SYTitleAndImageTableViewCell.h
//  ShuoYing
//
//  Created by chu on 2017/11/13.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^DelBlock)();
@interface SYTitleAndImageTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (weak, nonatomic) IBOutlet UIButton *delBtn;
@property (nonatomic, copy) DelBlock block;
@end
