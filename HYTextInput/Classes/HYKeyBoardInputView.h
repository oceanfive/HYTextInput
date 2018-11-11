//
//  HYKeyBoardInputView.h
//  HYFoundation
//
//  Created by ocean on 2018/8/10.
//  Copyright © 2018年 ocean. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@class HYKeyBoardInputView, HYAutoIncreasingTextView;

@protocol HYKeyBoardInputViewDelegate <NSObject>

@optional

/**
 键盘将要显示

 @param keyboardInputView HYKeyBoardInputView
 @param userInfo 键盘通知携带的参数信息, noti.userInfo
 */
- (void)hy_keyboardWillShow:(HYKeyBoardInputView *)keyboardInputView userInfo:(NSDictionary *)userInfo;

/**
 键盘将要隐藏

 @param keyboardInputView HYKeyBoardInputView
 @param userInfo 键盘通知携带的参数信息, noti.userInfo
 */
- (void)hy_keyboardWillHide:(HYKeyBoardInputView *)keyboardInputView userInfo:(NSDictionary *)userInfo;

/**
 键盘将要改变位置

 @param keyboardInputView HYKeyBoardInputView
 @param userInfo 键盘通知携带的参数信息, noti.userInfo
 */
- (void)hy_keyboardWillChangeFrame:(HYKeyBoardInputView *)keyboardInputView userInfo:(NSDictionary *)userInfo;

@end

@interface HYKeyBoardInputView : UIView

/**
 初始化方法，使用的是 HYAutoIncreasingTextView 作为 accessoryView，可以使用下面的属性 inputTextView 获取

 @param frame frame，一定要设置，这个作为最开始的位置
 @return HYKeyBoardInputView
 
 使用例子:
 
 CGRect frame = self.view.bounds;
 frame.origin.y += frame.size.height;
 frame.size.height = 55;
 HYKeyBoardInputView *keyboardInputView = [[HYKeyBoardInputView alloc] initWithFrame:frame];
 keyboardInputView.delegate = self;
 [self.view addSubview:keyboardInputView];
 self.keyboardInputView = keyboardInputView;
 
 */
- (instancetype)initWithFrame:(CGRect)frame;

/**
 初始化方法，使用的是 accessoryView 作为 accessoryView，可以使用 accessoryView 获取

 @param frame frame，一定要设置，这个作为最开始的位置
 @param accessoryView accessoryView
 @return HYKeyBoardInputView
 
 使用示例:
 
 CGRect frame = self.view.bounds;
 frame.origin.y += frame.size.height;
 frame.size.height = 55;
 
 UIView *customView = [[UIView alloc] init];
 customView.frame = frame;
 customView.backgroundColor = [UIColor orangeColor];
 
 UITextField *yTextField = [[UITextField alloc] init];
 yTextField.delegate = self;
 yTextField.frame = customView.bounds;
 yTextField.placeholder = @"我是占位字符哦~";
 [customView addSubview:yTextField];
 
 HYKeyBoardInputView *keyboardInputView = [[HYKeyBoardInputView alloc] initWithFrame:frame accessoryView:customView];
 keyboardInputView.delegate = self;
 [self.view addSubview:keyboardInputView];
 self.keyboardInputView = keyboardInputView;
 
 */
- (instancetype)initWithFrame:(CGRect)frame accessoryView:(nullable __kindof UIView *)accessoryView;

/// 自定义的view
@property (nonatomic, strong) __kindof UIView * accessoryView;
/// 默认的输入框textview
@property (nonatomic, strong) HYAutoIncreasingTextView *inputTextView;

/// 代理
@property (nonatomic, weak, nullable) id<HYKeyBoardInputViewDelegate> delegate;

/// 弹出键盘，如果是自定义accessoryView的话，会遍历子控件，找到第一个可以成为响应者的对象
- (void)hy_becomeFirstResponder;
/// 隐藏键盘
- (void)hy_resignFirstResponder;

/**
 是否可用，默认是`YES`;
 push/present 下一个 controller ，如果也有键盘输入，会干扰位置
 使用:
 
 - (void)viewWillAppear:(BOOL)animated {
 [super viewWillAppear:YES];
 self.commentInputView.responderEnabled = YES;
 }
 
 - (void)viewWillDisappear:(BOOL)animated {
 [super viewWillDisappear:YES];
 [self.commentInputView mh_resignFirstResponder];
 self.commentInputView.responderEnabled = NO;
 }
 */
@property (nonatomic, assign) BOOL responderEnabled;

/// 输入的内容，针对默认的 accessoryView(HYAutoIncreasingTextView) 使用
@property (nonatomic, copy) NSString *inputText;

/// 清空输入的内容，针对默认的 accessoryView(HYAutoIncreasingTextView) 使用
- (void)clearInputText;

@end

NS_ASSUME_NONNULL_END

