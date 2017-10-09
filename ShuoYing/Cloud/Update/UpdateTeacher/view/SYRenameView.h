//
//  SYRenameView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/2/23.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^RenameBlock)(NSString *newName);

@interface SYRenameView : UIView<UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UITextField *renameTF;
@property (weak, nonatomic) IBOutlet UIButton *cancleBtn;
@property (weak, nonatomic) IBOutlet UIButton *doneBtn;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;

@property (nonatomic, copy) RenameBlock block;

- (void)show;

- (void)dismiss;

@end
