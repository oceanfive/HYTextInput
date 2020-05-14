//
//  HYTextView.h
//
//  Created by ocean on 16/5/21.
//  Copyright © 2016年 ocean. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HYTextInput.h"

NS_ASSUME_NONNULL_BEGIN

@class HYTextView;

@protocol HYTextViewDelegate <NSObject>

@optional
/// 输入内容发生改变的回调，用于自定义处理，比如限制长度，限制输入字符等，方法返回处理后的字符串内容即可
- (NSString *)hy_textViewDidChangeHandler:(HYTextView *)textView;
/// 输入内容发生改变的代理方法
- (void)hy_textViewDidChange:(HYTextView *)textView;

/// 超过最大长度限制的代理方法
- (void)hy_textViewDidOverMaxInputLength:(HYTextView *)textView maxInputLength:(NSUInteger)maxInputLength;

@end

@interface HYTextView : UITextView <HYTextInput>

@property (nonatomic, weak, nullable) id<HYTextViewDelegate> hy_delegate;

/** 初始化方法 */
- (instancetype)initWithFrame:(CGRect)frame;

/** 占位文字 */
@property (nonatomic, copy) NSString *placeholder;
/** 占位文字颜色 */
@property (nonatomic, strong) UIColor *placeholderColor;
/** 占位文字位置偏移量 */
@property (nonatomic, assign) UIOffset placeholderOffset;

/** 普通情况下的提示文案 */
@property (nonatomic, copy) NSString *normalTipsText;
/** 输入框激活情况下的提示文案 */
@property (nonatomic, copy) NSString *focusTipsText;
/** 普通情况下提示文案颜色 */
@property (nonatomic, strong) UIColor *normalTipsColor;
/** 输入框激活情况下提示文案颜色 */
@property (nonatomic, strong) UIColor *focusTipsColor;

/** 输入内容发生改变会调用的方法 */
- (void)textValueDidChanged;
/** 开始编辑调用的方法 */
- (void)textDidBeginEditing;

@end

NS_ASSUME_NONNULL_END
