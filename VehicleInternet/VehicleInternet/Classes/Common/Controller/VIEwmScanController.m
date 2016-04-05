//
//  VIEwmScanController.m
//  VehicleInternet
//
//  Created by joker on 16/4/4.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIEwmScanController.h"
#import "SHBQRView.h"

@interface VIEwmScanController ()<SHBQRViewDelegate>
- (IBAction)dismissBtnClicked:(id)sender;

@end

@implementation VIEwmScanController

- (void)viewDidLoad {
    [super viewDidLoad];
    SHBQRView *qrView = [[SHBQRView alloc] initWithFrame:self.view.bounds];
    qrView.delegate = self;
    [self.view addSubview:qrView];
}

- (void)qrView:(SHBQRView *)view ScanResult:(NSString *)result {
    [view stopScan];
    /*
    NSDictionary *dict = @{
                           @"carName" : self.appointment.carName,
                           @"plateNum" : self.appointment.plateNum,
                           @"carOwnerName" : self.appointment.carOwnerName,
                           @"time" : self.appointment.time,
                           @"petrolStation" : self.appointment.petrolStation,
                           @"petrolType" : self.appointment.petrolType,
                           @"petrolAmount" : self.appointment.petrolAmount
                           
                           
                           };
     */
    
    NSDictionary *dict = [self dictionaryWithJsonString:result];
    
    
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:[NSString stringWithFormat:@"扫描结果：%@", result] preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"Sure" style:UIAlertActionStyleCancel handler:^(UIAlertAction * _Nonnull action) {
        [view startScan];
    }]];
    [self presentViewController:alert animated:true completion:nil];
}
- (IBAction)dismissBtnClicked:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
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
