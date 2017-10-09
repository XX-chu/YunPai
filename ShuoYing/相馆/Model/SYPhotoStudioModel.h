//
//  SYPhotoStudioModel.h
//  ShuoYing
//
//  Created by 硕影 on 2017/4/21.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYPhotoStudioModel : NSObject

@property (nonatomic, strong) NSNumber *ping;
@property (nonatomic, strong) NSNumber *photoStudioID;
@property (nonatomic, strong) NSNumber *juli;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *type;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *info;

+ (instancetype)photoStudioWithDictionary:(NSDictionary *)dic;

@end
