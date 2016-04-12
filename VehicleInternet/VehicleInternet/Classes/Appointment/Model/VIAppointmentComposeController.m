//
//  VIAppointmentComposeController.m
//  VehicleInternet
//
//  Created by joker on 16/3/25.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIAppointmentComposeController.h"
#import "VIAppointmentModel.h"
#import <AVOSCloud/AVOSCloud.h>
#import "UUDatePicker.h"
#import "VIUserModel.h"
#import "ZJAlertListView.h"
#import "VICarInfoModel.h"
//#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
//#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
//#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Search/BMKSearchBase.h>
#import <BaiduMapAPI_Base/BMKUserLocation.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKAnnotation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>


#define PTypeTag 1001
#define CInfoTag 1002

@interface VIAppointmentComposeController () <UITextFieldDelegate,ZJAlertListViewDelegate,ZJAlertListViewDatasource>
@property (weak, nonatomic) IBOutlet UITextField *timeTF;

@property (weak, nonatomic) IBOutlet UITextField *pretrolTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *petrolAmountTF;
@property (weak, nonatomic) IBOutlet UILabel *carBrandLabel;
@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UILabel *carNumLabel;
@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) NSArray *petrolTypes;


@property (nonatomic,strong) NSMutableArray *carInfoArr;
- (IBAction)carInfoBtnClicked;


- (IBAction)submitBtnClicked;

@end

@implementation VIAppointmentComposeController


#pragma mark - 懒加载
- (NSArray *)petrolTypes
{
    if (_petrolTypes == nil) {
        _petrolTypes = @[@"90号",@"93号",@"91号"];
    }
    return _petrolTypes;
}
- (NSMutableArray *)carInfoArr
{
    if (_carInfoArr == nil) {
        _carInfoArr = [NSMutableArray array];
    }
    return _carInfoArr;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    //添加导航栏左面按钮
    
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"退出" style:UIBarButtonItemStyleDone target:self action:@selector(backBtnClicked)];
    self.navigationItem.leftBarButtonItem.tintColor = [UIColor whiteColor];
    
  
    [self loadCarInfo];
    
    
    [self setupCustomView];
}

#pragma mark - 初始化
- (void)setupCustomView
{
    //设置用户名
    VIUserModel *user = [VIUserModel currentUser];
    self.userNameLabel.text = user.nickName;
    
    UUDatePicker *datePicker
    = [[UUDatePicker alloc]initWithframe:CGRectMake(0, 0, KDeviceWidth, 200)
                             PickerStyle:0
                             didSelected:^(NSString *year,
                                           NSString *month,
                                           NSString *day,
                                           NSString *hour,
                                           NSString *minute,
                                           NSString *weekDay) {
                                 
                                 self.timeTF.text = [NSString stringWithFormat:@"%@-%@-%@ %@:%@",year,month,day,hour,minute];
                             }];
    self.timeTF.inputView = datePicker;
}
#pragma mark - UItextfieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    switch (textField.tag) {
        case 10: //加油类型
        {
            ZJAlertListView *alertList = [[ZJAlertListView alloc] initWithFrame:CGRectMake(0, 0, 250, 300)];
            alertList.tag = PTypeTag;
            alertList.titleLabel.text = @"加油类型";
            alertList.datasource = self;
            alertList.delegate = self;
            [alertList show];
            //点击确定的时候，调用它去做点事情
            [alertList setDoneButtonWithBlock:^{
                
                NSIndexPath *selectedIndexPath = self.selectedIndexPath;
                textField.text = self.petrolTypes[selectedIndexPath.row];
                [alertList dismiss];
                self.selectedIndexPath = nil;
                
            }];
        }
            break;
        case 11: //选择加油站
        {
            NSLog(@"选择加油站");
        }
            break;
        default:
            break;
    }
}

#pragma mark - 其他方法
- (void)backBtnClicked
{
    [self.navigationController  dismissViewControllerAnimated:YES completion:nil];
}
- (IBAction)carInfoBtnClicked
{
    
    
    ZJAlertListView *alertList = [[ZJAlertListView alloc] initWithFrame:CGRectMake(0, 0, 250, 300)];
    alertList.tag = CInfoTag;
    alertList.titleLabel.text = @"选择车辆";
    alertList.datasource = self;
    alertList.delegate = self;
    [alertList show];
    //点击确定的时候，调用它去做点事情
    [alertList setDoneButtonWithBlock:^{
        
        NSIndexPath *selectedIndexPath = self.selectedIndexPath;
        VICarInfoModel *model = self.carInfoArr[selectedIndexPath.row];
        self.carBrandLabel.text = model.carBrand;
        self.carNumLabel.text = model.licenseNum;
        [alertList dismiss];
        
    }];

    
    
}

- (IBAction)submitBtnClicked {
    VIUserModel *user = [VIUserModel currentUser];
    VIAppointmentModel *appointment = [[VIAppointmentModel alloc] init];
    appointment.carOwnerName = @"张建明"; //user.nickName;
    appointment.carName = @"奔驰";
    appointment.ownerID = user.objectId;
    appointment.petrolType = @"32号";
    appointment.petrolStation = @"南邮加油站";
    appointment.petrolAmount = @"100升";
    appointment.time = self.timeTF.text;
    appointment.plateNum = @"鲁K88888";

    
    [appointment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        {
            if (succeeded)
            {
                NSLog(@"保存一条预约成功");
            }
        }
    }];
    
}


- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}



#pragma mark - ZJAlertListViewDatasource
- (NSInteger)alertListTableView:(ZJAlertListView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView.tag == PTypeTag) {
        return self.petrolTypes.count;
    }else if (tableView.tag == CInfoTag)
    {
        return self.carInfoArr.count;
    }else
    {
        return 0;
    }
}

- (UITableViewCell *)alertListTableView:(ZJAlertListView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    if (tableView.tag == PTypeTag) {
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
        
        cell.textLabel.text = self.petrolTypes[indexPath.row];
        
        return cell;
        
    }else if (tableView.tag == CInfoTag)
    {
        static NSString *identifier1 = @"identifier1";
        UITableViewCell *cell = [tableView dequeueReusableAlertListCellWithIdentifier:identifier1];
        if (nil == cell)
        {
            cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier1];
        }
        if ( self.selectedIndexPath && NSOrderedSame == [self.selectedIndexPath compare:indexPath])
        {
            cell.imageView.image = [UIImage imageNamed:@"dx_checkbox_red_on.jpg"];
        }
        else
        {
            cell.imageView.image = [UIImage imageNamed:@"dx_checkbox_off"];
        }
        
        VICarInfoModel *model = self.carInfoArr[indexPath.row];
        
        cell.textLabel.text = model.carBrand;
        cell.detailTextLabel.text = model.licenseNum;
        
        
        return cell;
    }else
    {
        return nil;
    }
    
}

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


#pragma mark - 加载数据
- (void)loadCarInfo
{
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"VICarInfoModel"];
    [query whereKey:@"ownerID" equalTo:user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {

            for (VICarInfoModel *model in objects) {
                [self.carInfoArr addObject:model];
        }
    }];

}
@end
