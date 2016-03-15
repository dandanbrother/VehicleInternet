//
//  VIPersonalController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/14.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIPersonalController.h"
#import "NSString+Hash.h"

#define app_id @"1518"
#define app_key @"16e7d03e38018a30cf8db2e125225c26"

@interface VIPersonalController ()

@end

@implementation VIPersonalController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
 
    
    [self getPeccancyInfotmation];
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
    NSString *carInfo = @"{hphm=沪A18P86&classno=6&engineno=110510646&city_id=280&car_type=02}";
    NSDate *date = [NSDate dateWithTimeIntervalSinceNow:0];
    NSNumber *timestamp = [NSNumber numberWithLong:[date timeIntervalSince1970]];
    NSString *signStr = [NSString stringWithFormat:@"%@%@%@%@",app_id,carInfo,timestamp,app_key];
    NSLog(@"%@",signStr);
    NSString *sign = [signStr md5String];
    NSLog(@"%@",sign);
    NSURL *url = [NSURL URLWithString:@"http://www.cheshouye.com/api/weizhang/query_task?"];
    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
    request.HTTPMethod = @"POST";
    request.HTTPBody = [[NSString stringWithFormat:@"%@&%@&%@&%@",@"%7bhphm%3d%e6%b2%aaA18P86%26classno%3d6%26engineno%3d110510646%26city_id%3d280%26car_type%3d02%7d",sign,timestamp,app_id] dataUsingEncoding:NSUTF8StringEncoding];
    
//    NSLog(@"%@",[carInfo stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLQueryAllowedCharacterSet]]);
    
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSMutableDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        NSLog(@"%@",dict);
    }];
    [task resume];
}

@end
