//
//  SYPayTypeView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/1/16.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^PayTypeBlock)(NSInteger tag);

@interface SYPayTypeView : UIView

@property (nonatomic, copy) PayTypeBlock block;

+ (instancetype)sharedInstance;

- (void)showInView;

- (void)dismissView;

@end
