//
//  VIPersonalController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIPersonalController.h"
#import "VIUserModel.h"
#import "JMLogInController.h"

@interface VIPersonalController ()

@end

@implementation VIPersonalController

- (void)viewWillAppear:(BOOL)animated
{
    VIUserModel *user = [VIUserModel currentUser];
    NSLog(@"当前用户---%@",user.username);
    if (user == nil)
    {
        JMLogInController *logVC = [[JMLogInController alloc] init];
        logVC.title = @"登录";
        UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:logVC];
        [self presentViewController:nav animated:YES completion:nil];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
