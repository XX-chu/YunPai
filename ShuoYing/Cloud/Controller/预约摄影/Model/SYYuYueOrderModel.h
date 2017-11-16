//
//  SYYuYueOrderModel.h
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYYuYueOrderModel : NSObject
@property (nonatomic, copy) NSString *orderid;
@property (nonatomic, copy) NSString *state;
@property (nonatomic, copy) NSString *money;
@property (nonatomic, copy) NSString *mid;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *addtime;
@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *address;
@property (nonatomic, copy) NSString *ping;
@property (nonatomic, copy) NSString *tel;
@property (nonatomic, copy) NSString *msg;
@property (nonatomic, copy) NSString *name;
@property (nonatomic, copy) NSString *link;
@property (nonatomic, copy) NSString *link_tel;
@property (nonatomic, strong) NSNumber *ping1;
@property (nonatomic, strong) NSNumber *ping2;
@property (nonatomic, strong) NSNumber *ping3;


+ (instancetype)yunpaiorderWithDicaionary:(NSDictionary *)dic;


@end
