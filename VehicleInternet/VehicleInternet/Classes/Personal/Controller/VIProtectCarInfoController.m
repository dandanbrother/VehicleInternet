//
//  VIProtectCarInfoController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIProtectCarInfoController.h"
#import "VICarInfoModel.h"
#import "VIProtectCarInfoCell.h"
#import "VICarEwmController.h"
#import "VIProtectCarEwmScanController.h"

@interface VIProtectCarInfoController () <VIProtectCarInfoCellDelegate>
@property (nonatomic, strong) NSMutableArray *carList;

@end

@implementation VIProtectCarInfoController

#pragma mark - 懒加载
- (NSMutableArray *)carList{
    if (!_carList) {
        self.carList = [NSMutableArray array];
    }
    return _carList;
}

- (void)viewWillAppear:(BOOL)animated {

    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"VICarInfoModel"];
    [query whereKey:@"ownerID" equalTo:user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (objects.count !=0 && objects !=nil)
        {
            [self.carList removeAllObjects];
            for (VICarInfoModel *model in objects) {
                [self.carList addObject:model];
            }
            [self.tableView reloadData];
        }
        
    }];
    
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    //覆盖多余空白cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.tableView.showsVerticalScrollIndicator = NO;

    self.tableView.separatorStyle = UITableViewCellSeparatorStyleSingleLine;
    
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.carList.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    VIProtectCarInfoCell *cell = [VIProtectCarInfoCell carInfoCellWithTableView:tableView];
    cell.carInfo = self.carList[indexPath.row];
    cell.delegate = self;
    return cell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 145;
}

#pragma mark - VIMyCarCellDelegate
- (void)clickToShowEwm:(UIButton *)btn carInfo:(VICarInfoModel *)carInfo
{
    VICarEwmController *ewmVC = [VICarEwmController ewmShownWithCarInfo:carInfo];
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:ewmVC];
    [self.navigationController presentViewController:nav animated:YES completion:nil];
}

- (IBAction)updateWithEwm:(id)sender {
    VIProtectCarEwmScanController *carScan = [[VIProtectCarEwmScanController alloc] init];
    carScan.modalPresentationStyle = UIModalPresentationPageSheet;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:carScan];
    
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    

}

- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        
        return nil;
        
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"json解析失败：%@",err);
        
        return nil;
        
    }
    
    return dic;
    
}

@end
