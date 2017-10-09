//
//  SYSelectCityAlert.h
//  ShuoYing
//
//  Created by 硕影 on 2017/2/20.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void (^SelectCityValue)(NSDictionary *selectCityDic);//选择的省市

@interface SYSelectCityAlert : UIView

@property (nonatomic, copy) SelectCityValue selecteValue;



@property (nonatomic, strong) NSDictionary *lastTimeSelectedValue;
/*!
 * @abstract 创建弹窗下拉列表类方法
 *
 * @param title 下拉框标题
 * @param titles 下拉框显示的string数组
 *
 */
+ (SYSelectCityAlert *)showWithTitle:(NSString *)title
                        titles:(NSArray *)titles
                   selectIndex:(SelectCityValue)selectIndex
               lastTimeSelectedValue:(NSDictionary *)lastTimeSelectedValue;

@end
