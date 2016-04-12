//
//  VIModifyCarController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/6.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIModifyCarController.h"

@interface VIModifyCarController ()
@property (weak, nonatomic) IBOutlet UITextField *carBrand;
@property (weak, nonatomic) IBOutlet UITextField *licenseNum;
@property (weak, nonatomic) IBOutlet UITextField *mileage;
@property (weak, nonatomic) IBOutlet UITextField *petrol;



@end

@implementation VIModifyCarController

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


@end
