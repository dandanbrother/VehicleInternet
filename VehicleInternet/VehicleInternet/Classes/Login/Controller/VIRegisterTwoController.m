//
//  VIRegisterTwoController.m
//  VehicleInternet
//
//  Created by joker on 16/5/23.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIRegisterTwoController.h"
#import "AFNetworking.h"
#import "LCCoolHUD.h"
#import <AVOSCloud/AVOSCloud.h>
#import "VIUserModel.h"
#import "VISettingController.h"
@interface VIRegisterTwoController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF2;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation VIRegisterTwoController

- (void)viewDidLoad {
    [super viewDidLoad];
    [_confirmBtn addTarget:self action:@selector(confirmBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
    self.title = @"注册";
    
}




- (void)leancloudRegister
{

    if (self.userNameTF.text.length == 0 || self.userNameTF.text == nil) {
        [LCCoolHUD showFailure:@"用户名不能为空" zoom:YES shadow:YES];
        return;
    }
    if (self.passwordTF.text.length == 0 || self.passwordTF.text == nil) {
        [LCCoolHUD showFailure:@"密码不能为空" zoom:YES shadow:YES];
        return;
    }
    if (![_passwordTF.text isEqualToString:_passwordTF2.text]) {
        [LCCoolHUD showFailure:@"两次输入密码不一致" zoom:YES shadow:YES];
        return;
    }
    //leancloud注册
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *phone = [user objectForKey:@"Rphone"];
    VIUserModel *userModel = [VIUserModel user];// 新建 AVUser 对象实例
    userModel.username = self.userNameTF.text;// 设置用户名
    userModel.password =  self.passwordTF.text;// 设置密码
    userModel.mobilePhoneNumber = phone;
    [userModel signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)// 注册成功
        {
            [LCCoolHUD showSuccess:@"注册成功" zoom:YES shadow:YES];
            [VIUserModel logInWithUsernameInBackground:self.userNameTF.text password:self.passwordTF.text block:^(AVUser *user, NSError *error) {
                if (user) {
                    NSLog(@"登录到");
                    VISettingController *vc = [[VISettingController alloc] init];
                    [self.navigationController pushViewController:vc animated:YES];
                }
            }];
        } else { //注册失败
            switch (error.code) {
                case 202:
                    [LCCoolHUD showFailure:@"用户名已被注册" zoom:YES shadow:YES];
                    break;
                case 127:
                    [LCCoolHUD showFailure:@"无效手机号" zoom:YES shadow:YES];
                    break;
                    
            }
            
            NSLog(@"%@",error);
        }
    }];
}

- (void)confirmBtnClicked:(UIButton *)btn
{
    [self leancloudRegister];
}


-(void)webRegister
{
    //web注册
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = self.userNameTF.text;
    params[@"password"] = self.passwordTF.text;
    //    params[@"phone_number"] = self.phoneNumTF.text;
    [session POST:URLSTR(@"register") parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"status"] isEqualToString:@"1"])
            {
                NSString *user_id = responseObject[@"user_id"];
                NSString *phone_number = responseObject[@"phone_number"];
                //本地存储
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:user_id forKey:@"user_id"];
                [user setObject:phone_number forKey:@"phone_number"];
                //leancloud注册
                [self leancloudRegister];
            }else
            {
                NSLog(@"web注册失败");
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    
}

@end
