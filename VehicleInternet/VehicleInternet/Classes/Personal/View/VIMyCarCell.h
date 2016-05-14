//
//  VIMyCarCell.h
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/7.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>

@class VICarInfoModel;

@protocol VIMyCarCellDelegate <NSObject>

@optional
- (void)clickToShowEwm:(UIButton *)btn carInfo:(VICarInfoModel*)carInfo;
- (void)clickToShowIllegalInfo:(UIButton *)btn carInfo:(VICarInfoModel*)carInfo;
@end

@interface VIMyCarCell : UITableViewCell

@property (nonatomic, strong) VICarInfoModel *carInfo;

@property (nonatomic,weak) id<VIMyCarCellDelegate> delegate;
- (void)setCarInfo:(VICarInfoModel *)carInfo;
+ (instancetype)carInfoCellWithTableView:(UITableView *)tableView;
@end
