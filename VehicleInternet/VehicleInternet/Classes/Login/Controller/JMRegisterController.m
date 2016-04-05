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

@interface JMRegisterController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;
@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;

@property (weak, nonatomic) IBOutlet UITextField *idenCodeTF;
@property (weak, nonatomic) IBOutlet UITextField *emailTF;


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
//    [AVOSCloud verifySmsCode:self.idenCodeTF.text mobilePhoneNumber:self.phoneNumTF.text callback:^(BOOL succeeded, NSError *error) {
//        if(succeeded){            //验证码正确
//            NSLog(@"验证成功");
//            JMUserModel *userModel = [JMUserModel user];// 新建 AVUser 对象实例
//            userModel.username = self.userNameTF.text;// 设置用户名
//            userModel.password =  self.passwordTF.text;// 设置密码
//            userModel.email = self.emailTF.text;// 设置邮箱
//            
//            [userModel signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
//                if (succeeded)// 注册成功
//                {
//                    NSLog(@"注册成功");
//                } else { //注册失败
//                    NSLog(@"注册失败");
//                }
//            }];
//        }else //验证码错误
//        {
//            NSLog(@"验证失败");
//        }
//    }];
    VIUserModel *userModel = [VIUserModel user];// 新建 AVUser 对象实例
                userModel.username = self.userNameTF.text;// 设置用户名
                userModel.password =  self.passwordTF.text;// 设置密码
//                userModel.email = self.emailTF.text;// 设置邮箱
    
                [userModel signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                    if (succeeded)// 注册成功
                    {
                        NSLog(@"注册成功");
                    } else { //注册失败
                        NSLog(@"注册失败");
                    }
                }];

}

- (IBAction)getIdenCodeBtnClicked
{
    NSString *str = self.phoneNumTF.text;
    [AVOSCloud requestSmsCodeWithPhoneNumber:str callback:^(BOOL succeeded, NSError *error) {
        if (succeeded) {
            NSLog(@"发送验证码成功");
        }else
        {
            NSLog(@"发送验证码失败---%@",error);
        }
    }];
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}


@end
