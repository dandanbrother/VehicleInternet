//
//  VIMyCarsController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIMyCarsController.h"
#import "VICarInfoModel.h"
#import "VIModifyCarController.h"

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

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"11");
    if ([segue.destinationViewController isKindOfClass:[VIModifyCarController class]]) {
        VIModifyCarController *vc = segue.destinationViewController;
        
        NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
        
        vc.car = self.carList[selectedIndex.row];
        
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getDataFromLeanCloud];
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.carList.count;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
//    NSLog(@"1");
    static NSString *ID = @"carinfo";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.textLabel.text = [self.carList[indexPath.row] valueForKey:@"carBrand"];
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"modify" sender:self];
}

- (void)getDataFromLeanCloud {
    AVQuery *query = [AVQuery queryWithClassName:@"VICarInfoModel"];
    [query includeKey:@"carBrand"];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (NSDictionary *dict in objects) {
            NSMutableDictionary *loc = [dict valueForKey:@"localData"];
            
            loc[@"objectId"] = [dict valueForKey:@"objectId"];
            [self.carList addObject:[VICarInfoModel carInfoWithDict:loc]];
//            NSLog(@"%@",[self.carList[0] objectForKey:@"objectId"]);
        }
        [self.tableView reloadData];
    }];
}


@end
