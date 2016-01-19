//
//  YRPopupPane.h
//  YRSnippets
//
//  Created by 王晓宇 on 13-11-18.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

/*!
 *	@class	基础的弹出层
 */
#import <UIKit/UIKit.h>

typedef enum {
    YRPopupDirection_FromTop=1,//上
    YRPopupDirection_FromLeft,//左
    YRPopupDirection_FromBottom,//下
    YRPopupDirection_FromRight,//右
    YRPopupDirection_FromMiddle,//中间
}YRPopupDirection;

@interface YRPopupPane : UIView
@property (assign,nonatomic) YRPopupDirection direction;//弹出方向
@property (retain,nonatomic) UIView *customPopupView;//弹出的视图
@property (assign,nonatomic) NSTimeInterval animateDuration;//动画时长
@property (assign,nonatomic) BOOL enableBlur NS_AVAILABLE_IOS(8_0);//启用高斯模糊,默认是YES

@property (assign,nonatomic) CGFloat xOffset;//x轴的偏移量
@property (assign,nonatomic) CGFloat yOffset;//y轴的偏移量

-(void)showInView:(UIView*)view animated:(BOOL)animated;
-(void)hide:(BOOL)animated;

-(BOOL)onShow;
@end
