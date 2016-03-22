//
//  VISearchSiteTextField.h
//  VehicleInternet
//
//  Created by joker on 16/3/18.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Search/BMKPoiSearchType.h>

@interface VISearchSiteTextField : UITextField



/** textField 包含的地点信息 */
@property (nonatomic,strong) BMKPoiInfo *siteInfo;


@end
