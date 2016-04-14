//
//  AppDelegate.m
//  VehicleInternet
//
//  Created by joker on 16/3/13.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "AppDelegate.h" 
#import <AVOSCloud/AVOSCloud.h>
#import "VIAppointmentModel.h"
#import "VIUserModel.h"
#import "VICarInfoModel.h"


@interface AppDelegate ()
{
    BMKMapManager* _mapManager;
    BOOL isUpdata;
}


@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    
    [[UITabBar appearance] setTintColor:[UIColor colorWithRed:253/255.0 green:130/255.0 blue:36/255.0 alpha:1]];
    [[UITabBar appearance] setBarTintColor:[UIColor whiteColor]];
    
    [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:83/255.0 green:125/255.0 blue:221/255.0 alpha:1.0]];
    
    //导航栏白色字体
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSForegroundColorAttributeName : [UIColor whiteColor]}];

    //初始化leancloud
    [self leancloudSetupWithLaunchOptions:launchOptions];
    //初始化百度地图
    [self baiduMapSetup];
    
    return YES;
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
    BOOL ret = [_mapManager start:@"CpVALBsZIouu5TAt485fEBRX"  generalDelegate:self];
    
    if (!ret) {
        NSLog(@"baiduMap failed");
    }else
    {
        NSLog(@"baiduMap successed");
    }
}


@end
