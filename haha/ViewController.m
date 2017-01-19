//
//  ViewController.m
//  haha
//
//  Created by jiang on 17/1/19.
//  Copyright © 2017年 com.meiniucn. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>

@interface ViewController ()<WKScriptMessageHandler>

@property (nonatomic, strong) WKWebView *webView;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // 设置偏好设置
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    // 默认为0
    config.preferences.minimumFontSize = 10;
    //是否支持JavaScript
    config.preferences.javaScriptEnabled = YES;
    //不通过用户交互，是否可以打开窗口
    config.preferences.javaScriptCanOpenWindowsAutomatically = NO;
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.bounds.size.width, self.view.bounds.size.height/2) configuration:config];
    [self.view addSubview:self.webView];

    
    NSString *filePath = [[NSBundle mainBundle] pathForResource:@"index" ofType:@"html"];
    NSURL *baseURL = [[NSBundle mainBundle] bundleURL];
    [self.webView loadHTMLString:[NSString stringWithContentsOfFile:filePath encoding:NSUTF8StringEncoding error:nil] baseURL:baseURL];
    
    WKUserContentController *userCC = config.userContentController;
    //JS调用OC 添加处理脚本
    [userCC addScriptMessageHandler:self name:@"showMobile"];
    [userCC addScriptMessageHandler:self name:@"showName"];
    [userCC addScriptMessageHandler:self name:@"showSendMsg"];
    
}

#pragma mark - WKScriptMessageHandler

- (void)userContentController:(WKUserContentController *)userContentController didReceiveScriptMessage:(WKScriptMessage *)message {
    NSLog(@"%@",NSStringFromSelector(_cmd));
    NSLog(@"%@",message.body);
    
    if ([message.name isEqualToString:@"showMobile"]) {
        [self showMsg:@"没有参数"];
    }
    
    if ([message.name isEqualToString:@"showName"]) {
        NSString *info = [NSString stringWithFormat:@"%@",message.body];
        [self showMsg:info];
    }
    
    if ([message.name isEqualToString:@"showSendMsg"]) {
        NSArray *array = message.body;
        NSString *info = [NSString stringWithFormat:@"有两个参数: %@, %@ !!",array.firstObject,array.lastObject];
        [self showMsg:info];
    }
}

- (void)showMsg:(NSString *)msg {
    [[[UIAlertView alloc] initWithTitle:nil message:msg delegate:nil cancelButtonTitle:nil otherButtonTitles:@"OK", nil] show];
}


//网页加载完成之后调用JS代码才会执行，因为这个时候html页面已经注入到webView中并且可以响应到对应方法

//不带参数
- (IBAction)NOParameter:(id)sender {
    [self.webView evaluateJavaScript:@"alertMobile()" completionHandler:^(id _Nullable response, NSError * _Nullable error) {
        //JS 返回结果
        NSLog(@"%@ %@",response,error);
    }];

    
}
//一个参数
- (IBAction)oneParameter:(id)sender {
    /*
     *alertName('奥特们打小怪兽')
     *alertName JS方法名
     *奥特们打小怪兽 带的参数
     */
    [self.webView evaluateJavaScript:@"alertName('奥特们打小怪兽')" completionHandler:nil];
}
//两个参数
- (IBAction)twoParameter:(id)sender {
    /*
     *alertSendMsg('我是参数1','我是参数2')
     *alertSendMsg JS方法名
     *我是参数1 带的参数
     *我是参数2
     */
    [self.webView evaluateJavaScript:@"alertSendMsg('我是参数1','我是参数2')" completionHandler:nil];
}


-(void)removeAllScriptMsgHandle{
    WKUserContentController *controller = self.webView.configuration.userContentController;
    [controller removeScriptMessageHandlerForName:@"showMobile"];
    [controller removeScriptMessageHandlerForName:@"showName"];
    [controller removeScriptMessageHandlerForName:@"showSendMsg"];
}





@end
