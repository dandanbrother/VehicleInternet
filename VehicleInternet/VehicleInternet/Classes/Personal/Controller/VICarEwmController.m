//
//  VICarEwmController.m
//  VehicleInternet
//
//  Created by joker on 16/4/13.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VICarEwmController.h"
#import "VICarInfoModel.h"

#import "UIImage+QRCode.h"

@interface VICarEwmController ()
@property (nonatomic,strong) VICarInfoModel *carInfo;
@end

@implementation VICarEwmController

+ (instancetype)ewmShownWithCarInfo:(VICarInfoModel *)carInfo
{
    VICarEwmController *ewmVC = [[self alloc] init];
    if (ewmVC) {
        ewmVC.carInfo = carInfo;
    }
    return ewmVC;
}



- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"车辆信息";
    //添加导航栏左面按钮
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(backBtnClicked)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    NSDictionary *dict = @{
                           @"objectID" : self.carInfo.objectId,
                           @"carBrand" : self.carInfo.carBrand,
                           @"mileage" : self.carInfo.mileage,
                           @"licenseNum" : self.carInfo.licenseNum,
                           @"petrol" : self.carInfo.petrol,
                           };
//    NSDictionary *dict = @{
//                           @"carBrand" : @"222",
//                           @"mileage" : @"222",
//                           @"licenseNum" : @"222",
//                           @"petrol" : @"222"
//                           };
    
    NSString *str = [self dictionaryToJson:dict];
    
    
    CGFloat width = 200;
    CGFloat imgX = (KDeviceWidth - 200) / 2;
    UIImageView *imgView = [[UIImageView alloc] initWithFrame:CGRectZero];
    imgView.frame = CGRectMake(imgX, 100, width, width);
    imgView.layer.shadowColor = [UIColor blackColor].CGColor;
    imgView.layer.shadowOffset = CGSizeMake(1, 2);
    imgView.layer.shadowRadius = 1;
    imgView.layer.shadowOpacity = 0.5;
    [self.view addSubview:imgView];
    
    
    imgView.image = [UIImage qrImageWithContent:str logo:[UIImage imageNamed:@"111.png"] size:width red:20 green:100 blue:100];
    

}

- (void)backBtnClicked
{
    [self.navigationController  dismissViewControllerAnimated:YES completion:nil];
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}
@end
