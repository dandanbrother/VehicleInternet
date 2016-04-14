//
//  VIScanResultController.m
//  VehicleInternet
//
//  Created by joker on 16/4/12.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIScanResultController.h"
#import "VIAppointmentModel.h"
#import "VIUserModel.h"

@interface VIScanResultController ()


@property (nonatomic,strong) VIAppointmentModel *appointment;
@property (nonatomic,copy) NSDictionary *dict;
@property (weak, nonatomic) IBOutlet UITextField *userNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *carBrandLabel;
@property (weak, nonatomic) IBOutlet UITextField *licenseNumLabel;
@property (weak, nonatomic) IBOutlet UITextField *timeLabel;
@property (weak, nonatomic) IBOutlet UITextField *petrolStationLabel;
@property (weak, nonatomic) IBOutlet UITextField *petrolTypeLabel;
@property (weak, nonatomic) IBOutlet UITextField *petrolAmountLabel;

@end

@implementation VIScanResultController

+ (instancetype)ewmResultWithAppointment:(NSDictionary *)dic
{
    VIScanResultController *scanResult = [[VIScanResultController alloc] init];
    if (scanResult) {
        scanResult.dict = dic;

    }
    return scanResult;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self fetchDataWithDict:self.dict];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)fetchDataWithDict:(NSDictionary *)dict
{
    
    
    NSString *objectId = dict[@"objectId"];
    NSString *ownerID = dict[@"ownerID"];
    AVQuery *query = [AVQuery queryWithClassName:@"_User"];
    [query whereKey:@"objectId" equalTo:ownerID];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        NSLog(@"%@",error);
        
        if (objects.count != 0)
        {
            VIUserModel *user = objects[0];
            self.userNameLabel.text = user.nickName;
            AVQuery *query = [AVQuery queryWithClassName:@"VIAppointmentModel"];
            [query whereKey:@"objectId" equalTo:objectId];
            [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
                if (objects.count != 0) {
                    VIAppointmentModel *appointment = objects[0];
                    
                    
                    self.carBrandLabel.text = appointment.carName;
                    self.licenseNumLabel.text = appointment.plateNum;
                    self.timeLabel.text = appointment.time;
                    self.petrolStationLabel.text = appointment.petrolStation;
                    self.petrolTypeLabel.text = appointment.petrolType;
                    self.petrolAmountLabel.text = appointment.petrolAmount;
                }
            }];
        }
    }];
}


@end
