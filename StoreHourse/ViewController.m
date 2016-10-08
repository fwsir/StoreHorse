//
//  ViewController.m
//  StoreHourse
//
//  Created by BOOM on 16/9/20.
//  Copyright © 2016年 DEVIL. All rights reserved.
//

#import "ViewController.h"
#import "StoreHourseView.h"

@interface ViewController () <UIScrollViewDelegate, UITableViewDelegate, UITableViewDataSource>

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (nonatomic, strong) StoreHourseView *hourseView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.backgroundColor = [UIColor colorWithWhite:45.f/255.f alpha:1.0];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"Cell"];
    
    UIView *footer = [[UIView alloc] init];
    self.tableView.tableFooterView = footer;
    
    self.hourseView = [StoreHourseView attachToScrollView:self.tableView
                                                   target:self
                                            refreshAction:@selector(_refreshTriggered:)
                                                    plist:@"AKTA"
                                                    color:[UIColor whiteColor]
                                                lineWidth:1.5
                                               dropHeight:80
                                                    scale:1
                                     horizontalRandomness:150
                                  reverseLoadingAnimation:YES
                                  internalAnimationFactor:0.5];
}

#pragma mark - TableView Delegate DataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 420;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"Cell" forIndexPath:indexPath];
    
    UIImageView *image = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"cell"]];
    image.translatesAutoresizingMaskIntoConstraints = NO;
    [cell.contentView addSubview:image];
    
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:image attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterX multiplier:1 constant:0]];
    [cell.contentView addConstraint:[NSLayoutConstraint constraintWithItem:image attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:cell.contentView attribute:NSLayoutAttributeCenterY multiplier:1 constant:0]];
    
    cell.backgroundColor = [UIColor clearColor];
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    
    return cell;
}

#pragma mark - Notifying Refresh

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    NSLog(@"ContentOffset is %f", scrollView.contentOffset.y);
    
    
    [self.hourseView scrollViewDidScroll];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate
{
    [self.hourseView scrollViewDidEndDragging];
}

- (void)_refreshTriggered:(id)sender
{
    [self performSelector:@selector(_finishRefresh) withObject:nil afterDelay:3 inModes:@[NSRunLoopCommonModes]];
}

- (void)_finishRefresh
{
    [self.hourseView finishingLoading];
}

- (UIStatusBarStyle)preferredStatusBarStyle
{
    return UIStatusBarStyleLightContent;
}

@end
