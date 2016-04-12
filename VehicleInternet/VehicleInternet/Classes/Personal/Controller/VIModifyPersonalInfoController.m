//
//  VIModifyPersonalInfoController.m
//  VehicleInternet
//
//  Created by 倪丁凡 on 16/4/12.
//  Copyright © 2016年 TomorJM. All rights reserved.
//

#import "VIModifyPersonalInfoController.h"
#import "VIUserModel.h"
#import "LCCoolHUD.h"

@interface VIModifyPersonalInfoController () <UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *nameText;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *saveBtn;
@property (nonatomic, strong) VIUserModel *user;


@end

@implementation VIModifyPersonalInfoController


- (void)viewDidLoad {
    [super viewDidLoad];
    UIView *header = [[UIView alloc] initWithFrame:CGRectMake(0, 64, self.view.width, 10)];
    header.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    self.tableView.tableHeaderView = header;
    self.tableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    self.view.backgroundColor = [UIColor colorWithRed:239/255.0 green:239/255.0 blue:244/255.0 alpha:1];
    UIView *passwordPaddingView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 14, self.nameText.height)];
    self.nameText.leftView = passwordPaddingView;
    self.nameText.leftViewMode = UITextFieldViewModeAlways;
    
    _user = [VIUserModel currentUser];
    self.nameText.text = _user.nickName;
    self.nameText.delegate = self;

}

#pragma mark - UITextFieldDelegate
-  (BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    NSString * aString = [textField.text stringByReplacingCharactersInRange:range withString:string];
    if (self.nameText == textField)
    {
        if ([aString length] > 15) {
            return NO;
        }
    }
    return YES;
    
}

- (IBAction)save:(id)sender {
    if (!self.nameText.text.length) {
        [LCCoolHUD showFailure:@"昵称不能为空" zoom:YES shadow:YES];
    } else {
        _user.nickName = self.nameText.text;
        [_user saveInBackground];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}



@end
