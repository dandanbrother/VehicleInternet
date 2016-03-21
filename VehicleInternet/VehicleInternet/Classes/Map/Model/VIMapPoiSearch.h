//
//  VIMapPoiSearch.h
//  VehicleInternet
//
//  Created by joker on 16/3/18.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import <BaiduMapAPI_Search/BMKPoiSearch.h>


typedef NS_ENUM(NSUInteger, VIMapPoiSearchType) {
    VIMapPoiSearchTypeCity,
    VIMapPoiSearchTypeNearby
};

@interface VIMapPoiSearch : BMKPoiSearch


@property (nonatomic,assign) VIMapPoiSearchType searchType;


@end
