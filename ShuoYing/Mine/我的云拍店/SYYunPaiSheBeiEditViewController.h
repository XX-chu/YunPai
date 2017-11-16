//
//  SYYunPaiSheBeiEditViewController.h
//  ShuoYing
//
//  Created by chu on 2017/11/14.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

typedef void(^SheBeiBlock)(NSString *ModelNo, NSString *SerialNo);

@interface SYYunPaiSheBeiEditViewController : SYBaseViewController
@property (weak, nonatomic) IBOutlet UITextField *xinghaoTF;

@property (weak, nonatomic) IBOutlet UITextField *xueliehaoTF;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (nonatomic, copy) SheBeiBlock block;
@end
