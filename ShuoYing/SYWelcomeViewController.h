//
//  QTWelcomeViewController.h
//  ReadingClub
//
//  Created by qtkj on 2016/10/26.
//  Copyright © 2016年 qtkj. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol QTWelcomeDelegate <NSObject>

- (void)gotoMainTabbar;

@end

@interface SYWelcomeViewController : UIViewController

@property (nonatomic, weak) id<QTWelcomeDelegate> delegate;

@end
