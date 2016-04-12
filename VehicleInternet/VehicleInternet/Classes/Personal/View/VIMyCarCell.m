//
//  VIMyCarCell.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/7.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIMyCarCell.h"

@interface VIMyCarCell ()
@property (weak, nonatomic) IBOutlet UILabel *carBrand;
@property (weak, nonatomic) IBOutlet UILabel *licenseNum;
@property (weak, nonatomic) IBOutlet UILabel *mileage;
@property (weak, nonatomic) IBOutlet UILabel *petrol;

@end

@implementation VIMyCarCell

- (void)setCarInfo:(VICarInfoModel *)carInfo {
    _carInfo = carInfo;
    self.carBrand.text = carInfo.carBrand;
    self.licenseNum.text = carInfo.licenseNum;
    self.mileage.text = carInfo.mileage;
    self.petrol.text = carInfo.petrol;
    
}

+ (instancetype)carInfoCellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"carinfo";
    VIMyCarCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VIMyCarCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }
    return cell;
}


@end
