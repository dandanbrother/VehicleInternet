//
//  VIModifyCarController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/6.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIModifyCarController.h"
#import "ZJAlertListView.h"

@interface VIModifyCarController () <UITextFieldDelegate,ZJAlertListViewDelegate,ZJAlertListViewDatasource>
@property (weak, nonatomic) IBOutlet UITextField *carBrand;
@property (weak, nonatomic) IBOutlet UITextField *licenseNum;
@property (weak, nonatomic) IBOutlet UITextField *mileage;
@property (weak, nonatomic) IBOutlet UITextField *petrol;

@property (nonatomic, strong) NSIndexPath *selectedIndexPath;

@property (nonatomic, strong) NSArray *carBrandTypes;

@end

@implementation VIModifyCarController

- (NSArray *)carBrandTypes{
    if (!_carBrandTypes) {
        self.carBrandTypes = [NSArray arrayWithObjects:@"奔驰",@"宝马",@"大众",@"丰田",nil];
    }
    return _carBrandTypes;
}

- (void)initData {
    self.carBrand.text = _car.carBrand;
    self.licenseNum.text = _car.licenseNum;
    self.mileage.text = _car.mileage;
    self.petrol.text = _car.petrol;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initData];
    
}

- (IBAction)save:(id)sender {
    [_car saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [_car setObject:self.carBrand.text forKey:@"carBrand"];
        [_car setObject:self.licenseNum.text forKey:@"licenseNum"];
        [_car setObject:self.mileage.text forKey:@"mileage"];
        [_car setObject:self.petrol.text forKey:@"petrol"];
        
        [_car saveInBackground];
        [self.navigationController popViewControllerAnimated:YES];
    }];
}
- (IBAction)revoke:(id)sender {
    [self initData];
}


#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField {
    NSLog(@"1");
    ZJAlertListView *alertList = [[ZJAlertListView alloc] initWithFrame:CGRectMake(0, 0, 250, 300)];
    alertList.titleLabel.text = @"弹框";
    alertList.datasource = self;
    alertList.delegate = self;
    [alertList show];
    //点击确定的时候，调用它去做点事情
    [alertList setDoneButtonWithBlock:^{
        
        NSIndexPath *selectedIndexPath = self.selectedIndexPath;
        textField.text = self.carBrandTypes[selectedIndexPath.row];
        [alertList dismiss];
        
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



@end
