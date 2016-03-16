//
//  VIMyCarsController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIMyCarsController.h"
#import "VICarInfoModel.h"

@interface VIMyCarsController ()
@property (nonatomic, strong) NSMutableArray *carList;
@end

@implementation VIMyCarsController

#pragma mark - 懒加载
- (NSMutableArray *)carList{
    if (!_carList) {
        self.carList = [NSMutableArray array];
    }
    return _carList;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    NSDictionary *carDict1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"大众1",@"carBrand",@"苏A123",@"licenseNum",@"1112",@"engineNum", nil];
    NSDictionary *carDict2 = [[NSDictionary alloc] initWithObjectsAndKeys:@"大众2",@"carBrand",@"苏A123",@"licenseNum",@"1112",@"engineNum", nil];
    NSDictionary *carDict3 = [[NSDictionary alloc] initWithObjectsAndKeys:@"大众3",@"carBrand",@"苏A123",@"licenseNum",@"1112",@"engineNum", nil];
//    VICarInfoModel *car1 = [VICarInfoModel carInfoWithDict:carDict];
    NSArray *array = [NSArray arrayWithObjects:carDict1,carDict2,carDict3];
    
    for (NSDictionary *dict in array) {
        [self.carList addObject:[VICarInfoModel carInfoWithDict:dict]   ];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
#warning Incomplete implementation, return the number of sections
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.carList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *ID = @"carinfo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.textLabel.text = [self.carList[indexPath.row] valueForKey:@"carBrand"];
    }
    
    return cell;
}

- (IBAction)addCar:(id)sender {
    NSDictionary *carDict1 = [[NSDictionary alloc] initWithObjectsAndKeys:@"大众1",@"carBrand",@"苏A123",@"licenseNum",@"1112",@"engineNum", nil];
    [self.carList addObject:[VICarInfoModel carInfoWithDict:carDict1]];
    [self.tableView reloadData];
}

@end
