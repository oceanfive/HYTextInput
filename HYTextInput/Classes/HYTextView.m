//
//  HYTextView.m
//
//  Created by ocean on 16/5/21.
//  Copyright © 2016年 ocean. All rights reserved.
//

#import "HYTextView.h"

@interface HYTextView ()

/** UITextView添加一个UILabel，形成占位文字 */
@property (nonatomic, strong) UILabel *placeholderLabel;
/** 右下角的提示label */
@property (nonatomic, strong) UILabel *tipsLabel;

@end

@implementation HYTextView

@synthesize hy_maxInputLength = _hy_maxInputLength;
@synthesize hy_truncatedWhenOverMaxInputLength = _hy_truncatedWhenOverMaxInputLength;

#pragma mark - init

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _hy_truncatedWhenOverMaxInputLength = YES;
        _isShowRemainingCountWhenFocus = YES;
        _lengthOfShowTips = 10;
        _placeholderOffset = UIOffsetZero;
        _normalTipsText = @"";
        _focusTipsText = @"";
        _normalTipsColor = [UIColor blueColor];
        _focusTipsColor = [UIColor redColor];

        self.placeholderLabel = [[UILabel alloc] init];
        self.placeholderLabel.text = @"请输入占位文字";
        self.placeholderLabel.numberOfLines = 0;
        self.placeholderLabel.textColor = [UIColor lightGrayColor];
        self.font = [UIFont systemFontOfSize:20.0];
        self.placeholderLabel.font = self.font;
        [self addSubview:self.placeholderLabel];
        [self addSubview:self.tipsLabel];

        // UITextView内容发生变化，发出通知，是否显示UILabel
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textValueDidChanged) name:UITextViewTextDidChangeNotification object:self];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidBeginEditing) name:UITextViewTextDidBeginEditingNotification object:self];
    }
    return self;
}

#pragma mark - 富文本处理
/**
 * UITextView内容变化，发出通知，调用方法----确定是否显示占位文字---普通文本，和富文本都需要判断
 */
- (void)textValueDidChanged {
    self.placeholderLabel.hidden = self.hasText;
    self.tipsLabel.text = self.hasText ? self.focusTipsText : self.normalTipsText;
    self.tipsLabel.textColor = self.hasText ? self.focusTipsColor : self.normalTipsColor;
    // 代理方法的处理
    if (![self hy_hasMarkedText]) {
        // 最大输入长度的限制
        if (self.hy_maxInputLength > 0 &&
            self.text.length > self.hy_maxInputLength) {
            if (self.hy_delegate && [self.hy_delegate respondsToSelector:@selector(hy_textViewDidOverMaxInputLength:maxInputLength:)]) {
                [self.hy_delegate hy_textViewDidOverMaxInputLength:self maxInputLength:self.hy_maxInputLength];
            }
            
            // 超过最大长度的截断处理
            if (self.hy_truncatedWhenOverMaxInputLength) {
                NSString *tempText = self.text;
                // Composed 方法可以防止emoji表情被中间截断
                tempText = [tempText substringWithRange:[tempText rangeOfComposedCharacterSequencesForRange:NSMakeRange(0, self.hy_maxInputLength)]];
                self.text = tempText;
            }
        }
    }
    // 自定义回调处理
    if (self.hy_delegate && [self.hy_delegate respondsToSelector:@selector(hy_textViewDidChangeHandler:)]) {
        NSString *handledString = [self.hy_delegate hy_textViewDidChangeHandler:self];
        if (handledString) {
            self.text = handledString;
        }
    }
    // 通知代理
    if (self.hy_delegate && [self.hy_delegate respondsToSelector:@selector(hy_textViewDidChange:)]) {
        [self.hy_delegate hy_textViewDidChange:self];
    }
    // 剩余输入字符数
    if (self.lengthOfShowTips > 0 && self.text.length >= self.lengthOfShowTips) {
        NSString *text = [NSString stringWithFormat:@"%@/%@", @(self.text.length), @(self.hy_maxInputLength)];
        self.tipsLabel.text = text;
    }
}

- (void)textDidBeginEditing {
    // do nothing
}

- (void)setAttributedText:(NSAttributedString *)attributedText {
    [super setAttributedText:attributedText];
    [self textValueDidChanged];
}

/**
 *  占位文字
 */
- (void)setPlaceholder:(NSString *)placeholder {
    _placeholder = [placeholder copy];
    self.placeholderLabel.text = placeholder;
    [self setNeedsLayout]; //刷新布局
}

/**
 *  占位文字颜色
 */
- (void)setPlaceholderColor:(UIColor *)placeholderColor {
    self.placeholderLabel.textColor = placeholderColor;
}

/**
 *  设置UITextView字体，需要重新设置占位文字字体
 */
- (void)setFont:(UIFont *)font {
    [super setFont:font]; //这里需要调用父类的方法,否则会报错，并且字体不一致
    self.placeholderLabel.font = font;
    self.tipsLabel.font = font;
    [self setNeedsLayout]; //UITextView的字体变化，内部的placeholderLabel也要跟随变化
}

- (void)setNormalTipsText:(NSString *)normalTipsText {
    _normalTipsText = [normalTipsText copy];
    self.tipsLabel.text = _normalTipsText;
    [self setNeedsLayout];
}

- (void)setFocusTipsText:(NSString *)focusTipsText {
    _focusTipsText = [focusTipsText copy];
    [self setNeedsLayout];
}

- (void)setNormalTipsColor:(UIColor *)normalTipsColor {
    _normalTipsColor = normalTipsColor;
    _tipsLabel.textColor = normalTipsColor;
}

/**
 *  自动布局子控件placeholderLabel的frame
 */
- (void)layoutSubviews {
    [super layoutSubviews];
    // 根据placeholderLabel的内容计算宽度和高度
    CGFloat maxWidth = self.frame.size.width - self.textContainerInset.left - self.textContainerInset.right;
    CGRect placeholderRect = [self.placeholderLabel.text boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.placeholderLabel.font} context:nil];
    self.placeholderLabel.frame = CGRectMake(self.textContainerInset.left + 3.0 + self.placeholderOffset.horizontal, self.textContainerInset.top + self.placeholderOffset.vertical, placeholderRect.size.width, placeholderRect.size.height);

    // 右下角提示文案
    NSString *tipsText = self.normalTipsText;
    if (self.focusTipsText && self.focusTipsText.length > tipsText.length) {
        tipsText = self.focusTipsText;
    }

    CGRect tipsRect = [tipsText boundingRectWithSize:CGSizeMake(maxWidth, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:self.tipsLabel.font} context:nil];
    CGFloat mHeight = self.contentSize.height <= self.bounds.size.height ? self.bounds.size.height : self.contentSize.height;
    CGFloat tipsLabelY = mHeight - self.textContainerInset.bottom - tipsRect.size.height;
    self.tipsLabel.frame = CGRectMake(self.textContainerInset.left + 3.0, tipsLabelY, maxWidth, tipsRect.size.height);
}

/**
 *  销毁通知
 */
- (void)dealloc{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (UILabel *)tipsLabel {
    if (!_tipsLabel) {
        _tipsLabel = [[UILabel alloc] init];
        _tipsLabel.text = @"请输入提示文案";
        _tipsLabel.font = [UIFont systemFontOfSize:12.0f];
        _tipsLabel.textColor = _normalTipsColor;
        _tipsLabel.textAlignment = NSTextAlignmentRight;
    }
    return _tipsLabel;;
}

#pragma mark - range / textRange

- (UITextPosition *)hy_beginningPositionFromRange:(NSRange)range {
    return [self positionFromPosition:self.beginningOfDocument offset:range.location];
}

- (UITextPosition *)hy_endPositionFromRange:(NSRange)range {
    return [self positionFromPosition:self.beginningOfDocument offset:range.location + range.length];
}

- (UITextRange *)hy_textRangeFromRange:(NSRange)range {
    UITextPosition *beginPosition = [self hy_beginningPositionFromRange:range];
    UITextPosition *endPosition = [self hy_endPositionFromRange:range];
    return [self textRangeFromPosition:beginPosition toPosition:endPosition];
}

- (NSInteger)hy_indexFromPositon:(UITextPosition *)position {
    return [self offsetFromPosition:self.beginningOfDocument toPosition:position];
}

- (NSRange)hy_rangeFormTextRange:(UITextRange *)textRange {
    NSInteger beginIndex = [self hy_indexFromPositon:textRange.start];
    NSInteger endIndex = [self hy_indexFromPositon:textRange.end];
    // 这里使用的是系统的offset，不需要 +1
    return NSMakeRange(beginIndex, endIndex - beginIndex);
}

#pragma mark - select 选中
- (BOOL)hy_hasSelectedText {
    return !self.selectedTextRange.isEmpty;
}

- (NSString *)hy_selectedText {
    return [self textInRange:self.selectedTextRange];
}

- (NSRange)hy_selectedRange {
    return [self hy_rangeFormTextRange:self.selectedTextRange];
}

#pragma mark - marked 临时的
- (BOOL)hy_hasMarkedText {
    // Nil if no marked text.
    if (!self.markedTextRange) return NO;
    return !self.markedTextRange.isEmpty;
}

- (NSString *)hy_markedText {
    return [self textInRange:self.markedTextRange];
}

- (NSRange)hy_markedRange {
    return [self hy_rangeFormTextRange:self.markedTextRange];
}

#pragma mark - 光标处理
- (NSUInteger)hy_cursorPosition {
    return self.hy_selectedRange.location;
}

- (void)setHy_cursorPosition:(NSUInteger)hy_cursorPosition {
    [self hy_moveCursorTo:hy_cursorPosition];
}

- (void)hy_moveCursorTo:(NSUInteger)index {
    // 光标就是长度为0
    if (index > self.text.length) {
        index = self.text.length;
    }
    NSRange range = NSMakeRange(index, 0);
    UITextRange *selectedRange = [self hy_textRangeFromRange:range];
    self.selectedTextRange = selectedRange;
}

- (void)hy_moveCursorToBeginPostion {
    [self hy_moveCursorTo:0];
}

- (void)hy_moveCursorToEndPostion {
    [self hy_moveCursorTo:self.text.length];
}

- (BOOL)hy_cursorIsAtBeginPostion {
    return self.hy_cursorPosition == 0;
}

- (BOOL)hy_cursorIsAtEndPostion {
    return self.hy_cursorPosition == self.text.length;
}
@end
