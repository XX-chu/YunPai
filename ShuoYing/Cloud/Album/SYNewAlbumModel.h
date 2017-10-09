//
//  SYNewAlbumModel.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYNewAlbumModel : NSObject

@property (nonatomic, strong) NSNumber *albumId;

@property (nonatomic, copy) NSString *img;

@property (nonatomic, strong) NSNumber *count;

@property (nonatomic, copy) NSString *file;

@property (nonatomic, copy) NSString *time;

@property (nonatomic, copy) NSString *img_200;
//这个属性只有在相关结算时用来存储加载到第几页
@property (nonatomic, strong) NSNumber *jiazaiCount;

@property (nonatomic, strong) NSNumber *isSelected;//这个属性只存储是否选中

- (instancetype)initWithDictionary:(NSDictionary *)dic;

+ (instancetype)albumWithDictionary:(NSDictionary *)dic;

@end
