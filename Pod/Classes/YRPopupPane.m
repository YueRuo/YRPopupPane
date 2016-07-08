//
//  YRPopupPane.m
//  YRSnippets
//
//  Created by 王晓宇 on 13-11-18.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import "YRPopupPane.h"

@interface YRPopupPane (){
    CGRect prePopupFrame;
    UIView *_visualEfView;
}

@end

@implementation YRPopupPane
-(instancetype)init{
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame
{
    self  =  [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _direction = YRPopupDirection_FromBottom;
        _animateDuration = 0.25f;
        
        _enableBlur = true;
        if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending) {
            _visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            _visualEfView.alpha = 1;
            [self addSubview:_visualEfView];
        }else{
            self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
        }
    }
    return self;
}

/*
 // Only override drawRect: if you perform custom drawing.
 // An empty implementation adversely affects performance during animation.
 - (void)drawRect:(CGRect)rect
 {
 // Drawing code
 }
 */

-(void)setEnableBlur:(BOOL)enableBlur{
    _enableBlur = enableBlur;
    _visualEfView.hidden = !enableBlur;
}


-(void)showInView:(UIView*)view animated:(BOOL)animated{
    if (!self.customPopupView) {
        return;
    }
    prePopupFrame = self.customPopupView.frame;
    self.frame = view.bounds;
    _visualEfView.frame = self.bounds;
    [self addSubview:self.customPopupView];
    self.alpha = 0;
    [view addSubview:self];
    if (animated) {
        if (self.direction==YRPopupDirection_FromMiddle) {
            self.customPopupView.transform = CGAffineTransformIdentity;
            self.customPopupView.frame = [self customViewInsideFrameInView:view];
            self.customPopupView.transform = CGAffineTransformMakeScale(0.2, 0.2);
            [UIView animateWithDuration:0.1 animations:^{
                self.alpha = 1;
            }completion:^(BOOL finished) {
                self.alpha = 1;
                [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.customPopupView.transform = CGAffineTransformIdentity;
                } completion:nil];
            }];
        }else{
            self.customPopupView.frame = [self customViewOutFrameInView:view];
            [UIView animateWithDuration:0.1 animations:^{
                self.alpha = 1;
            }completion:^(BOOL finished) {
                self.alpha = 1;
                [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.customPopupView.frame = [self customViewInsideFrameInView:view];
                } completion:nil];
            }];
        }
    }else{
        self.customPopupView.frame = [self customViewInsideFrameInView:view];
    }
}
-(void)hide:(BOOL)animated{
    if (![self superview]) {
        return;
    }
    if (animated) {
        if (self.direction==YRPopupDirection_FromMiddle) {
            self.customPopupView.transform = CGAffineTransformIdentity;
            [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.customPopupView.transform = CGAffineTransformMakeScale(0.2, 0.2);
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.alpha = 0;
                }completion:^(BOOL finished) {
                    self.alpha = 0;
                    self.customPopupView.transform = CGAffineTransformIdentity;
                    [self removeFromSuperview];
                }];
            }];
        }else{
            self.customPopupView.frame = [self customViewInsideFrameInView:[self superview]];
            [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                self.customPopupView.frame = [self customViewOutFrameInView:[self superview]];
            } completion:^(BOOL finished) {
                [UIView animateWithDuration:0.1 animations:^{
                    self.alpha = 0;
                }completion:^(BOOL finished) {
                    self.alpha = 0;
                    [self removeFromSuperview];
                }];
            }];
        }
    }else{
        self.customPopupView.frame = [self customViewInsideFrameInView:[self superview]];
        [self removeFromSuperview];
    }
}

-(CGRect)customViewInsideFrameInView:(UIView*)view{
    CGRect frame = CGRectZero;
    switch (self.direction) {
        case YRPopupDirection_FromTop:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-prePopupFrame.size.width)/2, self.yOffset+0, prePopupFrame.size.width, prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromLeft:{
            frame = CGRectMake(self.xOffset+0, self.yOffset+(view.frame.size.height-prePopupFrame.size.height)/2, prePopupFrame.size.width, prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromBottom:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-prePopupFrame.size.width)/2, self.yOffset+view.frame.size.height-prePopupFrame.size.height, prePopupFrame.size.width, prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromRight:{
            frame = CGRectMake(self.xOffset+view.frame.size.width-prePopupFrame.size.width, self.yOffset+(view.frame.size.height-prePopupFrame.size.height)/2, prePopupFrame.size.width, prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromMiddle:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-prePopupFrame.size.width)/2, self.yOffset+(view.frame.size.height-prePopupFrame.size.height)/2, prePopupFrame.size.width, prePopupFrame.size.height);
            break;}
        default:
            break;
    }
    return frame;
}

-(CGRect)customViewOutFrameInView:(UIView*)view{
    CGRect frame = CGRectZero;
    switch (self.direction) {
        case YRPopupDirection_FromTop:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-prePopupFrame.size.width)/2, self.yOffset-prePopupFrame.size.height, prePopupFrame.size.width, prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromLeft:{
            frame = CGRectMake(self.xOffset-prePopupFrame.size.width, self.yOffset+(view.frame.size.height-prePopupFrame.size.height)/2, prePopupFrame.size.width, prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromBottom:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-prePopupFrame.size.width)/2, self.yOffset+view.frame.size.height, prePopupFrame.size.width, prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromRight:{
            frame = CGRectMake(self.xOffset+view.frame.size.width, self.yOffset+(view.frame.size.height-prePopupFrame.size.height)/2, prePopupFrame.size.width, prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromMiddle:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-1)/2, self.yOffset+(view.frame.size.height-1)/2, 1, 1);
            break;}
        default:
            break;
    }
    return frame;
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    if (CGRectContainsPoint(self.customPopupView.frame, location)) {
        return;
    }
    [self hide:true];
}

-(BOOL)onShow{
    return self.superview!=nil;
}
@end
