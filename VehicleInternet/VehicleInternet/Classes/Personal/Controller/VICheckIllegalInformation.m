//
//  VICheckIllegalInformation.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/5/11.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VICheckIllegalInformation.h"
#import "VIRequestManager.h"
#import "LCCoolHUD.h"

@interface VICheckIllegalInformation ()
@property (nonatomic, strong) NSMutableArray *list;

@end


@implementation VICheckIllegalInformation

#pragma mark - 懒加载
- (NSMutableArray *)list{
    if (!_list) {
        self.list = [NSMutableArray array];
    }
    return _list;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:83/255.0 green:125/255.0 blue:221/255.0 alpha:1.0];
    self.navigationItem.title = @"违章查询";
    //覆盖多余空白cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.showsVerticalScrollIndicator = NO;
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG.png"]];
    
}

- (void)viewWillAppear:(BOOL)animated {
    VIRequestManager *manager = [[VIRequestManager alloc] init];
    [manager requestIllegalQueryWithlisenceNo:_model.licenseNum frameNo:_model.frameNum engineNo:_model.engineNum callBackBlock:^(NSDictionary *data, NSError * _Nullable error){
        if (![data[@"status"] isEqual:@0]) {
            dispatch_async(dispatch_get_main_queue(), ^{
                UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 30, 80, 100, 10)];
                label.text = @"数据有错";
                [self.view addSubview:label];
                
            });
        } else {
            
            [self.list removeAllObjects];
//            NSArray *array = @[
//                               @{
//                                   @"time": @"2015-06-23 18:24:00.0",
//                                   @"address": @"赵非公路鼓浪路北约20米",
//                                   @"content": @"违反规定停放、临时停车且驾驶人不在现场或驾驶人虽在现场拒绝立即驶离，妨碍其他车辆、行人通行的",
//                                   @"legalnum": @"",
//                                   @"price": @"0",
//                                   @"id": @"3500713",
//                                   @"score": @"0"
//                                   },
//                               @{
//                                   @"time": @"2015-06-05 18:20:00.0",
//                                   @"address": @"新松江路近人民北路东侧路段",
//                                   @"content": @"违反规定停放、临时停车且驾驶人不在现场或驾驶人虽在现场拒绝立即驶离，妨碍其他车辆、行人通行的",
//                                   @"legalnum": @"",
//                                   @"price": @"0",
//                                   @"id": @"3500714",
//                                   @"score": @"0"
//                                   },
//                               @{
//                                   @"time": @"2015-06-08 18:22:00.0",
//                                   @"address": @"鼓浪路近291弄路段",
//                                   @"content": @"违反规定停放、临时停车且驾驶人不在现场或驾驶人虽在现场拒绝立即驶离，妨碍其他车辆、行人通行的",
//                                   @"legalnum": @"",
//                                   @"price": @"0",
//                                   @"id": @"3500715",
//                                   @"score": @"0"
//                                   }
//                               ];
//            self.list = [NSMutableArray arrayWithArray:array];

            NSDictionary *result = data[@"result"];
            if ([result[@"list"] respondsToSelector:@selector(isEqualToString:)]) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake([UIScreen mainScreen].bounds.size.width/2 - 30, 80, 100, 10)];
                    label.text = @"没有违章";
                    [self.view addSubview:label];
    
                });
            } else {
                for (NSDictionary *dict in result[@"list"]) {
                    [self.list addObject:dict];
                }
                [self.tableView reloadData];
            }
            
            [self.tableView reloadData];
        }
    }];
    

}

#pragma mark - UITableViewDelegate
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.list.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *ID = @"info";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
    }
    UILabel *time = [[UILabel alloc] initWithFrame:CGRectMake(8, 5, 304, 21)];
    UILabel *address = [[UILabel alloc] initWithFrame:CGRectMake(8, 20, 304, 21)];
    UILabel *content = [[UILabel alloc] initWithFrame:CGRectMake(8, 30, 304, 60)];
    content.lineBreakMode = UILineBreakModeWordWrap;
    content.numberOfLines = 0;
    content.font = [UIFont systemFontOfSize:13];
    time.font = [UIFont systemFontOfSize:14];
    address.font = [UIFont systemFontOfSize:14];
    
    NSDictionary *dict = _list[indexPath.row];
    time.text = dict[@"time"];
    address.text = dict[@"address"];
    content.text = dict[@"content"];
    
    [cell addSubview:time];
    [cell addSubview:address];
    [cell addSubview:content];
    
    return cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 80;
}



@end
