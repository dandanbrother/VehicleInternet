//
//  VIProtectCarInfoCell.h
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VICarInfoModel;

@protocol VIProtectCarInfoCellDelegate <NSObject>

@optional
- (void)clickToShowEwm:(UIButton *)btn carInfo:(VICarInfoModel*)carInfo;

@end

@interface VIProtectCarInfoCell : UITableViewCell

@property (nonatomic, strong) VICarInfoModel *carInfo;

@property (nonatomic,weak) id<VIProtectCarInfoCellDelegate> delegate;


+ (instancetype)carInfoCellWithTableView:(UITableView *)tableView;
@end
