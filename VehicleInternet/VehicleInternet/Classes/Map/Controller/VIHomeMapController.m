//
//  VIHomeMapController.m
//  VehicleInternet
//
//  Created by joker on 16/3/13.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIHomeMapController.h"
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import <BaiduMapAPI_Base/BMKBaseComponent.h>
#import <BaiduMapAPI_Map/BMKPointAnnotation.h>
#import <BaiduMapAPI_Map/BMKPinAnnotationView.h>
#import <BaiduMapAPI_Search/BMKSearchBase.h>
#import <BaiduMapAPI_Base/BMKUserLocation.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Map/BMKAnnotation.h>

@interface VIHomeMapController ()

@property (nonatomic,strong) BMKMapView *mapView;



@end

@implementation VIHomeMapController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    [self setupMap];
    
    
    
    
    // Do any additional setup after loading the view.
}

#pragma mark - 初始化
/**
 * 初始化地图
 */
- (void)setupMap
{
    //初始化地图
    self.mapView = [[BMKMapView alloc] init];

    self.mapView.zoomEnabled = YES;//允许Zoom
    self.mapView.zoomLevel = 16;
    self.mapView.scrollEnabled = YES;//允许Scroll
    self.mapView.mapType = BMKMapTypeStandard;//地图类型为标准
    [self.view addSubview:self.mapView];

}




@end
