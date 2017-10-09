//
//  SYShopcartShangpinModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/5/3.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYShopcartShangpinModel : NSObject

@property (nonatomic, strong) NSNumber *spceid;

@property (nonatomic, strong) NSNumber *product;

@property (nonatomic, strong) NSNumber *shangpinid;

@property (nonatomic, strong) NSNumber *fee;

@property (nonatomic, strong) NSNumber *line;

@property (nonatomic, strong) NSNumber *num;

@property (nonatomic, strong) NSNumber *money;

@property (nonatomic, strong) NSNumber *state;//0.已失效（如：店铺关闭、商品下架或规格更改），1.正常

@property (nonatomic, copy) NSString *spce;

@property (nonatomic, copy) NSString *title;

@property (nonatomic, copy) NSString *img_200;

@property (nonatomic, strong) NSNumber *isSelected;

@property (nonatomic, strong) NSNumber *upimg;//需要上传图片的最大数量

@property (nonatomic, strong) NSNumber *c_img;//已上传数量

+ (instancetype)cartShangPinWithDictionary:(NSDictionary *)dic;

@end
