//
//  SYUpdatePreviewViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2017/2/21.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"

//typedef NS_ENUM(NSUInteger, UpdatePreviewType) {
//    UpdatePreviewMySpace,
//    UpdatePreview,
//    <#MyEnumValueC#>,
//};

@interface SYUpdatePreviewViewController : SYBaseViewController

+ (instancetype)updatePreviewWithUrl:(NSString *)url
                      Param:(NSDictionary *)param;

@end
