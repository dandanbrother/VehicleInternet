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
#import "HomeNavBarCityItem.h"
#import "VIMapPoiSearch.h"
#import "VISearchSiteTextField.h"

@interface VIHomeMapController () <BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate>

@property (nonatomic,strong) BMKMapView *mapView;

@property (nonatomic,strong) BMKLocationService *locationService;

@property (nonatomic,strong) VIMapPoiSearch *poiSearch;

@property (nonatomic,strong) BMKGeoCodeSearch *geoCodeSearch;

@property (nonatomic,strong) BMKUserLocation *currentLocation;

@property (nonatomic,strong) BMKRouteSearch *routeSearch;

/** 搜索加油站的结果数组,存放BMKPoiInfo */
@property (nonatomic,strong) NSMutableArray *resultArray;
/** 起始地和目的地输入时的模糊匹配数组,存放BMKPoiInfo */
@property (nonatomic,strong) NSMutableArray *poiMatchArray;

@property (weak, nonatomic) IBOutlet VISearchSiteTextField *startTF;

@property (weak, nonatomic) IBOutlet VISearchSiteTextField *destinationTF;

@property (nonatomic,strong) LQXSwitch *switchControl;

@property (nonatomic,strong) HomeNavBarCityItem *cityItem;


@property (nonatomic,strong) UITableView *poiMatchTableView;



- (IBAction)queryPathBtnClicked:(id)sender;


@end

@implementation VIHomeMapController

#pragma mark - 懒加载
- (NSMutableArray *)resultArray
{
    if (_resultArray == nil) {
        _resultArray = [NSMutableArray array];
    }
    return _resultArray;
}
- (NSMutableArray *)poiMatchArray
{
    if (_poiMatchArray == nil) {
        _poiMatchArray = [NSMutableArray array];
    }
    return _poiMatchArray;
}

#pragma mark - Lifetime
- (void)viewDidAppear:(BOOL)animated
{
    self.mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locationService.delegate = self;
    self.geoCodeSearch.delegate = self;
    self.poiSearch.delegate = self;
    self.routeSearch.delegate = self;
    //开始定位
    [self startLocation];
    
    
}
- (void)viewDidDisappear:(BOOL)animated
{
    self.mapView.delegate = nil; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.locationService.delegate = nil;
    self.geoCodeSearch.delegate = nil;
    self.poiSearch.delegate = nil;
    self.routeSearch.delegate = nil;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.startTF addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    [self.destinationTF addTarget:self action:@selector(textFieldValueChanged:) forControlEvents:UIControlEventEditingChanged];
    
    /** 初始化自定义视图 */
    [self setupCustomView];
    
    /** 初始化地图 */
    [self setupMap];
    /** 初始化定位服务 */
    self.locationService = [[BMKLocationService alloc] init]
    ;
    // 设置距离过滤，表示每移动8更新一次位置
    self.locationService.distanceFilter = 40;
    self.locationService.desiredAccuracy = kCLLocationAccuracyBest;
    self.geoCodeSearch = [[BMKGeoCodeSearch alloc] init];
    self.poiSearch = [[VIMapPoiSearch alloc]init];
    self.currentLocation = [[BMKUserLocation alloc] init];
    self.routeSearch = [[BMKRouteSearch alloc] init];
    
    

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
/**
 * 初始化自定义视图
 */
- (void)setupCustomView
{
    //导航栏城市按钮
    self.cityItem = [HomeNavBarCityItem homeNavBarCityItem];
    self.cityItem.backgroundColor = [UIColor clearColor];//这是View的背景颜色
    [self.cityItem addTarget:self action:@selector(cityItemClick:)];
    UIBarButtonItem *cityItem = [[UIBarButtonItem alloc] initWithCustomView:self.cityItem];
    self.navigationItem.leftBarButtonItem = cityItem;
    
    //模糊搜索表单
    self.poiMatchTableView = [[UITableView alloc] init];
    self.poiMatchTableView.delegate = self;
    self.poiMatchTableView.dataSource = self;
    [self.view addSubview:self.poiMatchTableView];
    
    
}
#pragma mark - 代理方法

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{

    self.poiMatchTableView.hidden = NO;
    self.poiMatchTableView.frame = CGRectMake(textField.x, textField.bottom, textField.width, 100);
    [self.view bringSubviewToFront:self.poiMatchTableView];
    
    
}

#pragma mark - UITableViewDataSource
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.poiMatchArray.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"poiMatchCell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:identifier];
    }
    BMKPoiInfo *info = self.poiMatchArray[indexPath.row];
    NSString *addStr = [NSString stringWithFormat:@"%@",info.name];
    cell.detailTextLabel.text = info.address;
    cell.textLabel.text = addStr;
    cell.textLabel.font = [UIFont systemFontOfSize:11];
    
    return cell;
}

#pragma mark - UITableViewDelegate
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    BMKPoiInfo *info = self.poiMatchArray[indexPath.row];
    if ([self.startTF isFirstResponder])
    {
        self.startTF.siteInfo = info;
        self.startTF.text = info.name;
    }else if ([self.destinationTF isFirstResponder])
    {
        self.destinationTF.siteInfo = info;
        self.destinationTF.text = info.name;
    }else
    {
        
    }
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

#pragma mark - BMKPoiSearchDelegate

- (void)onGetPoiResult:(BMKPoiSearch *)searcher result:(BMKPoiResult*)result errorCode:(BMKSearchErrorCode)error
{
    
    if ([searcher isKindOfClass:[VIMapPoiSearch class]])
    {

        VIMapPoiSearch *mySearcher = (VIMapPoiSearch *)searcher;
        
        if (mySearcher.searchType == VIMapPoiSearchTypeCity)//城市内搜索(起始地,目的地)
        {
//            NSLog(@"VIMapPoiSearchTypeCity");
            if (error == BMK_SEARCH_NO_ERROR) {
                
                [self.poiMatchArray removeAllObjects];
                NSArray *tempArray = result.poiInfoList;
                NSLog(@"地点模糊匹配数量---%d",tempArray.count);
                
                for (int i =0; i < tempArray.count; i ++)
                {
                    BMKPoiInfo *info = tempArray[i];
                    [self.poiMatchArray addObject:info];
                    if (i == 0) {
                        if ([self.startTF  isFirstResponder]) {
                            self.startTF.siteInfo = info;
                        }else
                        {
                            self.destinationTF.siteInfo = info;
                        }
                    }
                }
                
            } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
                NSLog(@"地点模糊匹配起始点有歧义");
            } else {
                NSLog(@"地点模糊匹配搜索失败");
            }
           
            [self.poiMatchTableView reloadData];

            
        }else //周围搜索(加油站)
        {
            if (error == BMK_SEARCH_NO_ERROR) {
                
                [self.resultArray removeAllObjects];
                NSArray *tempArray = result.poiInfoList;
                NSLog(@"加油站数量---%d",tempArray.count);
                
                for (int i =0; i < tempArray.count; i ++)
                {
                    BMKPoiInfo *info = tempArray[i];
                    [self.resultArray addObject:info];
                }
            } else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
                NSLog(@"周围加油站起始点有歧义");
            } else {
                NSLog(@"周围加油站搜索失败");
            }
            //显示搜索到的加油站
            [self loadPoiSites];
        }
        
    }
    
   
}


#pragma BMKRouteSearchDelegate
/**
 *返回驾乘搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKDrivingRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetDrivingRouteResult:(BMKRouteSearch*)searcher result:(BMKDrivingRouteResult*)result errorCode:(BMKSearchErrorCode)error
{
    if (error == BMK_SEARCH_NO_ERROR) {
        NSLog(@"返回驾车路径成功---%d",result.routes.count);
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"返回驾车路径失败有歧义---%d",result.routes.count);
    }
    else {
        NSLog(@"抱歉，未找到结果");
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
        self.poiSearch.searchType = VIMapPoiSearchTypeNearby;
        BOOL flag = [self.poiSearch poiSearchNearBy:option];
        if(flag)
        {
            NSLog(@"周围加油站检索发送成功");
        }
        else
        {  
            NSLog(@"周围加油站检索发送失败");
        }
        
        
    }else  //不显示
    {
        NSArray *arr = [NSArray arrayWithArray:self.mapView.annotations];
        [self.mapView removeAnnotations:arr];
    }
}
/**
 * 查询路线
 */
- (IBAction)queryPathBtnClicked:(id)sender
{
    [self.startTF resignFirstResponder];
    [self.destinationTF resignFirstResponder];
    
    BMKPlanNode *startNode = [[BMKPlanNode alloc] init];
    startNode.cityName = @"南京市";
    startNode.name = self.startTF.text;
    BMKPlanNode *endNode = [[BMKPlanNode alloc] init];
    endNode.cityName = @"南京市";
    endNode.name = self.destinationTF.text;
    BMKDrivingRoutePlanOption *transitRouteSearchOption =         [[BMKDrivingRoutePlanOption alloc]init];
//    transitRouteSearchOption.drivingPolicy = BMK_DRIVING_DIS_FIRST;
    transitRouteSearchOption.from = startNode;
    transitRouteSearchOption.to = endNode;
    BOOL flag = [self.routeSearch drivingSearch:transitRouteSearchOption];
    if(flag)
    {
        NSLog(@"驾车路径规划检索发送成功:起始点---%@---目的地---%@",startNode.name,endNode.name);
    }
    else
    {
        NSLog(@"驾车路径规划检索发送失败");
    }

}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.startTF resignFirstResponder];
    [self.destinationTF resignFirstResponder];
    self.poiMatchTableView.hidden = YES;
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

/**
 * 城市按钮点击
 */
- (void)cityItemClick:(HomeNavBarCityItem *)cityItem
{
    NSLog(@"cityItemClick");
}
/**
 * 起始地,目的地-输入监听
 */
- (void)textFieldValueChanged:(UITextField *)textField
{

    UITextRange *selectedRange = [textField markedTextRange];
    NSString * newText = [textField textInRange:selectedRange];
    if(newText.length>0)
        return;
    NSLog(@"%@",textField.text);
    
    BMKCitySearchOption *citySearchOption = [[BMKCitySearchOption alloc]init];
    citySearchOption.pageCapacity = 10;
    citySearchOption.city = @"南京";
    citySearchOption.keyword = textField.text;
    self.poiSearch.searchType = VIMapPoiSearchTypeCity;
    BOOL flag = [self.poiSearch poiSearchInCity:citySearchOption];
    if(flag)
    {
        NSLog(@"城市内检索发送成功");
    }
    else
    {
        NSLog(@"城市内检索发送失败");
    }

    
}
@end
