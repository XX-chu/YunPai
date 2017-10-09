//
//  SYEditStudentView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/2/23.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^EditStudentBolck)(NSDictionary *resultDic);

@interface SYEditStudentView : UIView

@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UIButton *renameStudent;
@property (weak, nonatomic) IBOutlet UIButton *deleteStudent;

@property (weak, nonatomic) IBOutlet UIView *contentView;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *scrollContentView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *scrollContentViewLeftContrains;
@property (weak, nonatomic) IBOutlet UIButton *deleteTitle;

@property (weak, nonatomic) IBOutlet UITextField *renameTF;
@property (weak, nonatomic) IBOutlet UILabel *deleteLabel;

@property (nonatomic, copy) EditStudentBolck block;

- (void)show;

- (void)dismiss;

@end
