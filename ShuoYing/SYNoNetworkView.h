//
//  SYNoNetworkView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/3/7.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^LoadDataBlock)();
@interface SYNoNetworkView : UIView

@property (weak, nonatomic) IBOutlet UIButton *loadDataBtn;

@property (nonatomic, copy) LoadDataBlock block;

@end
