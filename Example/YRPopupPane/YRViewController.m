//
//  YRViewController.m
//  YRPopupPane
//
//  Created by wangxiaoyu on 01/19/2016.
//  Copyright (c) 2016 wangxiaoyu. All rights reserved.
//

#import "YRViewController.h"
#import "YRPopupPane.h"

@interface YRViewController (){
}

@end

@implementation YRViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    self.view.backgroundColor = UIColor.brownColor;
    
}
- (IBAction)clicked:(id)sender {
    YRPopupPane *popup = [[YRPopupPane alloc]init];
    UIButton *customView = [[UIButton alloc]initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 100)];
    [customView addTarget:self action:@selector(hide:) forControlEvents:UIControlEventTouchUpInside];
    customView.backgroundColor = [UIColor purpleColor];
    
    popup.customPopupView = customView;
    popup.direction = YRPopupDirection_FromBottom;
    [popup showInView:self.view animated:true];
}
- (IBAction)click2:(id)sender {
    YRPopupPane *popup = [[YRPopupPane alloc]init];
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 50, 100)];
    customView.backgroundColor = [UIColor brownColor];
    
    popup.customPopupView = customView;
    popup.direction = YRPopupDirection_FromRight;
    popup.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    popup.enableBlur = false;
    [popup showInView:self.view animated:true];
}
- (IBAction)click3:(id)sender {
    YRPopupPane *popup = [[YRPopupPane alloc]init];
    UIView *customView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 150, 100)];
    customView.backgroundColor = [UIColor brownColor];
    
    popup.customPopupView = customView;
    popup.xOffset = -100;
    popup.direction = YRPopupDirection_FromTop;
    [popup showInView:self.view animated:true];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
@end
