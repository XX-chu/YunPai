//
//  SYMyAlbumInfosViewController.h
//  ShuoYing
//
//  Created by 硕影 on 2016/12/30.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"


@interface SYMyAlbumInfosViewController : SYBaseViewController


@property (nonatomic, strong) NSMutableArray *selectedPhotos;

@property (nonatomic, strong) NSNumber *photoID;

@property (nonatomic, copy) NSString *photoName;

@property (nonatomic, assign) BOOL isNotFromMine; //NO是我的相册， YES是来自老师或摄影师

@end
