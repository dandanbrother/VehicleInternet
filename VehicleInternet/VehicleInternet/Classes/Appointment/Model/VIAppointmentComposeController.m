//
//  VIAppointmentComposeController.m
//  VehicleInternet
//
//  Created by joker on 16/3/25.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIAppointmentComposeController.h"
#import "VIAppointmentModel.h"
#import <AVOSCloud/AVOSCloud.h>
#import "UUDatePicker.h"
#import "VIUserModel.h"

@interface VIAppointmentComposeController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *timeTF;


- (IBAction)submitBtnClicked;

@end

@implementation VIAppointmentComposeController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
  
    
    [self setupCustomView];
}

#pragma mark - 初始化
- (void)setupCustomView
{
    UUDatePicker *datePicker
    = [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, 320, 200)
                             PickerStyle:0
                             didSelected:^(NSString *year,
                                           NSString *month,
                                           NSString *day,
                                           NSString *hour,
                                           NSString *minute,
                                           NSString *weekDay) {
                                 
                                 self.timeTF.text = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",year,month,day,hour,minute];
                             }];
    self.timeTF.inputView = datePicker;
}
#pragma mark - UItextfieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    
}


- (IBAction)submitBtnClicked {
    VIUserModel *user = [VIUserModel currentUser];
    VIAppointmentModel *appointment = [[VIAppointmentModel alloc] init];
    appointment.carOwnerName = @"张建明"; //user.nickName;
    appointment.carName = @"奔驰";
    appointment.ownerID = user.objectId;
    appointment.petrolType = @"32号";
    appointment.petrolStation = @"南邮加油站";
    appointment.petrolAmount = @"100升";
    appointment.time = self.timeTF.text;
    appointment.plateNum = @"鲁K88888";

    
    [appointment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        {
            if (succeeded)
            {
                NSLog(@"保存一条预约成功");
            }
        }
    }];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
@end
