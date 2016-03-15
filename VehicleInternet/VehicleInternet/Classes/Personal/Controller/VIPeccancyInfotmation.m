//
//  VIPeccancyInfotmation.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIPeccancyInfotmation.h"
#import "NSString+Hash.h"

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


- (void)getAllConfig {
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithURL:[NSURL URLWithString:@"http://www.cheshouye.com/api/weizhang/get_all_config"] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
        
        NSLog(@"%@",responseString);
    }];
    [task resume];
}

- (void)getPeccancyInfotmation {
    NSString *carInfo = @"{hphm=渝A75B38&classno=A77439&engineno=5799&city_id=280&car_type=02}";
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSNumber *timestamp = [NSNumber numberWithLong:[date timeIntervalSince1970]];
    NSString *signStr = [NSString stringWithFormat:@"%@%@%@%@",app_id,carInfo,timestamp,app_key];
    NSLog(@"%@",signStr);
    NSString *sign = [signStr md5String];
    NSLog(@"%@",sign);
    NSURL *url = [NSURL URLWithString:@"http://www.cheshouye.com/api/weizhang/query_task?"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString stringWithFormat:@"%@&%@&%@&%@",@"%7bhphm%3d%e6%b8%9dA75B38%26classno%3dA77439%26engineno%3d5799%26city_id%3d332%26car_type%3d02%7d",sign,timestamp,app_id] dataUsingEncoding:NSUTF8StringEncoding];
    
    //    NSLog(@"%@",[carInfo stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dict);
    }];
    [task resume];
}

@end
