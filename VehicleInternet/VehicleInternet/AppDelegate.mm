//
//  AppDelegate.m
//  VehicleInternet
//
//  Created by joker on 16/3/13.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "AppDelegate.h" 
#import <AVOSCloud/AVOSCloud.h>
#import <AVOSCloudIM/AVOSCloudIM.h>
#import "VIAppointmentModel.h"
#import "VIUserModel.h"
#import "VICarInfoModel.h"
#import "BNCoreServices.h"
#import "VIMusicPlayerController.h"
#import <BmobPay/BmobPay.h>
#import <AlipaySDK/AlipaySDK.h>
#import "AFNetworking.h"

static NSString *const kAVIMInstallationKeyChannels = @"channels";


@interface AppDelegate () <UITabBarControllerDelegate>
{
    BMKMapManager* _mapManager;
    BOOL isUpdata;
    AVAudioPlayer *player;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    //初始化leancloud
    [self leancloudSetupWithLaunchOptions:launchOptions];
    //初始化百度地图
    [self baiduMapSetup];
    //初始化支付SDK
    [BmobPaySDK registerWithAppKey:@"285549832d04465b3d5e3db77e1a2525"];

    [AVOSCloud registerForRemoteNotification];
//    [AVPush setProductionMode:NO];
    
    
    [[UITabBar appearance] setTintColor:[UIColor blueColor]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];

    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:83/255.0 green:125/255.0 blue:221/255.0 alpha:1.0]];
    
    //导航栏白色字体
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    UITabBarController *mainWindow = (UITabBarController *)self.window.rootViewController;
    mainWindow.delegate = self;

    UIUserNotificationSettings *settings = [UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert categories:nil];
    [[UIApplication sharedApplication] registerUserNotificationSettings:settings];
   
    
    //开始播放音乐
    NSString *path = [[NSBundle mainBundle] pathForResource:@"安静.mp3" ofType:nil];
    NSURL *url = [NSURL fileURLWithPath:path];
    player = [[AVAudioPlayer alloc] initWithContentsOfURL:url error:nil];
    player.currentTime = 0;
    player.volume = 0.5;
    [player play];
    
//    AVPush *push = [[AVPush alloc] init];
//    [push setMessage:@"2333"];
//    [push sendPushInBackground];
    
    return YES;
}

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    if ([url.host isEqualToString:@"safepay"]) {
        
        [[AlipaySDK defaultService] processOrderWithPaymentResult:url standbyCallback:^(NSDictionary *resultDic) {}];
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if (tabBarController.selectedIndex == 2) {
        NSUserDefaults *time = [NSUserDefaults standardUserDefaults];
        NSNumber *musicTime = [NSNumber numberWithFloat:player.currentTime];
        [time setValue:musicTime forKey:@"time"];
        [player stop];
        
    }

}

- (void)application:(UIApplication *)app didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    AVInstallation *currentInstallation = [AVInstallation currentInstallation];
    [currentInstallation setDeviceTokenFromData:deviceToken];
    [currentInstallation saveInBackground];
}

- (void)application:(UIApplication *)application didFailToRegisterForRemoteNotificationsWithError:(NSError *)error {
    NSLog(@"error %@",error);
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo {
    NSLog(@"userinfo:%@",userInfo);
    NSLog(@"收到推送消息:%@",[[userInfo objectForKey:@"aps"] objectForKey:@"alert"]);
    
    if (application.applicationState == UIApplicationStateActive) {
        // 转换成一个本地通知，显示到通知栏，你也可以直接显示出一个 alertView，只是那样稍显 aggressive：）
        UILocalNotification *localNotification = [[UILocalNotification alloc] init];
        localNotification.userInfo = userInfo;
        localNotification.soundName = UILocalNotificationDefaultSoundName;
        localNotification.alertBody = [[userInfo objectForKey:@"aps"] objectForKey:@"alert"];
        localNotification.fireDate = [NSDate date];
        [[UIApplication sharedApplication] scheduleLocalNotification:localNotification];
    } else {
        [AVAnalytics trackAppOpenedWithRemoteNotificationPayload:userInfo];
    }
    
    
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

#pragma mark - Leancloud相关操作

- (void)leancloudSetupWithLaunchOptions:(NSDictionary *)launchOptions
{
    [AVOSCloud setApplicationId:@"qkuNzgIaUA246v24WYFByeNd-gzGzoHsz"
                      clientKey:@"TJVs6qapLKD7yLPOfmBVevlX"];
    [AVAnalytics trackAppOpenedWithLaunchOptions:launchOptions];
    
    /** 子类注册 */
    [VIAppointmentModel registerSubclass];
    [VIUserModel registerSubclass];
    [VICarInfoModel registerSubclass];

    
}
//
#pragma mark - 百度地图相关操作
- (void)baiduMapSetup
{
    if (_mapManager==nil) {
        _mapManager = [[BMKMapManager alloc]init];
    }
    
    /**
     *  tomorrow.VehicleInternetJM     o3DCdN1FZZKaT3gK0B8f3TkT
     *  tomorrow.VehicleInternet       CpVALBsZIouu5TAt485fEBRX
     *
     */
    BOOL ret = [_mapManager start:@"o3DCdN1FZZKaT3gK0B8f3TkT"  generalDelegate:self];
    
    if (!ret) {
        NSLog(@"baiduMap failed");
    }else
    {
        NSLog(@"baiduMap successed");
    }

    //初始化导航SDK
    [BNCoreServices_Instance initServices:@"o3DCdN1FZZKaT3gK0B8f3TkT"];
    [BNCoreServices_Instance startServicesAsyn:nil fail:nil];
}


@end
