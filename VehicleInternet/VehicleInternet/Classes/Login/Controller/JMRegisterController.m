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
#import "LCCoolHUD.h"
#import "VIWebUser.h"
#import "AFNetworking.h"
#import "VIRegisterTwoController.h"

@interface JMRegisterController ()

@property (weak, nonatomic) IBOutlet UITextField *phoneNumTF;

@property (weak, nonatomic) IBOutlet UITextField *idenCodeTF;

@property (weak, nonatomic) IBOutlet UIButton *yzmBtn;


- (IBAction)registerBtnClicked;

- (IBAction)getIdenCodeBtnClicked;

@end

@implementation JMRegisterController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"验证码";
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (IBAction)registerBtnClicked
{

    
    if (self.phoneNumTF.text.length == 0 || self.phoneNumTF.text == nil) {
        [LCCoolHUD showFailure:@"手机不能为空" zoom:YES shadow:YES];
        return;
    }


    if (self.idenCodeTF.text.length == 0 || self.idenCodeTF.text == nil) {
            [LCCoolHUD showFailure:@"验证码不能为空" zoom:YES shadow:YES];
        return;
    }

    
    [AVOSCloud verifySmsCode:self.idenCodeTF.text mobilePhoneNumber:self.phoneNumTF.text callback:^(BOOL succeeded, NSError *error) {
        if(succeeded){            //验证码正确
            NSLog(@"验证成功");
            
            [LCCoolHUD showSuccess:@"验证成功" zoom:YES shadow:YES];
            NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
            [user setObject:_phoneNumTF.text forKey:@"Rphone"];
            
            VIRegisterTwoController *vc = [[VIRegisterTwoController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];

            
        } else //验证码错误
        {
            [LCCoolHUD showFailure:@"验证码错误" zoom:YES shadow:YES];

        }
    }];
    



    
    
    
}

- (IBAction)getIdenCodeBtnClicked
{
    NSString *str = self.phoneNumTF.text;
    if (str.length != 11) {
        [LCCoolHUD showFailure:@"请输入11位手机号码" zoom:YES shadow:YES];
        return;
    }
    if (![self isMobileNumber:str])
    {
        [LCCoolHUD showFailure:@"请输入正确的手机号码" zoom:YES shadow:YES];
        return;
    }
    
        [AVOSCloud requestSmsCodeWithPhoneNumber:str callback:^(BOOL succeeded, NSError *error) {
            if (succeeded) {
                NSLog(@"发送验证码成功");
                [LCCoolHUD showSuccess:@"发送验证码成功" zoom:YES shadow:YES];
                [self openCountdown];
            }else
            {
                NSLog(@"发送验证码失败---%@",error);
                [LCCoolHUD showFailure:@"发送失败,请稍后重试" zoom:YES shadow:YES];
            }
        }];
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

// 开启倒计时效果
-(void)openCountdown{
    
    __block NSInteger time = 59; //倒计时时间
    
    dispatch_queue_t queue = dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0);
    dispatch_source_t _timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, queue);
    
    dispatch_source_set_timer(_timer,dispatch_walltime(NULL, 0),1.0*NSEC_PER_SEC, 0); //每秒执行
    
    dispatch_source_set_event_handler(_timer, ^{
        
        if(time <= 0){ //倒计时结束，关闭
            
            dispatch_source_cancel(_timer);
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮的样式
                [self.yzmBtn setTitle:@"获取验证码" forState:UIControlStateNormal];
//                [self.yzmBtn setTitleColor:[UIColor colorFromHexCode:@"FB8557"] forState:UIControlStateNormal];
                self.yzmBtn.userInteractionEnabled = YES;
            });
            
        }else{
            
            int seconds = time % 60;
            dispatch_async(dispatch_get_main_queue(), ^{
                
                //设置按钮显示读秒效果
                [self.yzmBtn setTitle:[NSString stringWithFormat:@"重新发送(%.2d)", seconds] forState:UIControlStateNormal];
//                [self.yzmBtn setTitleColor:[UIColor colorFromHexCode:@"979797"] forState:UIControlStateNormal];
                self.yzmBtn.userInteractionEnabled = NO;
            });
            time--;
        }
    });
    dispatch_resume(_timer);
}

@end
