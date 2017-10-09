//
//  DeleteOrderView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/7.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^RightBlock)();
typedef void(^LeftBlock)();
@interface DeleteOrderView : UIView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *tishiLabel;
@property (weak, nonatomic) IBOutlet UIButton *leftBtn;
@property (weak, nonatomic) IBOutlet UIButton *rightBtn;

@property (nonatomic, copy) RightBlock rightBlock;
@property (nonatomic, copy) LeftBlock leftBlock;
- (void)show;

- (void)dismiss;

@end
