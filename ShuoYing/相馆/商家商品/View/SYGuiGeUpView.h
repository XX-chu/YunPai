//
//  SYGuiGeUpView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/27.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^CloseGuiGeBlock)();
@interface SYGuiGeUpView : UIView
@property (weak, nonatomic) IBOutlet UIView *dicengView;
@property (weak, nonatomic) IBOutlet UIImageView *headImageView;
@property (weak, nonatomic) IBOutlet UIButton *closeBtn;
@property (weak, nonatomic) IBOutlet UILabel *priceLabel;
@property (weak, nonatomic) IBOutlet UILabel *kucunLabel;
@property (weak, nonatomic) IBOutlet UILabel *yixuanLabel;

@property (nonatomic, copy) CloseGuiGeBlock block;

@end
