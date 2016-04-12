//
//  VIMyCarsController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/15.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIMyCarsController.h"
#import "VICarInfoModel.h"
#import "VIMyCarCell.h"
#import "VIModifyCarController.h"

@interface VIMyCarsController ()
@property (nonatomic, strong) NSMutableArray *carList;
@property (nonatomic, assign) NSInteger sectionNum;
@end

@implementation VIMyCarsController

#pragma mark - 懒加载
- (NSMutableArray *)carList{
    if (!_carList) {
        _carList = [NSMutableArray array];
    }
    return _carList;
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    if ([segue.destinationViewController isKindOfClass:[VIModifyCarController class]]) {
        VIModifyCarController *vc = segue.destinationViewController;
        
        NSIndexPath *selectedIndex = [self.tableView indexPathForSelectedRow];
        
        vc.car = self.carList[selectedIndex.row];
        
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self getDataFromLeanCloud];
    
    //覆盖多余空白cell
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    //取消cell分割线
    self.tableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    self.tableView.backgroundView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"BG.png"]];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
#warning Incomplete implementation, return the number of rows
    return self.carList.count * 2;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    if (indexPath.row % 2 != 0) {
        
        VIMyCarCell *cell = [VIMyCarCell carInfoCellWithTableView:tableView];
        cell.carInfo = self.carList[indexPath.row/2];
        return cell;
    } else {
        static NSString *CELL_ID2 = @"SOME_STUPID_ID2";

        UITableViewCell * cell2 = [tableView dequeueReusableCellWithIdentifier:CELL_ID2];
        
        if (cell2 == nil)
        {
            cell2 = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CELL_ID2];
            [cell2 setUserInteractionEnabled:NO]; // prevent selection and other stuff
        }
        return cell2;
    }
    
}


- (void)tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath {
    if ([cell.reuseIdentifier  isEqual: @"SOME_STUPID_ID2"]) {
        cell.alpha = 0;
    } else {
        
        UIImageView *backGround = [[UIImageView alloc] initWithFrame:CGRectMake(cell.x, cell.y, cell.width, cell.height)];
        backGround.image = [UIImage imageNamed:@"CarCell.png"];
        cell.backgroundView = backGround;
        cell.alpha = 0.6;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row % 2 == 0) {
        
        return 12;
    } else {
        return 92;
    }
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [self performSegueWithIdentifier:@"modify" sender:self];
}

- (void)getDataFromLeanCloud {
    AVUser *user = [AVUser currentUser];
    AVQuery *query = [AVQuery queryWithClassName:@"VICarInfoModel"];
    [query whereKey:@"ownerID" equalTo:user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        for (NSDictionary *dict in objects) {
            NSMutableDictionary *loc = [dict valueForKey:@"localData"];
            
            loc[@"objectId"] = [dict valueForKey:@"objectId"];
            [self.carList addObject:[VICarInfoModel carInfoWithDict:loc]];
        }
        [self.tableView reloadData];
    }];
}


@end
