//
//  HYViewController.m
//  HYTextInput
//
//  Created by oceanfive on 11/12/2018.
//  Copyright (c) 2018 oceanfive. All rights reserved.
//

#import "HYViewController.h"
#import "HYTextView.h"

@interface HYViewController ()

@end

@implementation HYViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    HYTextView *textView = [[HYTextView alloc] init];
    textView.placeholder = @"描述一下您的问题，便于我们及时处理哦！";
    textView.font = [UIFont systemFontOfSize:12];
    textView.placeholderColor = [UIColor redColor];
    textView.backgroundColor = [UIColor lightGrayColor];
    textView.frame = CGRectMake(14, 200, CGRectGetWidth(self.view.bounds) - 28, 95);
    textView.textContainerInset = UIEdgeInsetsMake(12, 10, 12, 10);
    textView.normalTipsText = @"至少输入10个字";
    textView.focusTipsText = @"最多输入20个字";
    textView.normalTipsColor = [UIColor purpleColor];
    textView.focusTipsColor = [UIColor redColor];
    [self.view addSubview:textView];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
