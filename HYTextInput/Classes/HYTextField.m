//
//  HYTextField.m
//  HYFoundation
//
//  Created by ocean on 2018/8/8.
//  Copyright © 2018年 ocean. All rights reserved.
//

#import "HYTextField.h"

@implementation HYTextField

@synthesize hy_maxInputLength = _hy_maxInputLength;
@synthesize hy_truncatedWhenOverMaxInputLength = _hy_truncatedWhenOverMaxInputLength;

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        _hy_truncatedWhenOverMaxInputLength = YES;
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(_hy_textDidChanged) name:UITextFieldTextDidChangeNotification object:self];
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:self];
}

- (void)_hy_textDidChanged {
    if (![self hy_hasMarkedText]) {
        // 最大输入长度的限制
        if (self.hy_maxInputLength > 0 &&
            self.text.length > self.hy_maxInputLength) {
            if (self.hy_delegate && [self.hy_delegate respondsToSelector:@selector(hy_textFieldDidOverMaxInputLength:maxInputLength:)]) {
                [self.hy_delegate hy_textFieldDidOverMaxInputLength:self maxInputLength:self.hy_maxInputLength];
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
    if (self.hy_delegate && [self.hy_delegate respondsToSelector:@selector(hy_textFieldDidChangeHandler:)]) {
        NSString *handledString = [self.hy_delegate hy_textFieldDidChangeHandler:self];
        if (handledString) {
            self.text = handledString;
        }
    }
    // 通知代理
    if (self.hy_delegate && [self.hy_delegate respondsToSelector:@selector(hy_textFieldDidChange:)]) {
        [self.hy_delegate hy_textFieldDidChange:self];
    }
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
