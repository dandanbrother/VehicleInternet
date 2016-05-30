//
//  VIModifyPersonalInfoController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/12.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIModifyPersonalInfoController.h"
#import "VIUserModel.h"
#import "LCCoolHUD.h"
#import "AFNetworking.h"

@interface VIModifyPersonalInfoController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (nonatomic, strong) VIUserModel *user;


@end

@implementation VIModifyPersonalInfoController


- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 10)];
    header.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.tableView.tableHeaderView = header;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    UIView *passwordPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, self.nameText.height)];
    self.nameText.leftView = passwordPaddingView;
    self.nameText.leftViewMode = UITextFieldViewModeAlways;
    
    _user = [VIUserModel currentUser];
    self.nameText.text = _user.nickName;
    self.nameText.delegate = self;

}

#pragma mark - UITextFieldDelegate
-  (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.nameText == textField)
    {
        if ([aString length] > 15) {
            return NO;
        }
    }
    return YES;
    
}

- (IBAction)save:(id)sender {
    if (!self.nameText.text.length) {
        [LCCoolHUD showFailure:@"昵称不能为空" zoom:YES shadow:YES];
    } else {
        [self leancloud];
    }
}

- (void)web {
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    NSString *user_id = [user objectForKey:@"user_id"];
    //web修改昵称
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"nickName"] = self.nameText.text;
    params[@"user_id"] = [NSNumber numberWithInt:user_id.intValue];
    
    [session POST:URLSTR(@"set_nickName") parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
        if ([responseObject isKindOfClass:[NSDictionary class]]) {
            if ([responseObject[@"status"] isEqualToString:@"1"])
            {
                //本地存储
                NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                [user setObject:self.nameText.text forKey:@"nickName"];
                //leancloud修改
                VIUserModel *user1 = [VIUserModel currentUser];
                user1.nickName = self.nameText.text;
                [user1 saveInBackground];
                [LCCoolHUD showSuccess:@"设置成功" zoom:YES shadow:YES];
                [self.navigationController popViewControllerAnimated:YES];
            }else
            {
                NSLog(@"web修改失败");
            }
        }
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        
    }];

}

- (void)leancloud
{
    //leancloud修改
    VIUserModel *user1 = [VIUserModel currentUser];
    user1.nickName = self.nameText.text;
    [user1 saveInBackground];
    [LCCoolHUD showSuccess:@"设置成功" zoom:YES shadow:YES];
    [self.navigationController popViewControllerAnimated:YES];
}



@end
