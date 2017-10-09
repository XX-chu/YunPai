//
//  SYMyPhotoModel.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYMyPhotoModel : NSObject

@property (nonatomic, strong) NSNumber *photoID;

@property (nonatomic, copy) NSString *img;//原图 下载用

@property (nonatomic, copy) NSString *img_min;//缩略图

@property (nonatomic, copy) NSString *img_200;//剪裁的200*200像素小图

@property (nonatomic, strong) NSNumber *isSelected;//照片是否选中

- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (instancetype)photoWithDictionary:(NSDictionary *)dic;
@end
