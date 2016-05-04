//
//  VIPeccancyInfotmation.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

//C96560
//苏A M903V
//LSVNV4181E2126850
/*h ttp://www.cheshouye.com/api/weizhang/open_task?callback=jQuery1910017118618823587894_1462348408096&chepai_no=AM903V&engine_no=C96560&city_id=56&car_province_id=5&input_cost=0&vcode=%7B%22cookie_str%22%3A%22%22%2C%22verify_code%22%3A%22%22%2C%22vcode_para%22%3A%7B%22vcode_key%22%3A%22%22%7D%7D&td_key=rifij573atbp&car_type=02&uid=0&_=1462348408100
*/


#import "VIPeccancyInfotmation.h"

#define HTML @"<iframe name=\"weizhang\" src=\"http://m.cheshouye.com/api/weizhang/\" width=\"100%\" height=\"100%\" frameborder=\"0\" scrolling=\"no\"></iframe>"
static const NSString *app_id = @"1518";
static const NSString *app_key = @"16e7d03e38018a30cf8db2e125225c26";
static const NSString *requestUrl = @"http://www.cheshouye.com/api/weizhang/query_task?";
//32位小写加密 f979744b136c980b90ecffb94676a50d

//http://light.weiche.me/front/do-index.php
//c	baidu_light
//car_province	苏
//license_plate_num	MA903V
//province	江苏
//pinyin	nanjing
//mobile_num
//engine_num	C96560
//vcode_num

@interface VIPeccancyInfotmation ()

@property (weak, nonatomic) IBOutlet UIWebView *webView;

@end

@implementation VIPeccancyInfotmation


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    NSURL *URL=[NSURL URLWithString:@"http://192.168.1.53:8080/MJServer/login"];//不需要传递参数
    
    //    2.创建请求对象
        NSMutableURLRequest *request=[NSMutableURLRequest requestWithURL:URL];//默认为get请求
        request.timeoutInterval=5.0;//设置请求超时为5秒
        request.HTTPMethod=@"POST";//设置请求方法
    
        //设置请求体
         NSString *param=[NSString stringWithFormat:@""];
         //把拼接后的字符串转换为data，设置请求体
         request.HTTPBody=[param dataUsingEncoding:NSUTF8StringEncoding];
    
    [self.webView loadHTMLString:HTML baseURL:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
