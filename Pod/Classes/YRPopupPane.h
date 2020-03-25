//
//  YRPopupPane.h
//  YRSnippets
//
//  Created by 王晓宇 on 13-11-18.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

/*!
 *	@class	基础的弹出层
 *
 *  @note 如果需要转屏适配，可以通过调整customPopupView的autoresizingMask实现，一般关系如下
     case YRPopupDirection_FromTop:
         customPopupView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;//如果需要宽度跟随变化，再加上UIViewAutoresizingFlexibleWidth
     case YRPopupDirection_FromLeft:
         customPopupView.autoresizingMask = UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;//如果需要高度跟随变化，再加上UIViewAutoresizingFlexibleHeight
     case YRPopupDirection_FromBottom:
             customPopupView.autoresizingMask = UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleRightMargin;//如果需要宽度跟随变化，再加上UIViewAutoresizingFlexibleWidth
     case YRPopupDirection_FromRight:
         customPopupView.autoresizingMask = UIViewAutoresizingFlexibleLeftMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleBottomMargin;//如果需要高度跟随变化，再加上UIViewAutoresizingFlexibleHeight
     case YRPopupDirection_FromMiddle:
         customPopupView.autoresizingMask = UIViewAutoresizingFlexibleBottomMargin|UIViewAutoresizingFlexibleRightMargin|UIViewAutoresizingFlexibleTopMargin|UIViewAutoresizingFlexibleLeftMargin;
 */
#import <UIKit/UIKit.h>

typedef enum {
    YRPopupDirection_FromTop = 1, //上
    YRPopupDirection_FromLeft,    //左
    YRPopupDirection_FromBottom,  //下
    YRPopupDirection_FromRight,   //右
    YRPopupDirection_FromMiddle,  //中间
} YRPopupDirection;

@class YRPopupPane;
typedef void(^YRPopupPaneAnimationBlock)(YRPopupPane *popup, dispatch_block_t finishedBlock);
typedef void(^YRPopupPaneHideBlock)();

@interface YRPopupPane : UIView
@property (assign, nonatomic) YRPopupDirection direction;//弹出方向
@property (strong, nonatomic) UIView *customPopupView;//弹出的视图
@property (assign, nonatomic) NSTimeInterval animateDuration;//动画时长
@property (assign, nonatomic) CGFloat xOffset;//x轴的偏移量
@property (assign, nonatomic) CGFloat yOffset;//y轴的偏移量
@property (assign, nonatomic) BOOL enableBlur NS_AVAILABLE_IOS(8_0);//启用高斯模糊,默认是YES
@property (assign, nonatomic) BOOL needBackgroupView;//是否需要遮罩层,默认是YES,否则直接在被添加的view上弹出
@property (assign, nonatomic) BOOL hideOnTouchBackground;//遮罩存在时，点击遮罩层时自动消失,默认是YES
@property (copy, nonatomic) YRPopupPaneAnimationBlock showAnimationBlock;//可自定义出现动画,一般不需要使用
@property (copy, nonatomic) YRPopupPaneAnimationBlock hideAnimationBlock;//可自定义消失动画,一般不需要使用,动画完成后必须要执行finishedBlock

@property (copy, nonatomic) YRPopupPaneHideBlock willHideForBackgroundTouchBlock;//由于点击背景导致的弹窗消失，只有遮罩存在，且hideOnTouchBackground为YES时生效
@property (copy, nonatomic) YRPopupPaneHideBlock willHideBlock;//即将消失的回调
@property (copy, nonatomic) YRPopupPaneHideBlock didHideBlock;//消失后回调

@property (strong, nonatomic) id data; //生命周期保护,挂到该属性上的data会在弹窗出现期间被额外持有不释放,但要小心别弄成循环引用，不可以是showInView方法的view

- (void)showInView:(UIView *)view animated:(BOOL)animated;
- (void)hide:(BOOL)animated;

- (BOOL)onShow;

+ (void)hideAllPane:(BOOL)animated;//消除所有在显示的弹窗

//为了代码补全
- (void)setShowAnimationBlock:(YRPopupPaneAnimationBlock)showAnimationBlock;
- (void)setHideAnimationBlock:(YRPopupPaneAnimationBlock)hideAnimationBlock;
- (void)setWillHideForBackgroundTouchBlock:(YRPopupPaneHideBlock)hideForBackgroundTouchBlock;
- (void)setWillHideBlock:(YRPopupPaneHideBlock)willHideBlock;
- (void)setDidHideBlock:(YRPopupPaneHideBlock)didHideBlock;
@end
