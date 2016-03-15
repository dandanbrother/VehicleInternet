//
//  ViewController.m
//  VehicleInternet
//
//  Created by joker on 16/3/13.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "ViewController.h"
#import <AVOSCloud/AVOSCloud.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    AVObject *testObject = [AVObject objectWithClassName:@"TestObject"];
    [testObject setObject:@"bar" forKey:@"foo"];
    [testObject save];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
