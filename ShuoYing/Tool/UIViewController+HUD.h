//
//  UIViewController+HUD.h
//  ReadingClub
//
//  Created by qtkj on 16/9/1.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIViewController (HUD)

- (void)showHint:(NSString *)hint;

- (void)showHint:(NSString *)hint Offset:(CGFloat)offset;

- (void)hideHud;

@end
