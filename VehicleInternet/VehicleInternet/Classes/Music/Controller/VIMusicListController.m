//
//  VIMusicListController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/3/21.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIMusicListController.h"
#import "VIMusicModel.h"
#import "VIMusicPlayerController.h"

@interface VIMusicListController ()
@property (nonatomic, strong) NSArray *musicArr;
@property (nonatomic, strong) VIMusicModel *model;

@end

@implementation VIMusicListController

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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
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
    return self.musicArr.count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    self.model = self.musicArr[indexPath.row];
    static NSString *ID = @"musiclist";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:ID];
    if (!cell) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleSubtitle reuseIdentifier:ID];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ --- %@",_model.song,_model.singer];
    }
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    VIMusicPlayerController *vc = [[VIMusicPlayerController alloc] init];
    self.delegate = vc;
    if ([_delegate respondsToSelector:@selector(didSelectedMusicForRowAtIndexPath:)]) {
        [_delegate didSelectedMusicForRowAtIndexPath:indexPath];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

@end
