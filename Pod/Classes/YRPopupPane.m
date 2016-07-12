//
//  YRPopupPane.m
//  YRSnippets
//
//  Created by 王晓宇 on 13-11-18.
//  Copyright (c) 2013年 王晓宇. All rights reserved.
//

#import "YRPopupPane.h"
static NSMutableArray *lifecyleArray;

@interface YRPopupPane (){
    CGRect _prePopupFrame;
    UIView *_visualEfView;
}
@property (weak,nonatomic) UIView *targetView;//被添加到该view上
@end

@implementation YRPopupPane
+(void)initialize{
    lifecyleArray = [NSMutableArray arrayWithCapacity:20];
}

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
        _needBackgroupView = true;
        _hideOnTouchBackgroup = true;
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
    if (![lifecyleArray containsObject:self]) {
        [lifecyleArray addObject:self];
    }
    _targetView = view;
    _prePopupFrame = self.customPopupView.frame;
    if (_needBackgroupView) {
        self.frame = view.bounds;
        _visualEfView.frame = self.bounds;
        [self addSubview:self.customPopupView];
        self.alpha = 0;
        [view addSubview:self];
    }else{
        self.customPopupView.alpha = 0;
        [view addSubview:self.customPopupView];
    }
    if (animated) {
        CGRect toFrame = [self customViewInsideFrameInView:_targetView];
        CGRect fromFrame = [self customViewOutFrameInView:_targetView];
        if(self.showAnimationBlock){
            self.showAnimationBlock(self,fromFrame,toFrame);
        }else{
            UIView *addedView = _needBackgroupView?self:self.customPopupView;
            if (self.direction==YRPopupDirection_FromMiddle) {
                self.customPopupView.transform = CGAffineTransformIdentity;
                self.customPopupView.frame = toFrame;
                self.customPopupView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                [UIView animateWithDuration:0.1 animations:^{
                    addedView.alpha = 1;
                }completion:^(BOOL finished) {
                    addedView.alpha = 1;
                    [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.customPopupView.transform = CGAffineTransformIdentity;
                    } completion:nil];
                }];
            }else{
                self.customPopupView.frame = fromFrame;
                [UIView animateWithDuration:0.1 animations:^{
                    addedView.alpha = 1;
                }completion:^(BOOL finished) {
                    addedView.alpha = 1;
                    [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                        self.customPopupView.frame = toFrame;
                    } completion:nil];
                }];
            }
        }
    }else{
        self.customPopupView.frame = [self customViewInsideFrameInView:view];
    }
}
-(void)hide:(BOOL)animated{
    UIView *addedView = _needBackgroupView?self:self.customPopupView;
    if (![addedView superview]) {
        return;
    }
    [lifecyleArray removeObject:self];
    if (animated) {
        CGRect fromFrame = [self customViewInsideFrameInView:_targetView];
        CGRect toFrame = [self customViewOutFrameInView:_targetView];
        if (self.hideAnimationBlock) {
            self.hideAnimationBlock(self,fromFrame,toFrame);
        }else{
            if (self.direction==YRPopupDirection_FromMiddle) {
                self.customPopupView.transform = CGAffineTransformIdentity;
                [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.customPopupView.transform = CGAffineTransformMakeScale(0.2, 0.2);
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.1 animations:^{
                        addedView.alpha = 0;
                    }completion:^(BOOL finished) {
                        addedView.alpha = 0;
                        self.customPopupView.transform = CGAffineTransformIdentity;
                        [addedView removeFromSuperview];
                    }];
                }];
            }else{
                self.customPopupView.frame = fromFrame;
                [UIView animateWithDuration:self.animateDuration delay:0 options:UIViewAnimationOptionCurveEaseInOut animations:^{
                    self.customPopupView.frame = toFrame;
                } completion:^(BOOL finished) {
                    [UIView animateWithDuration:0.1 animations:^{
                        addedView.alpha = 0;
                    }completion:^(BOOL finished) {
                        addedView.alpha = 0;
                        [addedView removeFromSuperview];
                    }];
                }];
            }
        }
    }else{
        self.customPopupView.frame = [self customViewInsideFrameInView:_targetView];
        [addedView removeFromSuperview];
    }
}

-(CGRect)customViewInsideFrameInView:(UIView*)view{
    CGRect frame = CGRectZero;
    switch (self.direction) {
        case YRPopupDirection_FromTop:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-_prePopupFrame.size.width)/2, self.yOffset+0, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromLeft:{
            frame = CGRectMake(self.xOffset+0, self.yOffset+(view.frame.size.height-_prePopupFrame.size.height)/2, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromBottom:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-_prePopupFrame.size.width)/2, self.yOffset+view.frame.size.height-_prePopupFrame.size.height, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromRight:{
            frame = CGRectMake(self.xOffset+view.frame.size.width-_prePopupFrame.size.width, self.yOffset+(view.frame.size.height-_prePopupFrame.size.height)/2, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromMiddle:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-_prePopupFrame.size.width)/2, self.yOffset+(view.frame.size.height-_prePopupFrame.size.height)/2, _prePopupFrame.size.width, _prePopupFrame.size.height);
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
            frame = CGRectMake(self.xOffset+(view.frame.size.width-_prePopupFrame.size.width)/2, self.yOffset-_prePopupFrame.size.height, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromLeft:{
            frame = CGRectMake(self.xOffset-_prePopupFrame.size.width, self.yOffset+(view.frame.size.height-_prePopupFrame.size.height)/2, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromBottom:{
            frame = CGRectMake(self.xOffset+(view.frame.size.width-_prePopupFrame.size.width)/2, self.yOffset+view.frame.size.height, _prePopupFrame.size.width, _prePopupFrame.size.height);
            break;}
        case YRPopupDirection_FromRight:{
            frame = CGRectMake(self.xOffset+view.frame.size.width, self.yOffset+(view.frame.size.height-_prePopupFrame.size.height)/2, _prePopupFrame.size.width, _prePopupFrame.size.height);
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
    if (_needBackgroupView&&_hideOnTouchBackgroup) {
        UITouch *touch = [touches anyObject];
        CGPoint location = [touch locationInView:self];
        if (CGRectContainsPoint(self.customPopupView.frame, location)) {
            return;
        }
        [self hide:true];
    }else{
        [super touchesEnded:touches withEvent:event];
    }
}

-(BOOL)onShow{
    if (_needBackgroupView) {
        return self.superview!=nil;
    }else{
        return self.customPopupView.superview!=nil;
    }
}
@end
