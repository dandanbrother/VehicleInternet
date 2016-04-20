//
//  VIProtectCarEwmController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/18.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIProtectCarEwmScanController.h"
#import "SHBQRView.h"
#import "LCCoolHUD.h"
#import <AVOSCloud/AVOSCloud.h>

@interface VIProtectCarEwmScanController () <SHBQRViewDelegate>

@end

@implementation VIProtectCarEwmScanController

- (void)viewDidLoad {
    [super viewDidLoad];

    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"车辆维护信息扫描";
    SHBQRView *qrView = [[SHBQRView alloc] initWithFrame:self.view.bounds];
    qrView.delegate = self;
    [self.view addSubview:qrView];
    
    //添加导航栏左面按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(backBtnClicked)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)qrView:(SHBQRView *)view ScanResult:(NSString *)result {
    [view stopScan];
    
    NSMutableDictionary *dict = [self dictionaryWithJsonString:result];
    NSLog(@"%@",dict);
    AVQuery *query = [AVQuery queryWithClassName:@"VICarInfoModel"];
    [query getObjectInBackgroundWithId:dict[@"objectID"] block:^(AVObject *object, NSError *error) {
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //生成的二维码 默认全部损坏
            [object setValue:@"0" forKey:@"isEngineGood"];
            [object setValue:@"0" forKey:@"isLightGood"];
            [object setValue:@"0" forKey:@"isTransmissionGood"];
            dict[@"isEngineGood"] = @"0";
            dict[@"isLightGood"] = @"0";
            dict[@"isTransmissionGood"] = @"0";
            
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                if (succeeded) {
                                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            }];

        }];
    }];
    [LCCoolHUD showSuccess:@"扫描成功" zoom:YES shadow:YES]; 
    
    //本地推送
    UILocalNotification *petrolNotice = [UILocalNotification new];
    UILocalNotification *mileageNotice = [UILocalNotification new];
    UILocalNotification *protectNotice = [UILocalNotification new];

    if (petrolNotice!=nil) {
        
        petrolNotice.soundName = UILocalNotificationDefaultSoundName;
//        if (dict[@"petrol"]) {
        petrolNotice.alertBody = @"油量低于20%";
        mileageNotice.alertBody = @"里程数过10000公里啦";
        protectNotice.alertBody = @"车子坏啦";
//        }
//        if (dict[@"mileage"]) {
//            localNotifi.alertBody = @"里程数过1000啦";
//        }
//        if ([dict[@"isTransmissionGood"] isEqualToString:@"0"]) {
//            localNotifi.alertBody = @"车子坏啦";
//        }
       
    }
    petrolNotice.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
    mileageNotice.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
    protectNotice.fireDate = [NSDate dateWithTimeIntervalSinceNow:6];

    [[UIApplication sharedApplication] scheduleLocalNotification:petrolNotice];
    [[UIApplication sharedApplication] scheduleLocalNotification:mileageNotice];
    [[UIApplication sharedApplication] scheduleLocalNotification:protectNotice];
    

}

- (void)backBtnClicked
{
    [self.navigationController  dismissViewControllerAnimated:YES completion:nil];
}


- (NSMutableDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSMutableDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}

@end
