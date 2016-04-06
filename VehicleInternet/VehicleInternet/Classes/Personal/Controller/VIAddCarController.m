//
//  VIAddCarController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/5.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIAddCarController.h"
#import "VICarInfoModel.h"

@interface VIAddCarController ()
@property (weak, nonatomic) IBOutlet UITextField *carBrand;
@property (weak, nonatomic) IBOutlet UITextField *symbol;
@property (weak, nonatomic) IBOutlet UITextField *model;
@property (weak, nonatomic) IBOutlet UITextField *licenseNum;
@property (weak, nonatomic) IBOutlet UITextField *mileage;
@property (weak, nonatomic) IBOutlet UITextField *petrol;

@end

@implementation VIAddCarController

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (IBAction)save:(id)sender {
    if ((self.carBrand.text.length != 0 ) && (self.symbol.text.length != 0 ) && (self.model.text.length != 0 ) && (self.licenseNum.text.length != 0 ) && (self.mileage.text.length != 0 ) && (self.petrol.text.length != 0 )) {
        NSLog(@"1");
        VICarInfoModel *model = [VICarInfoModel object];
        model.carBrand = self.carBrand.text;
        model.symbol = self.symbol.text;
        model.model = self.model.text;
        model.licenseNum = self.licenseNum.text;
        model.mileage = self.mileage.text;
        model.petrol = self.petrol.text;
        [model saveInBackground];
        
        [self.navigationController popToRootViewControllerAnimated:YES];

    } else {
        NSLog(@"信息不全");
        
    }
}
@end
