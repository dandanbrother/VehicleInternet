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
#import "LQXSwitch.h"

@interface VIHomeMapController () <BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate>

@property (nonatomic,strong) BMKMapView *mapView;

@property (nonatomic,strong) BMKLocationService *locationService;

@property (nonatomic,strong) BMKPoiSearch *poiSearch;

@property (nonatomic,strong) BMKGeoCodeSearch *geoCodeSearch;


@property (weak, nonatomic) IBOutlet UITextField *startTF;

@property (weak, nonatomic) IBOutlet UITextField *destinationTF;

@property (nonatomic,strong) LQXSwitch *switchControl;


- (IBAction)queryPathBtnClicked:(id)sender;


@end

@implementation VIHomeMapController

#pragma mark - lifetime
- (void)viewDidAppear:(BOOL)animated
{
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locationService.delegate = self;
    self.geoCodeSearch.delegate = self;
    self.poiSearch.delegate = self;
    //开始定位
    [self startLocation];
    
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    self.mapView.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locationService.delegate = nil;
    self.geoCodeSearch.delegate = nil;
    self.poiSearch.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    
    
    
    /** 初始化地图 */
    [self setupMap];
    /** 初始化定位服务 */
    self.locationService = [[BMKLocationService alloc] init]
    ;
    self.geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    self.poiSearch = [[BMKPoiSearch alloc]init];
    
    
    

}

#pragma mark - 初始化
/**
 * 初始化地图
 */
- (void)setupMap
{
    //初始化地图
    self.mapView = [[BMKMapView alloc] init];
    self.mapView.frame = CGRectMake(0, self.destinationTF.bottom + 5, KDeviceWidth, 200);

    self.mapView.zoomEnabled = YES;//允许Zoom
    self.mapView.zoomLevel = 16;
    self.mapView.scrollEnabled = YES;//允许Scroll
    self.mapView.mapType = BMKMapTypeStandard;//地图类型为标准
    [self.view addSubview:self.mapView];
    //定位图层自定义样式参数
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isRotateAngleValid = NO;//跟随态旋转角度是否生效
    displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
    displayParam.locationViewOffsetY = 0;//定位偏移量（纬度）
    [self.mapView updateLocationViewWithParam:displayParam];
    
    //地图中心小图标
    UIImageView *imageView = [[UIImageView alloc] init];
    imageView.image = [UIImage imageNamed:@"iconfont-yuandianbiaozhu"];
    imageView.width = 10;
    imageView.height = 10;
    imageView.centerX = self.mapView.centerX;
    imageView.centerY = self.mapView.height * 0.5;
    [self.mapView addSubview:imageView];
    
    
    //显示加油站开关
    self.switchControl = [[LQXSwitch alloc] initWithFrame:CGRectMake(self.mapView.width - 45, self.mapView.height - 25, 30, 15) onColor:[UIColor colorWithRed:11 / 255.0 green:179 / 255.0 blue:11 / 255.0 alpha:1.0] offColor:[UIColor lightGrayColor] font:[UIFont systemFontOfSize:10] ballSize:12];
    [self.mapView addSubview:self.switchControl];
    UILabel *switchLabel = [[UILabel alloc] init];
    switchLabel.width = 60;
    switchLabel.height = 20;
    switchLabel.centerY = self.switchControl.centerY;
    switchLabel.x = self.switchControl.x - switchLabel.width - 2;
    [self.mapView addSubview:switchLabel];
    //    switchLabel.backgroundColor = [UIColor redColor];
    switchLabel.font = [UIFont systemFontOfSize:12];
    switchLabel.text = @"显示加油站";
    switchLabel.textColor = [UIColor redColor];
  
    
}

#pragma mark - BMKMapViewDelegate

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    NSLog(@"regionWillChangeAnimated---%f---%f",mapView.centerCoordinate.latitude,mapView.centerCoordinate.longitude);
    
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{

    if (userLocation == nil || userLocation == NULL) {
        return;
    }
    NSLog(@"didUpdateBMKUserLocation---%@",userLocation);
    [self.locationService stopUserLocationService];
    [self.mapView updateLocationData:userLocation];
    _mapView.centerCoordinate = userLocation.location.coordinate;
    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){self.mapView.centerCoordinate.latitude, self.mapView.centerCoordinate.longitude};
    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
    reverseGeocodeSearchOption.reverseGeoPoint = pt;
    BOOL flag = [self.geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
    if(flag)
    {
        NSLog(@"反geo检索发送成功");
    }
    else
    {
        NSLog(@"反geo检索发送失败");
    }
    
}

#pragma mark - 其他方法
/**
 * 开始定位
 */
- (void)startLocation
{
    [self.locationService startUserLocationService];
    _mapView.showsUserLocation = NO;//先关闭显示的定位图层
    _mapView.userTrackingMode = BMKUserTrackingModeNone;//设置定位的状态
    _mapView.showsUserLocation = YES;//显示定位图层
}


- (IBAction)queryPathBtnClicked:(id)sender
{
    [self.startTF resignFirstResponder];
    [self.destinationTF resignFirstResponder];
    
    
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.startTF resignFirstResponder];
    [self.destinationTF resignFirstResponder];
}


@end
