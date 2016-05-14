//
//  VIRequestManager.m
//  网络请求测试
//
//  Created by 倪丁凡 on 16/5/5.
//  Copyright © 2016年 倪丁凡. All rights reserved.
//

#import "VIRequestManager.h"

static const NSString *appkey = @"a3c51c48358ce568";

@implementation VIRequestManager

- (void)requestCarorgWithLsprefixCallBackBlock:(CallBack)callBack {
    NSString *urlStr=[NSString stringWithFormat:@"http://api.jisuapi.com/illegal/carorg?appkey=a3c51c48358ce568"];
    NSURLSession *session = [NSURLSession sharedSession];
    NSURLSessionTask *task = [session dataTaskWithRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:urlStr]] completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
        callBack(dict);
    }];
    [task resume];
    
}

- (void)requestIllegalQueryWithlisenceNo:(NSString *)lisenceNo frameNo:(NSString *)frameNo engineNo:(NSString *)engineNo callBackBlock:(CallBack)callback{
    
    [self requestCarorgWithLsprefixCallBackBlock:^(NSDictionary *data) {
        NSArray *array = [[data valueForKey:@"result"] valueForKey:@"data"];
//        NSLog(@"%@",array);
        //lsprefix
        NSString *lsprefix = [lisenceNo substringToIndex:1];
        NSString *lsnum = [lisenceNo substringWithRange:NSMakeRange(1, 1)];
        
        //carorg
        NSMutableString *carorg = [[NSMutableString alloc] init];
        for (NSDictionary *dict in array) {
            if ([dict[@"lsprefix"] isEqualToString:lsprefix]) {
                if (dict[@"list"] == nil) {
                    carorg = dict[@"carorg"];
                    NSLog(@"%@",carorg);
                } else {
                    for (NSDictionary *data in dict[@"list"]) {
                        if ([data[@"lsnum"] isEqualToString:lsnum]) {
                            carorg = data[@"carorg"];
                        }
                    }
                }
            }
        }
        
        
        NSString *urlStr=[NSString stringWithFormat:@"http://api.jisuapi.com/illegal/query?appkey=a3c51c48358ce568"];
        
        NSURL *url=[NSURL URLWithString:urlStr];
        
        //2.创建请求对象
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:url];
        request.HTTPMethod = @"POST";
        
        // 4、构造请求参数
        NSDictionary *parametersDict = @{@"carorg":carorg, @"lsprefix":lsprefix, @"lsnum":[lisenceNo substringFromIndex:1],@"lstype":@"02",@"frameno":frameNo,@"engineno":engineNo};
        // 4.2、遍历字典，以“key=value&”的方式创建参数字符串。
        NSMutableString *parameterString = [NSMutableString string];
        
        for (NSString *key in parametersDict.allKeys) {
            // 拼接字符串
            [parameterString appendFormat:@"%@=%@&", key, parametersDict[key]];
        }
        // 4.3、截取参数字符串，去掉最后一个“&”，并且将其转成NSData数据类型。
        NSData *parametersData = [[parameterString substringToIndex:parameterString.length - 1] dataUsingEncoding:NSUTF8StringEncoding];
        
        // 5、设置请求报文
        request.HTTPBody = parametersData;
        // 6、构造NSURLSessionConfiguration
        NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
        // 7、创建网络会话
        NSURLSession *session = [NSURLSession sessionWithConfiguration:configuration];
        // 8、创建会话任务
        NSURLSessionTask *task = [session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
            // 10、判断是否请求成功
            if (error) {
//                NSLog(@"error %@",error);
            }else {
                // 如果请求成功，则解析数据。
                NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableLeaves error:&error];
                callback(dict);
                
            }
            
        }];
        // 9、执行任务
        [task resume];
    }];
    

}
@end
