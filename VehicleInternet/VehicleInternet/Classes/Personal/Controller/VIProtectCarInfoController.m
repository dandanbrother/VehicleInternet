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
#import "VICarEwmScanController.h"

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
        if (objects.count !=0 && objects !=nil &&objects.count != self.carList.count)
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
    VICarEwmScanController *carScan = [[VICarEwmScanController alloc] init];
    carScan.modalPresentationStyle = UIModalPresentationPageSheet;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:carScan];
    
//    {
//        carBrand = "\U4fdd\U65f6\U6377";
//        licenseNum = Su123213;
//        mileage = 1212;
//        petrol = 200;
//    }
//
    
    [self.navigationController presentViewController:nav animated:YES completion:nil];
    [carScan returnBlock:^(NSString *result) {
        NSDictionary *dict = [self dictionaryWithJsonString:result];
        NSLog(@"%@",dict);
        AVQuery *query = [AVQuery queryWithClassName:@"VICarInfoModel"];
        [query getObjectInBackgroundWithId:dict[@"objectID"] block:^(AVObject *object, NSError *error) {
            [object saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [object setValue:@"0" forKey:@"isEngineGood"];
                [object setValue:@"0" forKey:@"isLightGood"];
                [object setValue:@"0" forKey:@"isTransmissionGood"];
                [object saveInBackground];
                [self.tableView reloadData];
            }];
        }];
        
    }];

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
