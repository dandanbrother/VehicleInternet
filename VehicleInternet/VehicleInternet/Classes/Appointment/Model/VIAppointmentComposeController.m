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
#import "LCCoolHUD.h"

#define PTypeTag 1001
#define CInfoTag 1002
#define LCornerR 5

@interface VIAppointmentComposeController () <UITextFieldDelegate,ZJAlertListViewDelegate,ZJAlertListViewDatasource>
@property (weak, nonatomic) IBOutlet UITextField *timeTF;
@property (weak, nonatomic) IBOutlet UITextField *licenseNumTF;

@property (weak, nonatomic) IBOutlet UITextField *pretrolTypeTF;
@property (weak, nonatomic) IBOutlet UITextField *petrolAmountTF;
@property (weak, nonatomic) IBOutlet UITextField *petrolStationTF;
@property (weak, nonatomic) IBOutlet UITextField *carBrandTF;

@property (weak, nonatomic) IBOutlet UILabel *userNameLabel;

@property (weak, nonatomic) IBOutlet UIButton *submitBtn;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) NSArray *petrolTypes;


@property (nonatomic,strong) NSMutableArray *carInfoArr;


/**
 *  设置圆角用
 */
@property (weak, nonatomic) IBOutlet UILabel *l1;
@property (weak, nonatomic) IBOutlet UILabel *l2;
@property (weak, nonatomic) IBOutlet UILabel *l3;
@property (weak, nonatomic) IBOutlet UILabel *l4;
@property (weak, nonatomic) IBOutlet UILabel *l5;
@property (weak, nonatomic) IBOutlet UILabel *l6;
@property (weak, nonatomic) IBOutlet UILabel *l7;

- (IBAction)carInfoBtnClicked;
- (IBAction)submitBtnClicked;
- (IBAction)petrolTypeBtnClicked;

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
    //设置圆角
    self.l1.layer.cornerRadius = LCornerR;
    self.l2.layer.cornerRadius = LCornerR;
    self.l3.layer.cornerRadius = LCornerR;
    self.l4.layer.cornerRadius = LCornerR;
    self.l5.layer.cornerRadius = LCornerR;
    self.l6.layer.cornerRadius = LCornerR;
    self.l7.layer.cornerRadius = LCornerR;
    
    self.submitBtn.layer.cornerRadius = LCornerR + 2;
    self.l1.layer.masksToBounds = YES;
    self.l2.layer.masksToBounds = YES;
    self.l3.layer.masksToBounds = YES;
    self.l4.layer.masksToBounds = YES;
    self.l5.layer.masksToBounds = YES;
    self.l6.layer.masksToBounds = YES;
    self.l7.layer.masksToBounds = YES;
    self.submitBtn.layer.masksToBounds = YES;
    
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
        self.carBrandTF.text = model.carBrand;
        self.licenseNumTF.text = model.licenseNum;
        [alertList dismiss];
        
    }];

    
    
}

- (IBAction)submitBtnClicked {
    
    
    
    if (self.carBrandTF.text == nil || self.carBrandTF.text.length == 0) {
        [LCCoolHUD showFailure:@"请填写车辆信息!" zoom:YES shadow:YES];
        return;
    }else if (self.carBrandTF.text == nil || self.carBrandTF.text.length == 0)
    {
        [LCCoolHUD showFailure:@"请填写车辆信息!" zoom:YES shadow:YES];
        return;
    }else if (self.timeTF.text == nil || self.timeTF.text.length == 0)
    {
        [LCCoolHUD showFailure:@"请填写预约时间!" zoom:YES shadow:YES];
        return;
    }else if (self.petrolStationTF.text == nil || self.petrolStationTF.text.length == 0)
    {
        [LCCoolHUD showFailure:@"请填写预约加油站!" zoom:YES shadow:YES];
        return;
    }else if (self.pretrolTypeTF.text == nil || self.pretrolTypeTF.text.length == 0)
    {
        [LCCoolHUD showFailure:@"请填写预约加油类型!" zoom:YES shadow:YES];
        return;
    }else if (self.petrolAmountTF.text == nil || self.petrolAmountTF.text.length == 0)
    {
        [LCCoolHUD showFailure:@"请填写预约加油量!" zoom:YES shadow:YES];
        return;
    }
    
    
    VIUserModel *user = [VIUserModel currentUser];
    VIAppointmentModel *appointment = [[VIAppointmentModel alloc] init];
    appointment.carOwnerName = self.userNameLabel.text;//user.nickName;
    appointment.carName = self.carBrandTF.text;
    appointment.ownerID = user.objectId;
    appointment.petrolType = self.pretrolTypeTF.text;
    appointment.petrolStation = self.petrolStationTF.text;
    appointment.petrolAmount = [NSString stringWithFormat:@"%@升",self.petrolAmountTF.text];
    appointment.time = self.timeTF.text;
    appointment.plateNum = self.licenseNumTF.text;

    
    [appointment saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        {
            if (succeeded)
            {
                NSLog(@"保存一条预约成功");
                [self.navigationController dismissViewControllerAnimated:YES completion:nil];
            }
        }
    }];
    
}

- (IBAction)petrolTypeBtnClicked
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
        self.pretrolTypeTF.text = self.petrolTypes[selectedIndexPath.row];
        [alertList dismiss];
        self.selectedIndexPath = nil;
        
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
