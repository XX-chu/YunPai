//
//  SYUpdateToStudentCollectionReusableView.h
//  ShuoYing
//
//  Created by 硕影 on 2017/3/1.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^StudentSeletePhotoBlock)();
@interface SYUpdateToStudentCollectionReusableView : UICollectionReusableView
@property (weak, nonatomic) IBOutlet UIView *backView;
@property (weak, nonatomic) IBOutlet UILabel *tishiLabel;
@property (weak, nonatomic) IBOutlet UITextField *moneyTF;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoBtn;
@property (weak, nonatomic) IBOutlet UILabel *historyLabel;

@property (nonatomic, copy) StudentSeletePhotoBlock block;

@end
