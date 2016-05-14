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
#import "LCCoolHUD.h"
#import "VIWebUser.h"
#import "AFNetworking.h"

@interface JMLogInController ()
@property (weak, nonatomic) IBOutlet UITextField *userNameTF;

@property (weak, nonatomic) IBOutlet UITextField *passwordTF;
- (IBAction)loginBtnClicked;

- (IBAction)registerBtnClicked;

@property (weak, nonatomic) IBOutlet UIImageView *bubble1;
@property (weak, nonatomic) IBOutlet UIImageView *bubble2;
@property (weak, nonatomic) IBOutlet UIImageView *bubble3;
@property (weak, nonatomic) IBOutlet UIImageView *bubble4;
@property (weak, nonatomic) IBOutlet UIImageView *bubble5;
@property (weak, nonatomic) IBOutlet UIButton *loginBtn;
@property (weak, nonatomic) IBOutlet UIButton *signinBtn;
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

    //TextField 光标缩进
    UIView *usernamePaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, self.userNameTF.frame.size.height)];
    self.userNameTF.leftView = usernamePaddingView;
    self.userNameTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIView *passwordPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 44, self.passwordTF.frame.size.height)];
    self.passwordTF.leftView = passwordPaddingView;
    self.passwordTF.leftViewMode = UITextFieldViewModeAlways;
    
    UIImageView *userImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fa-user"]];
    CGRect rect = userImageView.frame;
    rect.origin = CGPointMake(13, 10);  // 错误: .frame.orgine = CGPointMake()
    userImageView.frame = rect;
    [self.userNameTF addSubview:userImageView];
    
    UIImageView *passwordImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"fa-key"]];
    CGRect rect2 = passwordImageView.frame;
    rect2.origin = CGPointMake(13, 10);  // 错误: .frame.orgine = CGPointMake()
    passwordImageView.frame = rect2;
    [self.passwordTF addSubview:passwordImageView];
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStyleDone target:self action:@selector(cancel)];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:103/255.0 green:149/255.0 blue:225/255.0 alpha:1];
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
}

- (void)viewWillAppear:(BOOL)animated {
    self.bubble1.transform = CGAffineTransformMakeScale(0, 0);
    self.bubble2.transform = CGAffineTransformMakeScale(0, 0);
    self.bubble3.transform = CGAffineTransformMakeScale(0, 0);
    self.bubble4.transform = CGAffineTransformMakeScale(0, 0);
    self.bubble5.transform = CGAffineTransformMakeScale(0, 0);
    self.userNameTF.center = CGPointMake(self.userNameTF.center.x - self.view.bounds.size.width, self.userNameTF.center.y);
    self.passwordTF.center = CGPointMake(self.passwordTF.center.x - self.view.bounds.size.width, self.passwordTF.center.y);
    self.loginBtn.center = CGPointMake(self.loginBtn.center.x - self.view.bounds.size.width, self.loginBtn.center.y);
    self.signinBtn.center = CGPointMake(self.signinBtn.center.x - self.view.bounds.size.width, self.signinBtn.center.y);
}

- (void)viewDidDisappear:(BOOL)animated {
    [self.userNameTF.layer removeAnimationForKey:@"position"];
    [self.passwordTF.layer removeAnimationForKey:@"position"];
    [self.loginBtn.layer removeAnimationForKey:@"position"];
    [self.signinBtn.layer removeAnimationForKey:@"position"];
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:YES];
    //泡泡动画
    [UIView animateWithDuration:0.3 delay:0 usingSpringWithDamping:0.4 initialSpringVelocity:0 options:0 animations:^{
        self.bubble3.transform = CGAffineTransformMakeScale(1, 1);
        self.bubble4.transform = CGAffineTransformMakeScale(1, 1);
        
    } completion:nil];
    
    //泡泡动画
    [UIView animateWithDuration:0.3 delay:0.1 usingSpringWithDamping:1 initialSpringVelocity:0 options:0 animations:^{
        self.bubble1.transform = CGAffineTransformMakeScale(1, 1);
        self.bubble2.transform = CGAffineTransformMakeScale(1, 1);
        self.bubble5.transform = CGAffineTransformMakeScale(1, 1);
        
    } completion:nil];
    
    [CATransaction begin];
    
    CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"position"];
    animation.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.userNameTF.center.x, self.userNameTF.center.y)];
    animation.toValue = [NSValue valueWithCGPoint:CGPointMake(self.userNameTF.center.x + self.view.bounds.size.width, self.userNameTF.center.y)];
    animation.beginTime = 0.3 + CACurrentMediaTime();
    animation.duration = 0.3;
    animation.removedOnCompletion = NO;
    animation.fillMode = kCAFillModeForwards;
    [CATransaction setCompletionBlock:^{
         self.userNameTF.center = CGPointMake(self.userNameTF.center.x + self.view.bounds.size.width, self.userNameTF.center.y);
    }];
    [self.userNameTF.layer addAnimation:animation forKey:@"position"];
    
    CABasicAnimation *animation1 = [CABasicAnimation animationWithKeyPath:@"position"];
    animation1.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.passwordTF.center.x, self.passwordTF.center.y)];
    animation1.toValue = [NSValue valueWithCGPoint:CGPointMake(self.passwordTF.center.x + self.view.bounds.size.width, self.passwordTF.center.y)];
    animation1.duration = 0.3;
    animation1.beginTime = 0.4 + CACurrentMediaTime();
    animation1.removedOnCompletion = NO;
    animation1.fillMode = kCAFillModeForwards;
    [CATransaction setCompletionBlock:^{
        self.passwordTF.center = CGPointMake(self.passwordTF.center.x + self.view.bounds.size.width, self.passwordTF.center.y);
    }];
    [self.passwordTF.layer addAnimation:animation1 forKey:@"position"];


    CABasicAnimation *animation2 = [CABasicAnimation animationWithKeyPath:@"position"];
    animation2.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.loginBtn.center.x, self.loginBtn.center.y)];
    animation2.toValue = [NSValue valueWithCGPoint:CGPointMake(self.loginBtn.center.x + self.view.bounds.size.width, self.loginBtn.center.y)];
    animation2.duration = 0.3;
    animation2.beginTime = 0.5 + CACurrentMediaTime();
    animation2.removedOnCompletion = NO;
    animation2.fillMode = kCAFillModeForwards;
    [CATransaction setCompletionBlock:^{
        self.loginBtn.center = CGPointMake(self.loginBtn.center.x + self.view.bounds.size.width, self.loginBtn.center.y);
    }];
    [self.loginBtn.layer addAnimation:animation2 forKey:@"position"];
    

    CABasicAnimation *animation3 = [CABasicAnimation animationWithKeyPath:@"position"];
    animation3.fromValue = [NSValue valueWithCGPoint:CGPointMake(self.signinBtn.center.x, self.signinBtn.center.y)];
    animation3.toValue = [NSValue valueWithCGPoint:CGPointMake(self.signinBtn.center.x + self.view.bounds.size.width, self.signinBtn.center.y)];
    animation3.duration = 0.3;
    animation3.beginTime = 0.6 + CACurrentMediaTime();
    animation3.removedOnCompletion = NO;
    animation3.fillMode = kCAFillModeForwards;
    [CATransaction setCompletionBlock:^{
        self.signinBtn.center = CGPointMake(self.signinBtn.center.x + self.view.bounds.size.width, self.signinBtn.center.y);
    }];
    [self.signinBtn.layer addAnimation:animation3 forKey:@"position"];
    
    [CATransaction commit];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)loginBtnClicked
{
    //web修改昵称
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"username"] = self.userNameTF.text;
    params[@"password"] = self.passwordTF.text;
    
    [session POST:URLSTR(@"login") parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"status"] isEqualToString:@"1"])
            {
                NSLog(@"web登录成功");
                //本地存储
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:responseObject[@"user_id"] forKey:@"user_id"];
                [user setObject:responseObject[@"phone_number"] forKey:@"phone_number"];
                //leancloud登录
                [self leancloudlogin];
 
            }else
            {
                NSLog(@"web登录失败");
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];
    

}

- (IBAction)registerBtnClicked
{
    JMRegisterController *registerVC = [[JMRegisterController alloc] init];
    registerVC.title = @"注册";
    [self.navigationController pushViewController:registerVC animated:YES];
}

- (void)cancel
{
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)leancloudlogin
{
    //leancloud登录
    [VIUserModel logInWithUsernameInBackground:self.userNameTF.text password:self.passwordTF.text block:^(AVUser *user, NSError *error) {
        if (user != nil) //登录成功
        {
            [LCCoolHUD showSuccess:@"登陆成功" zoom:YES shadow:YES];
            NSLog(@"登录成功---%@",user);
            [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            
            
        } else //登录失败
        {
            if (!self.userNameTF.text.length) {
                [LCCoolHUD showFailure:@"用户名不能为空" zoom:YES shadow:YES];
            } else if (!self.passwordTF.text.length) {
                [LCCoolHUD showFailure:@"密码不能为空" zoom:YES shadow:YES];
            } else if (self.userNameTF.text.length && error.code == 211) {
                [LCCoolHUD showFailure:@"用户未注册" zoom:YES shadow:YES];
            } else if (error.code == 210) {
                [LCCoolHUD showFailure:@"密码错误" zoom:YES shadow:YES];
            }
        }
    }];
}
@end
