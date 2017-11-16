//
//  SYYunPaiEditZiShuViewController.h
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

typedef void(^ZiShuBlock)(NSString *content);

@interface SYYunPaiEditZiShuViewController : SYBaseViewController
@property (weak, nonatomic) IBOutlet UILabel *placeholedLabel;
@property (weak, nonatomic) IBOutlet UITextView *contentTV;
@property (weak, nonatomic) IBOutlet UILabel *countLabel;
@property (nonatomic, copy) ZiShuBlock zishuBlock;
@end
