//
//  YRPopupPane.m
//  YRSnippets
//
//  Created by 王晓宇 on 13-11-18.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import "YRPopupPane.h"
static NSMutableArray *lifecyleArray;

@interface YRPopupPane () {
    CGRect _prePopupFrame;
    UIView *_visualEfView;
}
@property (weak, nonatomic) UIView *targetView; //被添加到该view上
@end

@implementation YRPopupPane
+ (void)initialize {
    lifecyleArray = [NSMutableArray arrayWithCapacity:20];
}

- (instancetype)init {
    return [self initWithFrame:CGRectZero];
}

- (id)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
        _direction = YRPopupDirection_FromBottom;
        _animateDuration = 0.25f;
        
        _enableBlur = true;
        _needBackgroupView = true;
        _hideOnTouchBackgroup = true;
        if ([[[UIDevice currentDevice] systemVersion] compare:@"8.0"] != NSOrderedAscending) {
            _visualEfView = [[UIVisualEffectView alloc] initWithEffect:[UIBlurEffect effectWithStyle:UIBlurEffectStyleDark]];
            _visualEfView.alpha = 1;
            [self addSubview:_visualEfView];
        } else {
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

- (void)setEnableBlur:(BOOL)enableBlur {
    _enableBlur = enableBlur;
    _visualEfView.hidden = !enableBlur;
}

- (void)showInView:(UIView *)view animated:(BOOL)animated {
    if (!self.customPopupView) {
        return;
    }
    if (![lifecyleArray containsObject:self]) {
        [lifecyleArray addObject:self];
    }
    _targetView = view;
    _prePopupFrame = self.customPopupView.frame;
    if (_needBackgroupView) {
        self.frame = view.bounds;
        _visualEfView.frame = self.bounds;
        [self addSubview:self.customPopupView];
        [view addSubview:self];
    } else {
        [view addSubview:self.customPopupView];
    }
    if (animated) {
        CGRect toFrame = [self customViewInsideFrameInView:_targetView];
        CGRect fromFrame = [self customViewOutFrameInView:_targetView];
        if (self.showAnimationBlock) {
            self.showAnimationBlock(self, fromFrame, toFrame);
        } else {
            UIView *addedView = _needBackgroupView ? self : self.customPopupView;
            addedView.alpha = 0;
            if (self.direction == YRPopupDirection_FromMiddle) {
                self.customPopupView.frame = toFrame;
                [UIView animateWithDuration:0.1 animations:^{
                    addedView.alpha = 1;
                }completion:nil];
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                animation.duration = self.animateDuration;
                animation.removedOnCompletion = YES;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
                animation.fromValue = [NSNumber numberWithFloat:0.2];
                animation.toValue = [NSNumber numberWithFloat:1];
                [self.customPopupView.layer addAnimation:animation forKey:@"animateTransformScale"];
            } else {
                self.customPopupView.frame = fromFrame;
                [UIView animateWithDuration:0.1 animations:^{
                    addedView.alpha = 1;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.customPopupView.frame = toFrame;
                    }completion:nil];
                }];
            }
        }
    } else {
        self.alpha = 1;
        self.customPopupView.alpha = 1;
        self.customPopupView.frame = [self customViewInsideFrameInView:view];
    }
}
- (void)hide:(BOOL)animated {
    UIView *addedView = _needBackgroupView ? self : self.customPopupView;
    if (![addedView superview]) {
        return;
    }
    [lifecyleArray removeObject:self];
    if (animated) {
        CGRect fromFrame = [self customViewInsideFrameInView:_targetView];
        CGRect toFrame = [self customViewOutFrameInView:_targetView];
        if (self.hideAnimationBlock) {
            self.hideAnimationBlock(self, fromFrame, toFrame);
        } else {
            if (self.direction == YRPopupDirection_FromMiddle) {
                CABasicAnimation *animation = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
                animation.duration = self.animateDuration;
                animation.removedOnCompletion = YES;
                animation.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseOut];;
                animation.fromValue = [NSNumber numberWithFloat:1];
                animation.toValue = [NSNumber numberWithFloat:0.2];
                [self.customPopupView.layer addAnimation:animation forKey:@"animateTransformScale"];
                CGFloat after = MAX(0, self.animateDuration-0.12);
                dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(after * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                    [UIView animateWithDuration:0.1 animations:^{
                        addedView.alpha = 0;
                    }completion:^(BOOL finished) {
                        [addedView removeFromSuperview];
                        addedView.alpha = 1;
                    }];
                });
            } else {
                self.customPopupView.frame = fromFrame;
                [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.customPopupView.frame = toFrame;
                }completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.1 animations:^{
                        addedView.alpha = 0;
                    }completion:^(BOOL finished) {
                        [addedView removeFromSuperview];
                        addedView.alpha = 1;
                    }];
                }];
            }
        }
    } else {
        self.customPopupView.frame = [self customViewInsideFrameInView:_targetView];
        [addedView removeFromSuperview];
        addedView.alpha = 1;
    }
}

- (CGRect)customViewInsideFrameInView:(UIView *)view {
    CGRect frame = CGRectZero;
    switch (self.direction) {
        case YRPopupDirection_FromTop: {
            frame = CGRectMake(self.xOffset + (view.frame.size.width - _prePopupFrame.size.width) / 2, self.yOffset + 0, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        case YRPopupDirection_FromLeft: {
            frame = CGRectMake(self.xOffset + 0, self.yOffset + (view.frame.size.height - _prePopupFrame.size.height) / 2, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        case YRPopupDirection_FromBottom: {
            frame = CGRectMake(self.xOffset + (view.frame.size.width - _prePopupFrame.size.width) / 2, self.yOffset + view.frame.size.height - _prePopupFrame.size.height, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        case YRPopupDirection_FromRight: {
            frame = CGRectMake(self.xOffset + view.frame.size.width - _prePopupFrame.size.width, self.yOffset + (view.frame.size.height - _prePopupFrame.size.height) / 2, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        case YRPopupDirection_FromMiddle: {
            frame = CGRectMake(self.xOffset + (view.frame.size.width - _prePopupFrame.size.width) / 2, self.yOffset + (view.frame.size.height - _prePopupFrame.size.height) / 2, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        default:
            break;
    }
    return frame;
}

- (CGRect)customViewOutFrameInView:(UIView *)view {
    CGRect frame = CGRectZero;
    switch (self.direction) {
        case YRPopupDirection_FromTop: {
            frame = CGRectMake(self.xOffset + (view.frame.size.width - _prePopupFrame.size.width) / 2, self.yOffset - _prePopupFrame.size.height, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        case YRPopupDirection_FromLeft: {
            frame = CGRectMake(self.xOffset - _prePopupFrame.size.width, self.yOffset + (view.frame.size.height - _prePopupFrame.size.height) / 2, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        case YRPopupDirection_FromBottom: {
            frame = CGRectMake(self.xOffset + (view.frame.size.width - _prePopupFrame.size.width) / 2, self.yOffset + view.frame.size.height, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        case YRPopupDirection_FromRight: {
            frame = CGRectMake(self.xOffset + view.frame.size.width, self.yOffset + (view.frame.size.height - _prePopupFrame.size.height) / 2, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        case YRPopupDirection_FromMiddle: {
            frame = CGRectMake(self.xOffset + (view.frame.size.width - _prePopupFrame.size.width) / 2, self.yOffset + (view.frame.size.height - _prePopupFrame.size.height) / 2, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;
        }
        default:
            break;
    }
    return frame;
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    if (CGRectContainsPoint(self.customPopupView.frame, location)) {
        return;
    }else if (_needBackgroupView && _hideOnTouchBackgroup) {
        [self hide:true];
    } else {
        [super touchesEnded:touches withEvent:event];
    }
}

- (BOOL)onShow {
    if (_needBackgroupView) {
        return self.superview != nil;
    } else {
        return self.customPopupView.superview != nil;
    }
}
@end
