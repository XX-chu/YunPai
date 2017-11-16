//
//  SYYuYueModel.h
//  ShuoYing
//
//  Created by chu on 2017/11/15.
//  Copyright © 2017年 硕影. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SYYuYueModel : NSObject

@property (nonatomic, copy) NSString *nick;
@property (nonatomic, copy) NSString *ModelNo;
@property (nonatomic, copy) NSString *yuyueID;
@property (nonatomic, copy) NSString *SerialNo;
@property (nonatomic, strong) NSNumber *ping;
@property (nonatomic, strong) NSArray *works;
@property (nonatomic, copy) NSString *head;
@property (nonatomic, copy) NSString *juli;
@property (nonatomic, copy) NSString *done;
@property (nonatomic, copy) NSString *money;
@property (nonatomic, copy) NSString *info;

+ (instancetype)yuyueWithDicaionary:(NSDictionary *)dic;

@end
