//
//  JMLogInController.m
//  JMDiary
//
//  Created by joker on 16/3/5.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "JMLogInController.h"
#import "JMRegisterController.h"
#import <AVOSCloud/AVOSCloud.h>
#import "VIUserModel.h"
#import "VISettingController.h"

@interface JMLogInController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
- (IBAction)loginBtnClicked;

- (IBAction)registerBtnClicked;
- (IBAction)logOutBtnClicked;

@end

@implementation JMLogInController


- (instancetype)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        
    }
    return self;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



- (IBAction)loginBtnClicked
{
    [VIUserModel logInWithUsernameInBackground:self.userNameTF.text password:self.passwordTF.text block:^(AVUser *user, NSError *error) {
        if (user != nil) //登录成功
        {
            NSLog(@"登录成功---%@",user);
//            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            VISettingController *vc = [[VISettingController alloc] init];
            [self.navigationController pushViewController:vc animated:YES];
            
        } else //登录失败
        {
            NSLog(@"登录失败---%@",error);
        }
    }];
}

- (IBAction)registerBtnClicked
{
    JMRegisterController *registerVC = [[JMRegisterController alloc] init];
    registerVC.title = @"注册";
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (IBAction)logOutBtnClicked
{
    [VIUserModel logOut];
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}
@end
