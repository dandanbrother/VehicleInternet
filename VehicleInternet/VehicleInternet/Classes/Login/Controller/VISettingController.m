//
//  VISettingController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/7.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VISettingController.h"
#import "VIUserModel.h"

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
        NSLog(@"昵称不能为空");
    } else {
        NSLog(@"成功");
        VIUserModel *user = [VIUserModel currentUser];
        user.nickName = self.nickName.text;
        [user saveInBackground];
        NSLog(@"user %@",user.nickName);
        [self.navigationController dismissViewControllerAnimated:YES completion:nil];
        
    }
    
}


@end
