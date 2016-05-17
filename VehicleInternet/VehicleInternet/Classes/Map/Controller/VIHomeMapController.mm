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
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "LQXSwitch.h"
#import "HomeNavBarCityItem.h"
#import "VIMapPoiSearch.h"
#import "VISearchSiteTextField.h"
#import "VIMusicPlayerController.h"
#import "MBProgressHUD.h"
#import "LCCoolHUD.h"
#import "BNCoreServices.h"
#import "AFNetworking.h"
#import "NSString+extension.h"



@interface VIHomeMapController () <BMKMapViewDelegate,BMKLocationServiceDelegate,BMKPoiSearchDelegate,BMKGeoCodeSearchDelegate,BMKRouteSearchDelegate,UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,BNNaviUIManagerDelegate,BNNaviRoutePlanDelegate,UIAlertViewDelegate>

@property (nonatomic,strong) BMKMapView *mapView;

@property (nonatomic,strong) BMKLocationService *locationService;
- (IBAction)switchAddressBtnClicked;

@property (nonatomic,strong) VIMapPoiSearch *poiSearch;

@property (nonatomic,strong) BMKGeoCodeSearch *geoCodeSearch;
/** 当前位置 */
@property (nonatomic,strong) BMKUserLocation *currentLocation;

@property (nonatomic,strong) BMKRouteSearch *routeSearch;

/** 搜索加油站的结果数组,存放BMKPoiInfo */
@property (nonatomic,strong) NSMutableArray *resultArray;
/** 起始地和目的地输入时的模糊匹配数组,存放BMKPoiInfo */
@property (nonatomic,strong) NSMutableArray *poiMatchArray;

@property (weak, nonatomic) IBOutlet VISearchSiteTextField *startTF;

@property (weak, nonatomic) IBOutlet VISearchSiteTextField *destinationTF;

@property (nonatomic,strong) BMKPoiInfo *currentSiteInfo;

@property (nonatomic,strong) LQXSwitch *switchControl;

@property (nonatomic,strong) HomeNavBarCityItem *cityItem;


@property (nonatomic,strong) UITableView *poiMatchTableView;


@property (weak, nonatomic) IBOutlet UIButton *queryPathBtn;

- (IBAction)queryPathBtnClicked:(id)sender;

- (IBAction)getPetrolPriceClicked:(id)sender;

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
    
//    CLLocationCoordinate2D pt = (CLLocationCoordinate2D){32.1215900000,118.9374060000};
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

}

#pragma mark - 初始化
/**
 * 初始化地图
 */
- (void)setupMap
{
    //初始化地图
    self.mapView = [[BMKMapView alloc] init];
    self.mapView.frame = CGRectMake(0, 64, KDeviceWidth, KDeviceHeight - 64 - 50);

    self.mapView.zoomEnabled = YES;//允许Zoom
    self.mapView.zoomLevel = 14;
    self.mapView.scrollEnabled = YES;//允许Scroll
    self.mapView.userTrackingMode = BMKUserTrackingModeFollow;
    self.mapView.showsUserLocation = YES;
    self.mapView.mapType = BMKMapTypeStandard;//地图类型为标准
    [self.view insertSubview:self.mapView belowSubview:self.destinationTF];
    //定位图层自定义样式参数
    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isRotateAngleValid = NO;//跟随态旋转角度是否生效
    displayParam.isAccuracyCircleShow = NO;//精度圈是否显示
    displayParam.locationViewOffsetX = 0;//定位偏移量(经度)
    displayParam.locationViewOffsetY = 0;//定位偏移量（纬度）
    [self.mapView updateLocationViewWithParam:displayParam];
    
//    //地图中心小图标
//    UIImageView *imageView = [[UIImageView alloc] init];
//    imageView.image = [UIImage imageNamed:@"iconfont-yuandianbiaozhu"];
//    imageView.width = 10;
//    imageView.height = 10;
//    imageView.centerX = self.mapView.centerX;
//    imageView.centerY = self.mapView.height * 0.5;
//    [self.mapView addSubview:imageView];
    
    
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
    
    //设置查询按钮
    self.queryPathBtn.layer.cornerRadius = 8;
    self.queryPathBtn.alpha = 0.7;

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
    self.poiMatchTableView.hidden = YES;
    [self.view addSubview:self.poiMatchTableView];
    
    
}
#pragma mark - 代理方法

#pragma mark - UITextFieldDelegate
- (void)textFieldDidBeginEditing:(UITextField *)textField;
{

//    self.poiMatchTableView.hidden = NO;
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
    self.poiMatchTableView.hidden = YES;
}

#pragma mark - BMKMapViewDelegate

- (void)mapView:(BMKMapView *)mapView regionDidChangeAnimated:(BOOL)animated
{
    
    
    [self.startTF resignFirstResponder];
    [self.destinationTF resignFirstResponder];
    self.poiMatchTableView.hidden = YES;
}

/**
 *  根据overlay生成对应的View
 *  @param mapView 地图View
 *  @param overlay 指定的overlay
 *  @return 生成的覆盖物View
 */
- (BMKOverlayView *)mapView:(BMKMapView *)mapView viewForOverlay:(id<BMKOverlay>)overlay
{
    //画折线
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor = [[UIColor yellowColor] colorWithAlphaComponent:0.7];
        polylineView.strokeColor = [[UIColor greenColor] colorWithAlphaComponent:0.7];
        polylineView.lineWidth = 5.0;
        return polylineView;
    }
    return nil;
}
/**
 *当选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view
{

    NSLog(@"didSelectAnnotationView");
    
}

/**
 *当取消选中一个annotation views时，调用此接口
 *@param mapView 地图View
 *@param views 取消选中的annotation views
 */
- (void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view
{
    NSLog(@"didDeselectAnnotationView");
}
/**
 *当点击annotation view弹出的泡泡时，调用此接口
 *@param mapView 地图View
 *@param view 泡泡所属的annotation view
 */
- (void)mapView:(BMKMapView *)mapView annotationViewForBubble:(BMKAnnotationView *)view
{
    //当前位置
    BMKUserLocation *current = self.currentLocation;
    CLLocationCoordinate2D startL = current.location.coordinate;
    //目的地
    BMKPointAnnotation *annotation = (BMKPointAnnotation *)view.annotation;
    CLLocationCoordinate2D destinationL = annotation.coordinate;
    //路径点数组
    NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
    BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
    startNode.pos = [[BNPosition alloc] init];
    startNode.pos.x = startL.longitude;
    startNode.pos.y = startL.latitude;
    startNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:startNode];
    //终点
    BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
    endNode.pos = [[BNPosition alloc] init];
    endNode.pos.x = destinationL.longitude;
    endNode.pos.y = destinationL.latitude;
    endNode.pos.eType = BNCoordinate_BaiduMapSDK;
    [nodesArray addObject:endNode];
    
    [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Highway naviNodes:nodesArray time:nil delegete:self userInfo:nil];

    
}

#pragma mark - BNNaviRoutePlanDelegate
//算路成功回调
-(void)routePlanDidFinished:(NSDictionary *)userInfo
{
    NSLog(@"算路成功");
    //路径规划成功，开始导航
    [BNCoreServices_UI showNaviUI:BN_NaviTypeReal delegete:self isNeedLandscape:YES];
    
}

//算路失败回调
- (void)routePlanDidFailedWithError:(NSError *)error andUserInfo:(NSDictionary *)userInfo
{
    NSLog(@"算路失败");
    if ([error code] == BNRoutePlanError_LocationFailed) {
        NSLog(@"获取地理位置失败");
    }
    else if ([error code] == BNRoutePlanError_LocationServiceClosed)
    {
        NSLog(@"定位服务未开启");
    }
}

//算路取消回调
-(void)routePlanDidUserCanceled:(NSDictionary*)userInfo {
    NSLog(@"算路取消");
}

#pragma mark - BNNaviUIManagerDelegate

//退出导航回调
-(void)onExitNaviUI:(NSDictionary*)extraInfo
{
    NSLog(@"退出导航");
}

//退出导航声明页面回调
- (void)onExitDeclarationUI:(NSDictionary*)extraInfo
{
    NSLog(@"退出导航声明页面");
}


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
                
//                [self.poiMatchArray removeAllObjects];

                if (self.poiMatchArray.count >= 1) {
                    [self.poiMatchArray removeObjectsInRange:NSMakeRange(1, self.poiMatchArray.count - 1)];
                }
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
        
        BMKDrivingRouteLine *plan = (BMKDrivingRouteLine *)[result.routes objectAtIndex:0];
        int size = (int)[plan.steps count];
        int pointCount = 0;
        for (int i = 0; i< size; i++) {
            BMKDrivingStep *step = [plan.steps objectAtIndex:i];
            pointCount += step.pointsCount;
        }
        BMKMapPoint *points = new BMKMapPoint[pointCount];
        int k = 0;
        for (int i = 0; i< size; i++) {
            BMKDrivingStep *step = [plan.steps objectAtIndex:i];
            for (int j= 0; j<step.pointsCount; j++) {
                points[k].x = step.points[j].x;
                points[k].y = step.points[j].y;
                k++;
            }
        }
        NSLog(@"点的个数:(%d)",k);
        BMKPolyline *polyLine = [BMKPolyline polylineWithPoints:points count:pointCount];
        NSArray *arr = [NSArray arrayWithArray:self.mapView.overlays];
        [self.mapView removeOverlays:arr];
        [_mapView addOverlay:polyLine];
        
        
        
    }
    else if (error == BMK_SEARCH_AMBIGUOUS_ROURE_ADDR){
        NSLog(@"返回驾车路径失败有歧义---%d",result.routes.count);
    }
    else {
        NSLog(@"抱歉，未找到结果");
    }
}


#pragma mark - BMKGeoCodeSearchDelegate -设置城市名称

- (void) onGetReverseGeoCodeResult:(BMKGeoCodeSearch *)searcher result:(BMKReverseGeoCodeResult *)result errorCode:(BMKSearchErrorCode)error
{
    //设置bubble的title 并 给poiMatchArr 添加第一个元素
    BMKPoiInfo *firstInfo = result.poiList[0];
    self.currentLocation.title = firstInfo.name;
    
//    CLLocationCoordinate2D pt1 = CLLocationCoordinate2DMake(userLocation.location.coordinate.latitude, userLocation.location.coordinate.longitude);
//    currentInfo.pt = pt1;
    BMKPoiInfo *info = [[BMKPoiInfo alloc] init];
    info.name = @"当前位置";
    info.pt = firstInfo.pt;
    [self.poiMatchArray insertObject:info atIndex:0];
    
    //设置城市名称
    NSString *cityName = result.addressDetail.city;
    NSString *subStr = [cityName substringWithRange:NSMakeRange(0, cityName.length - 1)];
    self.cityItem.title = subStr;
    MBProgressHUD *hud = [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeText;
    hud.label.text = [NSString stringWithFormat:@"当前定位城市:%@",subStr];
    [hud hideAnimated:YES afterDelay:1.5f];
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
    if (self.startTF.text == nil || self.startTF.text.length == 0)
    {
        [LCCoolHUD showFailure:@"请输入出发地" zoom:YES shadow:NO];
        return;
    }
    if (self.destinationTF.text == nil || self.destinationTF.text.length == 0)
    {
        [LCCoolHUD showFailure:@"请输入目的地" zoom:YES shadow:NO];
        return;
    }
    [self.startTF resignFirstResponder];
    [self.destinationTF resignFirstResponder];
    
    UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"提示"
                                                        message:@"请选择路径规划方式"
                                                       delegate:nil
                                              cancelButtonTitle:@"使用导航"
                                              otherButtonTitles:@"显示路径(最少时间)",@"显示路径(最短距离)",nil];
    alertView.delegate = self;
    [alertView show];

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
        annotation.title = @"点击导航";
        annotation.subtitle = info.name;
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

    self.poiMatchTableView.hidden = NO;
    
    
    if (textField.text.length == 0) {
        self.poiMatchTableView.hidden = YES;
        return;
    }
    
    
    
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

- (IBAction)switchAddressBtnClicked
{
    if (self.startTF.text == nil || self.startTF.text.length == 0)
    {
        [LCCoolHUD showFailure:@"请输入出发地" zoom:YES shadow:NO];
        return;
    }
    if (self.destinationTF.text == nil || self.destinationTF.text.length == 0)
    {
        [LCCoolHUD showFailure:@"请输入目的地" zoom:YES shadow:NO];
        return;
    }
    
    
    
    NSString *str = self.startTF.text;
    self.startTF.text = self.destinationTF.text;
    self.destinationTF.text = str;
    BMKPoiInfo *info = self.startTF.siteInfo;
    self.startTF.siteInfo = self.destinationTF.siteInfo;
    self.destinationTF.siteInfo = info;

    
}

#pragma mark - UIAlertViewDelegate

- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex == 0) {
        NSLog(@"使用导航");
        
        
        //路径点数组
        NSMutableArray *nodesArray = [[NSMutableArray alloc]initWithCapacity:2];
        //起点
        BNRoutePlanNode *startNode = [[BNRoutePlanNode alloc] init];
        startNode.pos = [[BNPosition alloc] init];
        startNode.pos.x = self.startTF.siteInfo.pt.longitude;
        startNode.pos.y = self.startTF.siteInfo.pt.latitude;
        startNode.pos.eType = BNCoordinate_BaiduMapSDK;
        [nodesArray addObject:startNode];
        //终点
        BNRoutePlanNode *endNode = [[BNRoutePlanNode alloc] init];
        endNode.pos = [[BNPosition alloc] init];
        endNode.pos.x = self.destinationTF.siteInfo.pt.longitude;
        endNode.pos.y = self.destinationTF.siteInfo.pt.latitude;
        endNode.pos.eType = BNCoordinate_BaiduMapSDK;
        [nodesArray addObject:endNode];
        
        [BNCoreServices_RoutePlan startNaviRoutePlan:BNRoutePlanMode_Highway naviNodes:nodesArray time:nil delegete:self userInfo:nil];
    }else if(buttonIndex == 1)
    {
        NSLog(@"显示路线,最少时间");
        BMKPoiInfo *startSiteInfo = self.startTF.siteInfo;
        BMKPoiInfo *destinationSiteInfo = self.destinationTF.siteInfo;
        BMKPlanNode *startNode = [[BMKPlanNode alloc] init];
        startNode.pt = startSiteInfo.pt;
        BMKPlanNode *endNode = [[BMKPlanNode alloc] init];
        endNode.pt = destinationSiteInfo.pt;
        BMKDrivingRoutePlanOption *transitRouteSearchOption =         [[BMKDrivingRoutePlanOption alloc]init];
        transitRouteSearchOption.drivingPolicy = BMK_DRIVING_TIME_FIRST;
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
    }else
    {
        NSLog(@"显示路线,最短距离");
        BMKPoiInfo *startSiteInfo = self.startTF.siteInfo;
        BMKPoiInfo *destinationSiteInfo = self.destinationTF.siteInfo;
        BMKPlanNode *startNode = [[BMKPlanNode alloc] init];
        startNode.pt = startSiteInfo.pt;
        BMKPlanNode *endNode = [[BMKPlanNode alloc] init];
        endNode.pt = destinationSiteInfo.pt;
        BMKDrivingRoutePlanOption *transitRouteSearchOption =         [[BMKDrivingRoutePlanOption alloc]init];
        transitRouteSearchOption.drivingPolicy = BMK_DRIVING_DIS_FIRST;
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
}


- (IBAction)getPetrolPriceClicked:(id)sender
{
    NSLog(@"getPetrolPriceClicked");
//    if ([_cityItem.title isEqualToString:@"城市"])
//    {
//        [LCCoolHUD showFailure:@"未定位城市" zoom:YES shadow:YES];
//        return;
//    }
    NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
    [user setObject:@"0" forKey:@"got"];
    AFHTTPSessionManager *session = [AFHTTPSessionManager manager];
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    params[@"city"] = _cityItem.title;
    
    
    NSString *httpUrl = @"http://apis.baidu.com/showapi_open_bus/oil_price/find";
    NSString *httpArg = [NSString stringWithFormat:@"prov=%@",[@"江苏" urlencode]];
    [self request: httpUrl withHttpArg: httpArg];
    



}
-(void)request: (NSString*)httpUrl withHttpArg: (NSString*)HttpArg  {
    NSString *urlStr = [[NSString alloc]initWithFormat: @"%@?%@", httpUrl, HttpArg];
    NSURL *url = [NSURL URLWithString: urlStr];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]initWithURL: url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval: 10];
    [request setHTTPMethod: @"GET"];
    [request addValue: @"9acc80d2aaf5081b3ce84559dc77f6dd" forHTTPHeaderField: @"apikey"];
    [NSURLConnection sendAsynchronousRequest: request
                                       queue: [NSOperationQueue mainQueue]
                           completionHandler: ^(NSURLResponse *response, NSData *data, NSError *error){
                               if (error) {
                                   NSLog(@"Httperror: %@%ld", error.localizedDescription, error.code);
                               } else {
                                   NSInteger responseCode = [(NSHTTPURLResponse *)response statusCode];
                                   NSString *responseString = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
                                   NSLog(@"HttpResponseCode:%ld", responseCode);
                                   NSLog(@"HttpResponseBody %@",responseString);
                                   NSDictionary *dict = [self dictionaryWithJsonString:responseString];
                                   NSDictionary *dict1 = dict[@"showapi_res_body"];
                                   NSArray *array = dict1[@"list"];
                                   if (array.count != 0) {
                                       NSDictionary *dict1 = array[0];
                                       NSString * str90 = dict1[@"p90"];
                                       NSString * str93 = dict1[@"p93"];
                                       NSString * str97 = dict1[@"p97"];
                                       NSUserDefaults *user = [NSUserDefaults standardUserDefaults];
                                       [user setObject:@"1" forKey:@"got"];
                                       [user setObject:str97 forKey:@"p97"];
                                       [user setObject:str93 forKey:@"p93"];
                                       [user setObject:str90 forKey:@"p90"];
                                       
                                   }
                                   
                               }
                           }];
}
- (NSDictionary *)dictionaryWithJsonString:(NSString *)jsonString {
    
    if (jsonString == nil) {
        return nil;
    }
    
    NSData *jsonData = [jsonString dataUsingEncoding:NSUTF8StringEncoding];
    
    NSError *err;
    
    NSDictionary *dic = [NSJSONSerialization JSONObjectWithData:jsonData
                         
                                                        options:NSJSONReadingMutableContainers
                         
                                                          error:&err];
    
    if(err) {
        
        NSLog(@"JSON解析失败：%@",err);
        
        return nil;
        
    }
    return dic;
}

@end
