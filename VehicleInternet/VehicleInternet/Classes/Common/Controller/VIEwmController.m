//
//  VIEwmController.m
//  VehicleInternet
//
//  Created by joker on 16/4/4.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIEwmController.h"
#import "VIAppointmentModel.h"

#import "UIImage+QRCode.h"

@interface VIEwmController ()

@property (nonatomic,strong) VIAppointmentModel *appointment;


@end

@implementation VIEwmController

+ (instancetype)ewmShownWithAppointment:(VIAppointmentModel *)appointment
{
    VIEwmController *ewmVC = [[self alloc] init];
    if (ewmVC) {
        ewmVC.appointment = appointment;
    }
    return ewmVC;
}


- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"预约二维码";
    //添加导航栏左面按钮
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(backBtnClicked)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
    NSDictionary *dict = @{
                           @"ownerID" : self.appointment.ownerID,
                           @"objectId" : self.appointment.objectId
                           };
    
    
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
    
    imgView.centerY = KDeviceHeight * 0.5;
    
    imgView.image = [UIImage qrImageWithContent:str logo:[UIImage imageNamed:@"111"] size:width red:20 green:100 blue:100];

    
}

- (NSString*)dictionaryToJson:(NSDictionary *)dic

{
    
    NSError *parseError = nil;
    
    NSData *jsonData = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&parseError];
    
    return [[NSString alloc] initWithData:jsonData encoding:NSUTF8StringEncoding];
    
}

- (void)backBtnClicked
{
    [self.navigationController  dismissViewControllerAnimated:YES completion:nil];
}


@end
