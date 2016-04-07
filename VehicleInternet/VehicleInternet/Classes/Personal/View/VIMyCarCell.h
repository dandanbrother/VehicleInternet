//
//  VIMyCarCell.h
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/7.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "VICarInfoModel.h"

@interface VIMyCarCell : UITableViewCell

@property (nonatomic, strong) VICarInfoModel *carInfo;

+ (instancetype)carInfoCellWithTableView:(UITableView *)tableView;
@end
