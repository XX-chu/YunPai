//
//  SYTiXianTixingView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/3/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^certifierGrapher)();
@interface SYTiXianTixingView : UIView

@property (weak, nonatomic) IBOutlet UIView *backView;

@property (nonatomic, copy) certifierGrapher block;

- (void)show;

- (void)disMiss;

@end
