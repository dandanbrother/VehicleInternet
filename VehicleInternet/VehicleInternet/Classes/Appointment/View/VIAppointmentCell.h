//
//  VIAppointmentCell.h
//  VehicleInternet
//
//  Created by joker on 16/4/3.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VIAppointmentModel;


@protocol AppointmentCellDelegate <NSObject>

@optional
- (void)clickToShowEwm:(UIButton *)btn appointment:(VIAppointmentModel*)appointment;

@end

@interface VIAppointmentCell : UITableViewCell

@property (nonatomic,strong) VIAppointmentModel *appointmentInfo;


@property (nonatomic,weak) id<AppointmentCellDelegate> delegate;


+ (instancetype)appointmentCellWithTableView:(UITableView *)tableView;
@end
