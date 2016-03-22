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
#import "VIMusicPlayerController.h"
#import "VIMusicModel.h"


@interface VIHomeMapController () <BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate,AVAudioPlayerDelegate>

@property (nonatomic,strong) BMKMapView *mapView;

@property (nonatomic,strong) BMKLocationService *locationService;

@property (nonatomic,strong) BMKPoiSearch *poiSearch;

@property (nonatomic,strong) BMKGeoCodeSearch *geoCodeSearch;

@property (nonatomic,strong) BMKUserLocation *currentLocation;

/** 存放 BMKPoiInfo */
@property (nonatomic,strong) NSMutableArray *resultArray;

@property (weak, nonatomic) IBOutlet UITextField *startTF;

@property (weak, nonatomic) IBOutlet UITextField *destinationTF;

@property (nonatomic,strong) LQXSwitch *switchControl;

@property (nonatomic, strong) NSArray *musicArr;



- (IBAction)queryPathBtnClicked:(id)sender;


@end

@implementation VIHomeMapController

- (NSArray *)musicArr{
    if (!_musicArr) {
        NSArray *arr = [NSArray arrayWithContentsOfFile:[[NSBundle mainBundle]pathForResource:@"music" ofType:@"plist"]];
        
        NSMutableArray *muteArr = [NSMutableArray array];
        for (NSDictionary *dict in arr) {
            [muteArr addObject:[VIMusicModel musicWithDict:dict]];
        }
        _musicArr = muteArr;
    }
    return _musicArr;
}

#pragma mark - 懒加载
- (NSMutableArray *)resultArray
{
    if (_resultArray == nil) {
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}

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
    // 设置距离过滤，表示每移动8更新一次位置
    self.locationService.distanceFilter = 40;
    self.locationService.desiredAccuracy = kCLLocationAccuracyBest;
    self.geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    self.poiSearch = [[BMKPoiSearch alloc]init];
    self.currentLocation = [[BMKUserLocation alloc] init];
    
    

    //创建播放器
    NSString *path = [NSString stringWithFormat:@"%@/安静.mp3", [[NSBundle mainBundle] resourcePath]];
    NSURL *soundUrl = [NSURL fileURLWithPath:path];
    //初始化AVAudioPlayer实例对象
   AVAudioPlayer *player = [[AVAudioPlayer alloc] initWithContentsOfURL:soundUrl error:nil];
    
    //设置开始的音量
    player.volume = .5;
    
    //设置当前的时间
    player.currentTime = 0;
    
    //设置代理
    player.delegate = self;
    
    //
    BOOL isPlay = [player prepareToPlay];
    
    if (isPlay) {
        
        [player play];
        
    }else{
        
        NSLog(@"播放失败");
    }

}

#pragma mark - 初始化
/**
 * 初始化地图
 */
- (void)setupMap
{
    //初始化地图
    self.mapView = [[BMKMapView alloc] init];
    self.mapView.frame = CGRectMake(0, self.destinationTF.bottom + 5, KDeviceWidth, KDeviceHeight - 49 - 5 - self.destinationTF.bottom);

    self.mapView.zoomEnabled = YES;//允许Zoom
    self.mapView.zoomLevel = 14;
    self.mapView.scrollEnabled = YES;//允许Scroll
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;
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
    [self.switchControl addTarget:self action:@selector(switchControlClicked:) forControlEvents:UIControlEventValueChanged];
    self.switchControl.on = NO;
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

//- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
//{
//    NSLog(@"regionWillChangeAnimated---%f---%f",mapView.centerCoordinate.latitude,mapView.centerCoordinate.longitude);
//    
//    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){mapView.centerCoordinate.latitude, mapView.centerCoordinate.longitude};
//    BMKReverseGeoCodeOption *reverseGeocodeSearchOption = [[BMKReverseGeoCodeOption alloc]init];
//    reverseGeocodeSearchOption.reverseGeoPoint = pt;
//    BOOL flag = [self.geoCodeSearch reverseGeoCode:reverseGeocodeSearchOption];
//    if(flag)
//    {
//        NSLog(@"反geo检索发送成功");
//    }
//    else
//    {
//        NSLog(@"反geo检索发送失败");
//    }
//}

#pragma mark - BMKLocationServiceDelegate
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation
{

    if (userLocation == nil || userLocation == NULL) {
        return;
    }
    self.currentLocation = userLocation;
    NSLog(@"didUpdateBMKUserLocation---%f----%f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [self.mapView updateLocationData:userLocation];
    _mapView.centerCoordinate = userLocation.location.coordinate;
    
}

#pragma mark - BMKSearchDelegate

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    
    if (error == BMK_SEARCH_NO_ERROR) {

        [self.resultArray removeAllObjects];
        NSArray *tempArray = result.poiInfoList;
        NSLog(@"加油站数量---%lu",(unsigned long)tempArray.count);
        
        for (int i =0; i < tempArray.count; i ++)
        {
            BMKPoiInfo *info = tempArray[i];
            [self.resultArray addObject:info];
        }
    } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"起始点有歧义");
    } else {
        NSLog(@"搜索失败");
    }
    [self loadPoiSites];

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
/**
 * 显示加油站
 */
- (void)switchControlClicked:(LQXSwitch *)switchControl
{

    if (switchControl.isOn) //显示
    {
        //发起检索
        BMKNearbySearchOption *option = [[BMKNearbySearchOption alloc]init];
        option.location = CLLocationCoordinate2DMake(self.currentLocation.location.coordinate.latitude, self.currentLocation.location.coordinate.longitude);
        option.keyword = @"加油站";
        //搜索半径(m)
        option.radius = 300000;
        BOOL flag = [self.poiSearch poiSearchNearBy:option];
        if(flag)
        {
            NSLog(@"周边检索发送成功");
        }
        else
        {  
            NSLog(@"周边检索发送失败");  
        }
        
        
    }else  //不显示
    {
        
    }
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

/**
 * 加载标注点(加油站)
 */
- (void)loadPoiSites
{
    if (self.resultArray.count == 0) {
        return;
    }
    
    
    for (BMKPoiInfo *info in self.resultArray)
    {
        //添加标注点
        BMKPointAnnotation *annotation = [[BMKPointAnnotation alloc] init];


        annotation.coordinate = info.pt;
        annotation.title = info.name;
        [self.mapView addAnnotation:annotation];
    }
    

    
}

@end
