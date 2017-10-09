//
//  UIViewController+HUD.m
//  ReadingClub
//
//  Created by qtkj on 16/9/1.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import "UIViewController+HUD.h"
#import "MBProgressHUD.h"
#import <objc/runtime.h>

static const void *HttpRequestHUDKey = &HttpRequestHUDKey;

@implementation UIViewController (HUD)

- (MBProgressHUD *)HUD{
    return objc_getAssociatedObject(self, HttpRequestHUDKey);
}

- (void)setHUD:(MBProgressHUD *)HUD{
    objc_setAssociatedObject(self, HttpRequestHUDKey, HUD, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)showHint:(NSString *)hint
{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.bezelView.color = [UIColor blackColor];
    hud.contentColor = [UIColor whiteColor];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    //    hud.labelText = hint;
    hud.detailsLabel.text = hint;
    hud.margin = 10.f;
    CGPoint oldOffset = hud.offset;
    hud.offset = CGPointMake(oldOffset.x, 180);
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

- (void)showHint:(NSString *)hint Offset:(CGFloat)offset{
    UIView *view = [[UIApplication sharedApplication].delegate window];
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:view animated:YES];
    hud.userInteractionEnabled = NO;
    hud.bezelView.color = [UIColor blackColor];
    hud.contentColor = [UIColor whiteColor];
    // Configure for text only and offset down
    hud.mode = MBProgressHUDModeText;
    //    hud.labelText = hint;
    hud.detailsLabel.text = hint;
    hud.margin = 10.f;
    CGPoint oldOffset = hud.offset;
    hud.offset = CGPointMake(oldOffset.x, offset);
    hud.removeFromSuperViewOnHide = YES;
    [hud hideAnimated:YES afterDelay:2];
}

- (void)hideHud{
    [[self HUD] hideAnimated:YES];
}

@end
