//
//  UIDevice+iPhoneModel.h
//  ReadingClub
//
//  Created by qtkj on 16/8/15.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(char, iPhoneModel){//0~3
    iPhone4,//320*480
    iPhone5,//320*568
    iPhone6,//375*667
    iPhone6Plus,//414*736
    UnKnown
};

@interface UIDevice (iPhoneModel)




/**
    12  *  return current running iPhone model
    13  *
    14  *  @return iPhone model
    15  */
+ (iPhoneModel)iPhonesModel;


@end
