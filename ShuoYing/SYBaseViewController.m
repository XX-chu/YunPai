//
//  SYBaseViewController.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "SYBaseViewController.h"
#import "IQKeyboardReturnKeyHandler.h"
@interface SYBaseViewController ()

@property (nonatomic, strong) IQKeyboardReturnKeyHandler *returnKey;

@end

@implementation SYBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = BackGroundColor;
    
    self.returnKey = [[IQKeyboardReturnKeyHandler alloc] initWithViewController:self];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)dealloc{
    self.returnKey = nil;
    NSLog(@"BaseViewController dealloc");
}



@end
