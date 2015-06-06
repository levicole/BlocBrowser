//
//  ViewController.m
//  BlocBrowser
//
//  Created by Levi Kennedy on 6/4/15.
//  Copyright (c) 2015 Levi Kennedy. All rights reserved.
//

#import "ViewController.h"
#import <WebKit/WebKit.h>
#import "AwesomeFloatingToolbar.h"

#define kWebBrowserBackString NSLocalizedString(@"Back", @"Back Command")
#define kWebBrowserForwardString NSLocalizedString(@"Forward", @"Forward Command")
#define kWebBrowserStopString NSLocalizedString(@"Stop", @"Stop Command")
#define kWebBrowserRefreshString NSLocalizedString(@"Refresh", @"Reload Command")

@interface ViewController () <WKNavigationDelegate, UITextFieldDelegate, AwesomeFloatingToolBarDelegate>

@property (nonatomic, strong) WKWebView *webView;
@property (nonatomic, strong) UITextField *textField;
@property (nonatomic, strong) AwesomeFloatingToolbar *awesomeToolbar;
@property (nonatomic, strong) UIActivityIndicatorView *activityIndicator;
@property (nonatomic, assign) NSUInteger frameCount;

@end

@implementation ViewController

#pragma mark - UIViewCrontroller
- (void)loadView {
    UIView *mainView = [UIView new];

    self.webView = [[WKWebView alloc] init];
    self.webView.navigationDelegate = self;
    
    self.textField = [[UITextField alloc] init];
    self.textField.keyboardType = UIKeyboardTypeURL;
    self.textField.returnKeyType = UIReturnKeyDone;
    self.textField.autocapitalizationType = UITextAutocapitalizationTypeNone;
    self.textField.placeholder = NSLocalizedString(@"Website URL", @"Placeholder text for web browser URL field");
    self.textField.backgroundColor = [UIColor colorWithWhite:220/255.0f alpha:1];
    self.textField.delegate = self;
    
    self.awesomeToolbar = [[AwesomeFloatingToolbar alloc] initWithFourTitles:@[kWebBrowserBackString, kWebBrowserForwardString, kWebBrowserStopString, kWebBrowserRefreshString]];
    self.awesomeToolbar.delegate = self;
    
    for(UIView *viewToAdd in @[self.webView, self.textField, self.awesomeToolbar]) {
        [mainView addSubview:viewToAdd];
    }
    
    self.view = mainView;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    
    self.activityIndicator = [[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:self.activityIndicator];
    // Do any additional setup after loading the view, typically from a nib.
}

- (void)viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
    
    static const CGFloat itemHeight = 50;
    CGFloat width = CGRectGetWidth(self.view.bounds);
    CGFloat browserHeight = CGRectGetHeight(self.view.bounds) - itemHeight;
    
    self.textField.frame = CGRectMake(0, 0, width, itemHeight);
    self.webView.frame = CGRectMake(0, CGRectGetMaxY(self.textField.frame), width, browserHeight);
    
    self.awesomeToolbar.frame = CGRectMake(width - 280, browserHeight - 10, 280, 60);
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField*)textField {
    [textField resignFirstResponder];
    
    NSString *URLString = textField.text;
    
    NSURL *URL = [NSURL URLWithString:URLString];
    
    if (!URL.scheme) {
        URL = [NSURL URLWithString:[NSString stringWithFormat:@"http://%@", URLString]];
    }
    
    if (URL) {
        NSURLRequest *request = [NSURLRequest requestWithURL:URL];
        [self.webView loadRequest:request];
    }
    return NO;
}

#pragma mark - WKNavigationDelegate

- (void) webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitles];
}

- (void) webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    [self updateButtonsAndTitles];
}

- (void)webView:(WKWebView *)webView didFailProvisionalNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    [self webView:webView didFailNavigation:navigation withError:error];
}

- (void)webView:(WKWebView *)webView didFailNavigation:(WKNavigation *)navigation withError:(NSError *)error {
    if (error.code != NSURLErrorCancelled) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:NSLocalizedString(@"Error", @"Error")
                                                                       message:[error localizedDescription]
                                                                preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *okAction = [UIAlertAction actionWithTitle:NSLocalizedString(@"OK", nil) style:UIAlertActionStyleCancel handler:nil];
        
        [alert addAction:okAction];
        [self presentViewController:alert animated:YES completion:nil];
    }
}

#pragma mark - AwesomeFloatingToolbarDelegate

- (void) floatingToolBar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWith:(NSString *)title {
    if ([title isEqualToString:kWebBrowserBackString]) {
        [self.webView goBack];
    } else if ([title isEqualToString:kWebBrowserForwardString]) {
        [self.webView goForward];
    } else if ([title isEqualToString:kWebBrowserStopString]) {
        [self.webView stopLoading];
    } else if ([title isEqualToString:kWebBrowserRefreshString]) {
        [self.webView reload];
    }
}

- (void) floatingToolBar:(AwesomeFloatingToolbar *)toolbar didTryToPanWithOffset:(CGPoint)offset {
    CGPoint startingPoint = toolbar.frame.origin;
    CGPoint newPoint = CGPointMake(startingPoint.x + offset.x, startingPoint.y + offset.y);
    
    CGRect potentialNewFrame = CGRectMake(newPoint.x, newPoint.y, CGRectGetWidth(toolbar.frame), CGRectGetHeight(toolbar.frame));

    if (CGRectContainsRect(self.view.bounds, potentialNewFrame)) {
        toolbar.frame = potentialNewFrame;
    }
    
}

#pragma mark - Miscelaneous
- (void) resetWebView {
    [self.webView removeFromSuperview];
    
    WKWebView *newWebView = [[WKWebView alloc] init];
    newWebView.navigationDelegate = self;
    [self.view addSubview:newWebView];
    
    self.webView = newWebView;
    
    self.textField.text = nil;
    [self updateButtonsAndTitles];
}

- (void) updateButtonsAndTitles {
    [self.activityIndicator startAnimating];
    
    NSString *webpageTitle = [self.webView.title copy];
    if ([webpageTitle length]) {
        self.title = webpageTitle;
    } else {
        self.title = self.webView.URL.absoluteString;
    }
    
    if (self.webView.isLoading) {
        [self.activityIndicator startAnimating];
    } else {
        [self.activityIndicator stopAnimating];
    }
    [self.awesomeToolbar setEnabled:[self.webView canGoBack] forButtonWithTitle:kWebBrowserBackString];
    [self.awesomeToolbar setEnabled:[self.webView canGoForward] forButtonWithTitle:kWebBrowserForwardString];
    [self.awesomeToolbar setEnabled:[self.webView isLoading] forButtonWithTitle:kWebBrowserStopString];
    [self.awesomeToolbar setEnabled:![self.webView isLoading] && self.webView.URL forButtonWithTitle:kWebBrowserRefreshString];
}

@end
