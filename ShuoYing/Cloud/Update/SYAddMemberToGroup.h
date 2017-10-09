//
//  SYAddMemberToGroup.h
//  ShuoYing
//
//  Created by 硕影 on 2017/3/6.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AddMemberResultBlock)(NSString *phone);


@interface SYAddMemberToGroup : UIView
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UILabel *title;

@property (nonatomic, copy) AddMemberResultBlock block;

- (void)show;

- (void)dismiss;

@end
