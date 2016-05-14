//
//  VISettingController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/7.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VISettingController.h"
#import "VIUserModel.h"
#import "LCCoolHUD.h"
#import "VIWebUser.h"
#import "AFNetworking.h"

@interface VISettingController ()
@property (weak, nonatomic) IBOutlet UITextField *nickName;

@end

@implementation VISettingController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view from its nib.
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)finish:(id)sender {
    if (!self.nickName.text.length) {
        [LCCoolHUD showFailure:@"昵称不能为空" zoom:YES shadow:YES];
    } else {
        NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
        NSString *user_id = [user objectForKey:@"user_id"];
        //web修改昵称
        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
        NSMutableDictionary *params = [NSMutableDictionary dictionary];
        params[@"nickName"] = self.nickName.text;
        params[@"user_id"] = [NSNumber numberWithInt:user_id.intValue];

        [session POST:URLSTR(@"set_nickName") parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
            
        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
            if ([responseObject isKindOfClass:[NSDictionary class]]) {
                if ([responseObject[@"status"] isEqualToString:@"1"])
                {
                    //本地存储
                    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                    [user setObject:self.nickName.text forKey:@"nickName"];
                    //leancloud修改
                    VIUserModel *user1 = [VIUserModel currentUser];
                    user1.nickName = self.nickName.text;
                    [user1 saveInBackground];
                    [LCCoolHUD showSuccess:@"设置成功" zoom:YES shadow:YES];
                    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
                }else
                {
                    NSLog(@"web修改失败");
                }
            }
            
        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
            
        }];
        
        
        

        
    }
    
}


@end
