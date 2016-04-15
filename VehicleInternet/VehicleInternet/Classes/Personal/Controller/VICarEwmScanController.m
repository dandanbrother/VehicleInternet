//
//  VICarEwmScanController.m
//  VehicleInternet
//
//  Created by joker on 16/4/13.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VICarEwmScanController.h"
#import "SHBQRView.h"
#import "LCCoolHUD.h"
@interface VICarEwmScanController ()<SHBQRViewDelegate>

@end

@implementation VICarEwmScanController


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"车辆信息扫描";
    SHBQRView *qrView = [[SHBQRView alloc] initWithFrame:self.view.bounds];
    qrView.delegate = self;
    [self.view addSubview:qrView];
    
    //添加导航栏左面按钮
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(backBtnClicked)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
}

- (void)qrView:(SHBQRView *)view ScanResult:(NSString *)result {
    [view stopScan];
    [LCCoolHUD showSuccess:@"扫描成功" zoom:YES shadow:YES];

    if (self.returnBlock != nil) {
        self.returnBlock(result);
    }

    
    
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
    
}

- (void)returnBlock:(ReturnBlock)block {
    self.returnBlock = block;
}

- (void)backBtnClicked
{
    [self.navigationController  dismissViewControllerAnimated:YES completion:nil];
}


- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}


@end
