//
//  AppDelegate.m
//  ShuoYing
//
//  Created by 硕影 on 2016/12/26.
//  Copyright © 2016年 硕影. All rights reserved.
//

#import "AppDelegate.h"
#import "SYBaseTabBarController.h"
#import "SYBaseNavigationController.h"

#import "WXApi.h"

#import "SYWelcomeViewController.h"
#import "SYGrapherUpdataPhotoViewController.h"
#import "SYCommentListViewController.h"
#import <AlipaySDK/AlipaySDK.h>

@interface AppDelegate ()<WXApiDelegate, QTWelcomeDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.backgroundColor = [UIColor whiteColor];
    
    if (@available(iOS 11.0, *)) {
        [[UIScrollView appearance] setContentInsetAdjustmentBehavior:UIScrollViewContentInsetAdjustmentNever];
    }

    
    if ([self isFirstLoad]) {
        //第一次
        [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isFirstActionApp"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        SYWelcomeViewController *welcome = [[SYWelcomeViewController alloc] init];
        welcome.delegate = self;
        self.window.rootViewController = welcome;
        
        
    }else{
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isFirstActionApp"];
        [[NSUserDefaults standardUserDefaults] synchronize];

        SYBaseTabBarController *tabbar = [[SYBaseTabBarController alloc] init];
        SYBaseNavigationController *navigation = [[SYBaseNavigationController alloc] initWithRootViewController:tabbar];
        self.window.rootViewController = navigation;
        
    }
    //在这里实例化SVProgressHUD
    [SVProgressHUD setDefaultStyle:SVProgressHUDStyleDark];
    [SVProgressHUD setDefaultMaskType:SVProgressHUDMaskTypeCustom];
    [SVProgressHUD setDefaultAnimationType:SVProgressHUDAnimationTypeNative];
    [SVProgressHUD dismissWithDelay:3];
    // Override point for customization after application launch.
    IQKeyboardManager *manager = [IQKeyboardManager sharedManager];
    manager.enable = YES;
    manager.shouldResignOnTouchOutside = YES;
    manager.enableAutoToolbar = NO;
    [[manager disabledDistanceHandlingClasses] addObject:[SYGrapherUpdataPhotoViewController class]];
    [[manager disabledDistanceHandlingClasses] addObject:[SYCommentListViewController class]];
    
    
    
    
    //注册微信支付
    [WXApi registerApp:@"wx3fa3352427c88e20" withDescription:@"com.shuoying.yunpai"];
    
    /* 打开调试日志 */
    [[UMSocialManager defaultManager] openLog:YES];
    
    /* 设置友盟appkey */
    [[UMSocialManager defaultManager] setUmSocialAppkey:@"58bf66b51061d22fa3001727"];

    [self configUSharePlatforms];
    
    [self confitUShareSettings];
    
    //注册通知
    float version = [[[UIDevice currentDevice] systemVersion] floatValue];
    if (version >= 8.0) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge categories:nil];
        [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
        [application registerForRemoteNotifications];
    }
    
    
    [self.window makeKeyAndVisible];
    return YES;
}

- (void)confitUShareSettings
{
    /*
     * 打开图片水印
     */
    //[UMSocialGlobal shareInstance].isUsingWaterMark = YES;
    
    /*
     * 关闭强制验证https，可允许http图片分享，但需要在info.plist设置安全域名
     <key>NSAppTransportSecurity</key>
     <dict>
     <key>NSAllowsArbitraryLoads</key>
     <true/>
     </dict>
     */
    //[UMSocialGlobal shareInstance].isUsingHttpsWhenShareContent = NO;
    
}

- (void)configUSharePlatforms
{
    /* 设置微信的appKey和appSecret */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_WechatSession appKey:@"wx3fa3352427c88e20" appSecret:@"a6bb54e582292148c4ffcbb4776041e9" redirectURL:@"http://wap.yunxiangguan.cn"];
    /*
     * 移除相应平台的分享，如微信收藏
     */
    //[[UMSocialManager defaultManager] removePlatformProviderWithPlatformTypes:@[@(UMSocialPlatformType_WechatFavorite)]];
    
    /* 设置分享到QQ互联的appID
     * U-Share SDK为了兼容大部分平台命名，统一用appKey和appSecret进行参数设置，而QQ平台仅需将appID作为U-Share的appKey参数传进即可。
     */
    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_QQ appKey:@"1106027896"/*设置QQ平台的appID*/  appSecret:@"Of4GooloPT6LMeRp" redirectURL:@"http://wap.yunxiangguan.cn"];
    
    /* 设置新浪的appKey和appSecret */
//    [[UMSocialManager defaultManager] setPlaform:UMSocialPlatformType_Sina appKey:@"3921700954"  appSecret:@"04b48b094faeb16683c32669824ebdad" redirectURL:@"https://sns.whalecloud.com/sina2/callback"];

    
}

- (void)gotoMainTabbar{
    SYBaseTabBarController *tabbarVC = [[SYBaseTabBarController alloc] init];
    SYBaseNavigationController *naviVC = [[SYBaseNavigationController alloc] initWithRootViewController:tabbarVC];
    self.window.rootViewController = naviVC;
    
}


//微信支付回调
- (void)onResp:(BaseResp *)resp{
    NSLog(@"微信支付回调");
    
    [[NSNotificationCenter defaultCenter] postNotificationName:@"weixinPayResp" object:[NSString stringWithFormat:@"%i",resp.errCode]];
}

//分享,支付回调
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    NSLog(@"url - %@",url.host);
    NSLog(@"url -- %@",url);
    BOOL result = [[UMSocialManager defaultManager] handleOpenURL:url sourceApplication:sourceApplication annotation:annotation];
    if (!result) {
        // 其他如支付等SDK的回调
        if ([url.host isEqualToString:@"pay"]) {
            return [WXApi handleOpenURL:url delegate:self];
        }
        //支付宝
        if ([url.host isEqualToString:@"safepay"]) {
            
            //跳转支付宝钱包app进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                
                //发送支付结果
                NSString *payResult = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"resultStatus"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"payResule" object:self userInfo:@{@"payStatus":payResult}];
            }];
            
        }
        
        return YES;
    }
    return result;
    
}

#warning 如果是ios10必须实现这个方法
- (BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options{
    
    NSLog(@"url - %@",url.host);
    NSLog(@"url -- %@",url);
    //6.3的新的API调用，是为了兼容国外平台(例如:新版facebookSDK,VK等)的调用[如果用6.2的api调用会没有回调],对国内平台没有影响
    BOOL result = [[UMSocialManager defaultManager]  handleOpenURL:url options:options];
    if (!result) {
        // 其他如支付等SDK的回调 微信
        if ([url.host isEqualToString:@"pay"]) {
            return [WXApi handleOpenURL:url delegate:self];
        }
        //支付宝
        if ([url.host isEqualToString:@"safepay"]) {
            
            //跳转支付宝钱包app进行支付，处理支付结果
            [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {
                
                //发送支付结果
                NSString *payResult = [NSString stringWithFormat:@"%@",[resultDic objectForKey:@"resultStatus"]];
                
                [[NSNotificationCenter defaultCenter] postNotificationName:@"payResule" object:self userInfo:@{@"payStatus":payResult}];
            }];
            
        }
        return YES;
    }
    return result;
    
}


- (BOOL)isFirstLoad{
    NSString *currentVersion = [[[NSBundle mainBundle] infoDictionary]
                                objectForKey:@"CFBundleShortVersionString"];
    
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    NSString *lastRunVersion = [defaults objectForKey:LAST_RUN_VERSION_KEY];
    NSLog(@"currentVersion - %@",currentVersion);
    NSLog(@"lastRunVersion - %@",lastRunVersion);
    if (!lastRunVersion) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        return YES;
    }
    else if (![lastRunVersion isEqualToString:currentVersion]) {
        [defaults setObject:currentVersion forKey:LAST_RUN_VERSION_KEY];
        return YES;  
    }  
    return NO;  
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
