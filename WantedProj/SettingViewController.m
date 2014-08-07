//
//  SettingViewController.m
//  WantedProj
//
//  Created by JD_Acorld on 14-8-4.
//  Copyright (c) 2014年 hxy. All rights reserved.
//

#import "SettingViewController.h"

@interface SettingViewController ()<UITableViewDelegate, UITableViewDataSource>
{
    
}
@end

@implementation SettingViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"设置";
    [self.navigationController setNavigationBarHidden:NO animated:NO];
    self.view.backgroundColor = [UIColor whiteColor];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark -
#pragma -mark ==== Method ====
#pragma mark -

- (void)didSwitchCameraDirection:(UISwitch *)s
{
    [[XYTool sharedXYTool] setCameraFront:s.on];
    [self.tableView reloadRowsAtIndexPaths:@[[NSIndexPath indexPathForRow:0 inSection:0]] withRowAnimation:UITableViewRowAnimationNone];
}

#pragma mark -
#pragma -mark ==== TableView Delegate & DataSource ====
#pragma mark -

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 2;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"identifier";
    NSInteger row = indexPath.row;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier];
    if (nil == cell)
    {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:identifier];
    }
    
    switch (row) {
        case 0:
        {
            BOOL isFront = [[XYTool sharedXYTool] cameraIsFront];
            cell.textLabel.text = [NSString stringWithFormat:@"摄像头方向:%@",isFront ? @"前置摄像头" : @"后置摄像头"];
            UISwitch *s = [[UISwitch alloc] initWithFrame:(CGRect){0,0,51,31}];
            [s addTarget:self action:@selector(didSwitchCameraDirection:) forControlEvents:UIControlEventValueChanged];
            s.on = isFront;
            cell.accessoryView = s;
            break;
        }
        case 1:
        {
            cell.textLabel.text = @"请设置自己的头像";
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            break;
        }
        default:
            break;
    }
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NSInteger row = indexPath.row;
    switch (row) {
        case 1:
        {
            NSLog(@"11 %@",@"11");
            break;
        }
        default:
            break;
    }
}

@end
