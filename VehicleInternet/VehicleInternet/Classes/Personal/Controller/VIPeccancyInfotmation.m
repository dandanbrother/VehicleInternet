//
//  VIPeccancyInfotmation.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIPeccancyInfotmation.h"

#define app_id @"1518"
#define app_key @"16e7d03e38018a30cf8db2e125225c26"

#define HTML @"<iframe name=\"weizhang\" src=\"http://m.cheshouye.com/api/weizhang/\" width=\"100%\" height=\"100%\" frameborder=\"0\" scrolling=\"no\"></iframe>"

@interface VIPeccancyInfotmation ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation VIPeccancyInfotmation


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    [self.webView loadHTMLString:HTML baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
