//
//  SYAddStudentToClassView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/2/23.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^AddStudentResultBlock)(NSString *name, NSString *phone);

@interface SYAddStudentToClassView : UIView
@property (weak, nonatomic) IBOutlet UITextField *nameTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneTF;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;

@property (nonatomic, copy) AddStudentResultBlock block;

- (void)show;

- (void)dismiss;
@end
