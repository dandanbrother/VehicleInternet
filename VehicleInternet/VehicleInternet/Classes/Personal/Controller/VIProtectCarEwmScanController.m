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
    
    AVQuery *query = [AVQuery queryWithClassName:@"VICarInfoModel"];
    [query getObjectInBackgroundWithId:dict[@"objectID"] block:^(AVObject *object, NSError *error) {
        [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            //保存二维码数据，传给服务器
            [object setValue:[NSString stringWithFormat:@"%@",dict[@"isEngineGood"]] forKey:@"isEngineGood"];
            [object setValue:[NSString stringWithFormat:@"%@",dict[@"isLightGood"]] forKey:@"isLightGood"];
//            [object setValue:dict[@"isTransGood"] forKey:@"isTransGood"];
            [object setValue:dict[@"mileage"] forKey:@"mileage"];
            [object setValue:dict[@"crtPetrol"] forKey:@"crtPetrol"];
            
            NSLog(@"%@",dict);
 
            if (succeeded) {
                
                    //本地推送
                UILocalNotification *petrolNotice = [[UILocalNotification alloc] init];
                UILocalNotification *mileageNotice = [[UILocalNotification alloc] init];
                UILocalNotification *protectNotice = [[UILocalNotification alloc] init];
                if ([dict[@"crtPetrol"] floatValue] <= [[object valueForKey:@"petrol"] floatValue] * 0.2) {
                            petrolNotice.alertBody = @"油量低于20%";
                            
                        }
                if ([dict[@"mileage"] floatValue] >= 15000.0) {
                            mileageNotice.alertBody = @"里程数过1000啦";
                        }
                if ([dict[@"isLightGood"] isEqualToString:@"0"] || [dict[@"isEngineGood"] isEqualToString:@"0"]) {
                            protectNotice.alertBody = @"车子坏啦";
                        }
                
                    petrolNotice.fireDate = [NSDate dateWithTimeIntervalSinceNow:2];
                    mileageNotice.fireDate = [NSDate dateWithTimeIntervalSinceNow:4];
                    protectNotice.fireDate = [NSDate dateWithTimeIntervalSinceNow:6];
                    
                    [[UIApplication sharedApplication] scheduleLocalNotification:petrolNotice];
                    [[UIApplication sharedApplication] scheduleLocalNotification:mileageNotice];
                    [[UIApplication sharedApplication] scheduleLocalNotification:protectNotice];
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }
            }];

    }];
    [LCCoolHUD showSuccess:@"扫描成功" zoom:YES shadow:YES]; 


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
