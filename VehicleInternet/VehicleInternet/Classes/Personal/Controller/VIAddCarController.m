//
//  VIAddCarController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/5.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIAddCarController.h"
#import "VICarInfoModel.h"
#import "ZJAlertListView.h"
#import "VICarEwmScanController.h"
#import "LCCoolHUD.h"
#import "AFNetworking.h"

@interface VIAddCarController () <UITextFieldDelegate,ZJAlertListViewDelegate,ZJAlertListViewDatasource>
@property (weak, nonatomic) IBOutlet UITextField *carBrand;
@property (weak, nonatomic) IBOutlet UITextField *licenseNum;
@property (weak, nonatomic) IBOutlet UITextField *mileage;
@property (weak, nonatomic) IBOutlet UITextField *engineNum;
@property (weak, nonatomic) IBOutlet UITextField *frameNum;
@property (weak, nonatomic) IBOutlet UITextField *petrol;
- (IBAction)carBrandBtnClicked;
- (IBAction)saveBtnClicked;


@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) NSArray *carBrandTypes;

@end

@implementation VIAddCarController


#pragma mark - 懒加载
- (NSArray *)carBrandTypes{
    if (!_carBrandTypes) {
        self.carBrandTypes = [NSArray arrayWithObjects:@"奔驰",@"宝马",@"大众",@"丰田",@"保时捷",@"巴博斯",@"MINI",@"本田",@"铃木",@"雷克萨斯",@"朗世",@"马自达",@"别克",@"福特",@"宾利",@"捷豹",@"路虎",nil];
    }
    return _carBrandTypes;
}

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)save:(id)sender {
    
    
    VICarEwmScanController *carScan = [[VICarEwmScanController alloc] init];
    carScan.modalPresentationStyle = UIModalPresentationPageSheet;
    UINavigationController *nav = [[UINavigationController alloc] initWithRootViewController:carScan];
//    NSDictionary *dict = @{
//                           @"carBrand" : self.carInfo.carBrand,
//                           @"mileage" : self.carInfo.mileage,
//                           @"licenseNum" : self.carInfo.licenseNum,
//                           @"petrol" : self.carInfo.petrol
//                           };
    
    __weak typeof(self) weakSelf = self;

    [self.navigationController presentViewController:nav animated:YES completion:nil];
    [carScan returnBlock:^(NSString *result) {
        NSDictionary *dict = [self dictionaryWithJsonString:result];
        weakSelf.mileage.text = dict[@"mileage"];
        weakSelf.licenseNum.text = dict[@"licenseNum"];
        weakSelf.petrol.text = dict[@"petrol"];
        weakSelf.carBrand.text = dict[@"carBrand"];
        
    }];
    
}

#pragma mark - ZJAlertListViewDatasource
- (NSInteger)alertListTableView:(ZJAlertListView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.carBrandTypes.count;
    
}

- (UITableViewCell *)alertListTableView:(ZJAlertListView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    UITableViewCell *cell = [tableView dequeueReusableAlertListCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    if ( self.selectedIndexPath && NSOrderedSame == [self.selectedIndexPath compare:indexPath])
    {
        cell.imageView.image = [UIImage imageNamed:@"dx_checkbox_red_on.jpg"];
    }
    else
    {
        cell.imageView.image = [UIImage imageNamed:@"dx_checkbox_off"];
    }
    
    cell.textLabel.text = self.carBrandTypes[indexPath.row];
    
    return cell;
}

#pragma mark - ZJAlertListViewDelegate
- (void)alertListTableView:(ZJAlertListView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView alertListCellForRowAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"dx_checkbox_off"];
    NSLog(@"didDeselectRowAtIndexPath:%ld", (long)indexPath.row);
}

- (void)alertListTableView:(ZJAlertListView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    UITableViewCell *cell = [tableView alertListCellForRowAtIndexPath:indexPath];
    cell.imageView.image = [UIImage imageNamed:@"dx_checkbox_red_on.jpg"];
    NSLog(@"didSelectRowAtIndexPath:%ld", (long)indexPath.row);
}

- (IBAction)carBrandBtnClicked {
    ZJAlertListView *alertList = [[ZJAlertListView alloc] initWithFrame:CGRectMake(0, 0, 250, 300)];
    alertList.titleLabel.text = @"弹框";
    alertList.datasource = self;
    alertList.delegate = self;
    [alertList show];
    //点击确定的时候，调用它去做点事情
    [alertList setDoneButtonWithBlock:^{
        
        NSIndexPath *selectedIndexPath = self.selectedIndexPath;
        self.carBrand.text = self.carBrandTypes[selectedIndexPath.row];
        [alertList dismiss];
        
    }];
}

- (IBAction)saveBtnClicked {
    
    if ((self.carBrand.text.length != 0 ) && (self.licenseNum.text.length != 0 ) && (self.mileage.text.length != 0 ) && (self.petrol.text.length != 0 )) {
        

        //Web保存
//        NSUserDefaults *user1 = [NSUserDefaults standardUserDefaults];
//        NSString *user_id = [user1 objectForKey:@"user_id"];
//        AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
//        NSMutableDictionary *params = [NSMutableDictionary dictionary];
//        params[@"user_id"] = [NSNumber numberWithInt:user_id.intValue];
//        params[@"carBrand"] = self.carBrand.text;
//        params[@"licenseNum"] = self.licenseNum.text;
//        params[@"mileage"] = self.mileage.text;
//        params[@"petrol"] = self.petrol.text;
//        params[@"engineNum"] = self.engineNum.text;
//        params[@"frameNum"] = self.frameNum.text;
//        params[@"isLightGood"] = @"1";
//        params[@"isEngineGood"] = @"1";
//        params[@"isTransGood"] = @"1";
        

        [self leancloudsaveWithCar_id:@"1"];
        
//        [session POST:URLSTR(@"bindCar") parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
//            
//        } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable responseObject) {
//            if ([responseObject isKindOfClass:[NSDictionary class]]) {
//                if ([responseObject[@"status"] isEqualToString:@"1"])
//                {
//                    NSLog(@"%@,%@,%@",responseObject[@"status"],responseObject[@"msg"],responseObject[@"car_id"]);
//                    //leancloud修改
//                    [self leancloudsaveWithCar_id:responseObject[@"car_id"]];
//                    
//                    [LCCoolHUD showSuccess:@"添加成功" zoom:YES shadow:YES];
//                    
//                    [self.navigationController popViewControllerAnimated:YES];
//                }else
//                {
//                    NSLog(@"web添加车辆失败");
//                }
//            }
//            
//        } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
//            
//        }];

        
    } else {
        [LCCoolHUD showFailure:@"信息不全" zoom:YES shadow:YES];
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
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

- (void)leancloudsaveWithCar_id:(NSString *)car_id
{
    AVUser *user = [AVUser currentUser];
    VICarInfoModel *model = [VICarInfoModel object];
    model.carBrand = self.carBrand.text;
    model.licenseNum = self.licenseNum.text;
    model.mileage = self.mileage.text;
    model.petrol = self.petrol.text;
    model.isLightGood = @"1";
    model.isEngineGood = @"1";
    model.isTransGood = @"1";
    model.ownerID = user.objectId;
//    model.car_id = car_id;
    model.engineNum = self.engineNum.text;
    model.frameNum = self.frameNum.text;
    [model saveInBackground];
    [LCCoolHUD showSuccess:@"添加成功" zoom:YES shadow:YES];
    [self.navigationController popViewControllerAnimated:YES];
}
@end
