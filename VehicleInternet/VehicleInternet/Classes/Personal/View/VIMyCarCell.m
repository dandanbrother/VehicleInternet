//
//  VIMyCarCell.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/7.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIMyCarCell.h"
#import "VICarInfoModel.h"

@interface VIMyCarCell ()
@property (weak, nonatomic) IBOutlet UILabel *carBrand;
@property (weak, nonatomic) IBOutlet UILabel *licenseNum;
@property (weak, nonatomic) IBOutlet UILabel *mileage;
@property (weak, nonatomic) IBOutlet UILabel *petrol;
- (IBAction)ewmBtnClicked:(id)sender;


@end

@implementation VIMyCarCell

- (void)setCarInfo:(VICarInfoModel *)carInfo {
    _carInfo = carInfo;
    self.carBrand.text = carInfo.carBrand;
    self.licenseNum.text = carInfo.licenseNum;
    self.mileage.text = [carInfo.mileage stringByAppendingString:@" 公里"];
    self.petrol.text = [carInfo.petrol stringByAppendingString:@" 升"];
    
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



- (IBAction)ewmBtnClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickToShowEwm:carInfo:)])
    {
        [self.delegate clickToShowEwm:(UIButton *)sender carInfo:_carInfo];
    }
}
@end
