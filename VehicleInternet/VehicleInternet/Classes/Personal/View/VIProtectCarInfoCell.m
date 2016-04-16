//
//  VIProtectCarInfoCell.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIProtectCarInfoCell.h"
#import "VICarInfoModel.h"

@interface VIProtectCarInfoCell ()
@property (weak, nonatomic) IBOutlet UILabel *isEngineGood;
@property (weak, nonatomic) IBOutlet UILabel *isTransmissionGood;
@property (weak, nonatomic) IBOutlet UILabel *isLightGood;
@property (weak, nonatomic) IBOutlet UILabel *carBrand;
@property (weak, nonatomic) IBOutlet UILabel *licenseNum;

@end

@implementation VIProtectCarInfoCell

- (void)setCarInfo:(VICarInfoModel *)carInfo {
    _carInfo = carInfo;
    
    self.isLightGood.text = [carInfo.isLightGood isEqualToString:@"1"]?@"车灯完好":@"车灯有损坏";
    self.isTransmissionGood.text = [carInfo.isTransmissionGood isEqualToString:@"1"]?@"变速器完好":@"变速器有损坏";
    self.isEngineGood.text = [carInfo.isEngineGood isEqualToString:@"1"]?@"发动机完好":@"发动机有损坏";
    self.carBrand.text = carInfo.carBrand;
    self.licenseNum.text = carInfo.licenseNum;

}

+ (instancetype)carInfoCellWithTableView:(UITableView *)tableView {
    static NSString *ID = @"protectCarInfo";
    VIProtectCarInfoCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[[NSBundle mainBundle] loadNibNamed:@"VIProtectCarInfoCell" owner:self options:nil] lastObject];
        cell.selectionStyle = UITableViewCellEditingStyleNone;
    }
    return cell;
}

- (IBAction)EwmBtnClicked:(id)sender {
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickToShowEwm:carInfo:)])
    {
        [self.delegate clickToShowEwm:(UIButton *)sender carInfo:_carInfo];
    }
}



@end
