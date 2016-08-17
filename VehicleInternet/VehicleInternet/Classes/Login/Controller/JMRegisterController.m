//
//  JMRegisterController.m
//  JMDiary
//
//  Created by joker on 16/3/5.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "JMRegisterController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "VIUserModel.h"
#import "VISettingController.h"
#import "LCCoolHUD.h"
#import "VIWebUser.h"
#import "AFNetworking.h"

@interface JMRegisterController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;

@property (weak, nonatomic) IBOutlet UITextField *idenCodeTF;



- (IBAction)registerBtnClicked;

- (IBAction)getIdenCodeBtnClicked;

@end

@implementation JMRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

- (IBAction)registerBtnClicked
{
    VIUserModel *userModel = [VIUserModel user];// 新建 AVUser 对象实例
                userModel.username = self.userNameTF.text;// 设置用户名
                userModel.password =  self.passwordTF.text;// 设置密码
    
    if (self.phoneNumTF.text.length == 0 || self.phoneNumTF.text == nil) {
        [LCCoolHUD showFailure:@"手机不能为空" zoom:YES shadow:YES];
        return;
    }
    if (self.phoneNumTF.text.length != 11) {
        [LCCoolHUD showFailure:@"请输入11位手机号码" zoom:YES shadow:YES];
        return;
    }
    if (![self isMobileNumber:self.phoneNumTF.text])
    {
        [LCCoolHUD showFailure:@"请输入正确的手机号码" zoom:YES shadow:YES];
        return;
    }

    if (self.idenCodeTF.text.length == 0 || self.idenCodeTF.text == nil) {
            [LCCoolHUD showFailure:@"验证码不能为空" zoom:YES shadow:YES];
        return;
    }
    if (self.userNameTF.text.length == 0 || self.userNameTF.text == nil) {
        [LCCoolHUD showFailure:@"用户名不能为空" zoom:YES shadow:YES];
        return;
    }
    if (self.passwordTF.text.length == 0 || self.passwordTF.text == nil) {
        [LCCoolHUD showFailure:@"密码不能为空" zoom:YES shadow:YES];
        return;
    }
    
    [AVOSCloud verifySmsCode:self.idenCodeTF.text mobilePhoneNumber:self.phoneNumTF.text callback:^(BOOL succeeded, NSError *error) {
        if(succeeded){            //验证码正确
//            NSLog(@"验证成功");
            //web注册
            AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
            NSMutableDictionary *params = [NSMutableDictionary dictionary];
            params[@"username"] = self.userNameTF.text;
            params[@"password"] = self.passwordTF.text;
            params[@"phone_number"] = self.phoneNumTF.text;
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

            

            
        } else //验证码错误
        {
            NSLog(@"error %@",error);
            [LCCoolHUD showFailure:@"验证码错误" zoom:YES shadow:YES];

        }
    }];
    



    
    
    
}

- (IBAction)getIdenCodeBtnClicked
{
    NSString *str = self.phoneNumTF.text;
    if ([self isMobileNumber:str]) {
        [AVOSCloud requestSmsCodeWithPhoneNumber:str callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"发送验证码成功");
            }else
            {
                NSLog(@"发送验证码失败---%@",error);
            }
        }];
    }else
    {
        [LCCoolHUD showFailure:@"请输入正确的手机号码" zoom:YES shadow:YES];
    }

}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}

- (BOOL)isMobileNumber:(NSString *)mobileNum {
    
    //    电信号段:133/153/180/181/189/177
    
    //    联通号段:130/131/132/155/156/185/186/145/176
    
    //    移动号段:134/135/136/137/138/139/150/151/152/157/158/159/182/183/184/187/188/147/178
    
    //    虚拟运营商:170
    
    NSString *MOBILE = @"^1(3[0-9]|4[57]|5[0-35-9]|8[0-9]|7[06-8])\\d{8}$";
    
    NSPredicate *regextestmobile = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", MOBILE];
    
    return [regextestmobile evaluateWithObject:mobileNum];
    
}

- (void)leancloudRegister
{
    
    //leancloud注册
    VIUserModel *userModel = [VIUserModel user];// 新建 AVUser 对象实例
    userModel.username = self.userNameTF.text;// 设置用户名
    userModel.password =  self.passwordTF.text;// 设置密码
    [userModel signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (succeeded)// 注册成功
        {
            [LCCoolHUD showSuccess:@"注册成功" zoom:YES shadow:YES];
            [VIUserModel logInWithUsernameInBackground:self.userNameTF.text password:self.passwordTF.text block:^(AVUser *user, NSError *error) {
                if (user) {
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


@end
