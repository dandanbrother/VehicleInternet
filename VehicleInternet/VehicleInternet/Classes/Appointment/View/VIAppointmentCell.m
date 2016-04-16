//
//  VIAppointmentCell.m
//  VehicleInternet
//
//  Created by joker on 16/4/3.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIAppointmentCell.h"
#import "VIAppointmentModel.h"

@interface VIAppointmentCell ()
@property (weak, nonatomic) IBOutlet UILabel *carInfoLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *petrolStationLabel;
@property (weak, nonatomic) IBOutlet UILabel *petrolTypeLabel;
@property (weak, nonatomic) IBOutlet UILabel *petrolAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *licenseNumLabel;
@property (weak, nonatomic) IBOutlet UILabel *isPayed;

- (IBAction)showEwmBtnClicked:(id)sender;

@end

@implementation VIAppointmentCell


- (void)setAppointmentInfo:(VIAppointmentModel *)appointmentInfo
{
    _appointmentInfo = appointmentInfo;
    self.carInfoLabel.text = appointmentInfo.carName;
    self.licenseNumLabel.text = appointmentInfo.plateNum;
    self.timeLabel.text = appointmentInfo.time;
    self.petrolStationLabel.text = appointmentInfo.petrolStation;
    self.petrolTypeLabel.text = appointmentInfo.petrolType;
    self.petrolAmountLabel.text = [NSString stringWithFormat:@"%@",appointmentInfo.petrolAmount];
    self.isPayed.text = appointmentInfo.isPayed;
    NSLog(@"self.isPayed.text %@",self.isPayed.text);
}


#pragma mark - 初始化操作
+ (instancetype)appointmentCellWithTableView:(UITableView *)tableView
{
    static NSString *identifier = @"appointmentCell";
    VIAppointmentCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell)
    {
        cell= [[[NSBundle mainBundle] loadNibNamed:@"VIAppointmentCell" owner:nil options:nil] lastObject];
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
    }
    return cell;
}

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

- (IBAction)showEwmBtnClicked:(id)sender
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(clickToShowEwm:appointment:)])
    {
        [self.delegate clickToShowEwm:(UIButton *)sender appointment:_appointmentInfo];
    }
}
@end
