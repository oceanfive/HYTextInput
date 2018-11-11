//
//  HYKeyBoardInputView.m
//  HYFoundation
//
//  Created by ocean on 2018/8/10.
//  Copyright © 2018年 ocean. All rights reserved.
//

#import "HYKeyBoardInputView.h"
#import "HYAutoIncreasingTextView.h"


@implementation UIView (HYFirstResponderHelper)

- (UIView *)findCanBecomeFirstResponderView {
    if ([self canBecomeFirstResponder]) {
        return self;
    }
    for (UIView *subview in self.subviews) {
        UIView *responder = [subview findCanBecomeFirstResponderView];
        if (responder) {
            return responder;
        }
    }
    return nil;
}

@end

#pragma mark - ---------------------

#define UICOLORFROMRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

@interface HYKeyBoardInputView ()<HYAutoIncreasingTextViewDelegate>
/// 左右间距
@property (nonatomic, assign) CGFloat lrMargin;
/// 上下间距
@property (nonatomic, assign) CGFloat tbMargin;

/**
 键盘的状态:
 默认是YES，将要显示的状态，这时候是显示键盘操作
 NO，将要隐藏的状态，这时候是隐藏键盘操作
 注意：键盘dismiss之后需要重新设置为YES
 */
@property (nonatomic, assign, getter=isKeyboardWillShow) BOOL keyboardWillShow;
/// 本身初始的frame，用于dismiss的时候，键盘位置复原
@property (nonatomic, assign) CGRect originalFrame;
/// 键盘的frame，用属性记录，因为自增长高度的时候，也会用到
@property (nonatomic, assign) CGRect keyboardFrame;
/// 键盘的动画时间
@property (nonatomic, assign) CGFloat duration;

@end

@implementation HYKeyBoardInputView

- (instancetype)initWithFrame:(CGRect)frame accessoryView:(__kindof UIView *)accessoryView {
    self = [super initWithFrame:frame];
    if (self) {
        _originalFrame = frame;
        _lrMargin = 15;
        _tbMargin = 10;
        _duration = 0.25;
        _keyboardWillShow = YES;
        _responderEnabled = YES;
        self.backgroundColor = UICOLORFROMRGB(0xfafafa);
        self.layer.borderColor = [UICOLORFROMRGB(0xcccccc) CGColor];
        self.layer.borderWidth = 0.7;
        if (accessoryView) {
            _accessoryView = accessoryView;
            [self addSubview:accessoryView];
        } else {
            [self initDefaultSubViews];
        }
        [self addNotificationObserver];
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame accessoryView:nil];
}

- (void)addNotificationObserver {
    // 这里 监听的对象是 nil ，因为下一个页面也存在输入框的话，会有输入框无法弹出的异常
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillChangeFrame:) name:UIKeyboardWillChangeFrameNotification object:nil];
}

- (void)initDefaultSubViews {
    UIFont *font = [UIFont systemFontOfSize:18];
    HYAutoIncreasingTextView *inputTextView = [[HYAutoIncreasingTextView alloc] init];
    inputTextView.placeholder = @"";
    inputTextView.placeholderColor = UICOLORFROMRGB(0xcccccc);
    inputTextView.font = font;
    inputTextView.textColor = UICOLORFROMRGB(0x333333);
    inputTextView.maxNumberOfLines = 5;
    inputTextView.layer.borderColor = [UICOLORFROMRGB(0xeeeeee) CGColor];
    inputTextView.layer.borderWidth = 0.7;
    inputTextView.layer.cornerRadius = 8;
    inputTextView.returnKeyType = UIReturnKeySend;
    inputTextView.hy_autoIncreasingDelegate = self;
    [self addSubview:inputTextView];
    self.inputTextView = inputTextView;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    if (self.inputTextView) {
        self.inputTextView.frame = CGRectMake(self.lrMargin, self.tbMargin, CGRectGetWidth(self.frame) - 2 * self.lrMargin, CGRectGetHeight(self.frame) - 2 * self.tbMargin);
    } else {
        self.accessoryView.frame = self.bounds;
    }
}

#pragma mark - HYAutoIncreasingTextViewDelegate

- (void)hy_autoIncreasingTextViewHeightDidChanged:(HYAutoIncreasingTextView *)textView height:(CGFloat)height {
    if (!textView.isMaxHeightReached) {
        [self updateFrameByTextHeight:height];
    }
}

- (void)updateFrameByTextHeight:(CGFloat)textHeight {
    CGRect frame = self.frame;
    frame.size.height = textHeight + 2 * self.tbMargin;
    self.frame = frame;
    [self updateViewFrame];
}

- (void)updateViewFrame {
    if (self.responderEnabled) {
        CGRect frame = self.originalFrame;
        // 处理高度问题，自增长高度变化了
        frame.size.height = self.frame.size.height;
        // 高度，不是y偏移量
        frame.origin.y += -(self.keyboardFrame.size.height + self.bounds.size.height);
        
        if (self.keyboardWillShow) {
            [UIView animateWithDuration:self.duration animations:^{
                self.frame = frame;
            }];
        } else {
            [UIView animateWithDuration:self.duration animations:^{
                self.frame = self.originalFrame;
            } completion:^(BOOL finished) {
                if (finished) {
                    self.keyboardWillShow = YES;
                }
            }];
        }
    }
}

- (void)hy_becomeFirstResponder {
    if (self.inputTextView) {
        [self.inputTextView becomeFirstResponder];
    } else {
        UIView *responder = [self findCanBecomeFirstResponderView];
        if (responder) {
            [responder becomeFirstResponder];
        }
    }
}

- (void)hy_resignFirstResponder {
    if (self.inputTextView) {
        [self.inputTextView resignFirstResponder];
    } else {
        [self endEditing:YES];
    }
}

#pragma mark - notification

- (void)keyboardWillShow:(NSNotification *)noti {
    NSLog(@"keyboardWillShow: %@", noti);
    if (self.responderEnabled) {
        self.keyboardWillShow = YES;
        if (self.delegate && [self.delegate respondsToSelector:@selector(hy_keyboardWillShow:userInfo:)]) {
            [self.delegate hy_keyboardWillShow:self userInfo:noti.userInfo];
        }
    }
}

- (void)keyboardWillHide:(NSNotification *)noti {
    NSLog(@"keyboardWillHide: %@", noti);
    if (self.responderEnabled) {
        self.keyboardWillShow = NO;
        [self updateViewFrame];
        if (self.delegate && [self.delegate respondsToSelector:@selector(hy_keyboardWillHide:userInfo:)]) {
            [self.delegate hy_keyboardWillHide:self userInfo:noti.userInfo];
        }
    }
}

- (void)keyboardWillChangeFrame:(NSNotification *)noti {
    NSLog(@"keyboardWillChangeFrame: %@", noti);
    if (self.responderEnabled) {
        [self.superview bringSubviewToFront:self];
        
        CGFloat duration = [[noti.userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] floatValue];
        CGRect endFrame = [[noti.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
        
        self.keyboardFrame = endFrame;
        self.duration = duration;
        
        [self updateViewFrame];
        
        if (self.delegate && [self.delegate respondsToSelector:@selector(hy_keyboardWillChangeFrame:userInfo:)]) {
            [self.delegate hy_keyboardWillChangeFrame:self userInfo:noti.userInfo];
        }
    }
}

#pragma mark - setter / getter
- (NSString *)inputText {
    if (self.inputTextView) {
        return self.inputTextView.text;
    } else {
        return nil;
    }
}

- (void)setInputText:(NSString *)inputText {
    if (self.inputTextView) {
        self.inputTextView.text = inputText;
    }
}

- (void)clearInputText {
    if (self.inputTextView) {
        self.inputTextView.text = nil;
    }
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

@end
