//
//  ViewController.h
//  BlocBrowser
//
//  Created by Levi Kennedy on 6/4/15.
//  Copyright (c) 2015 Levi Kennedy. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ViewController : UIViewController

/**
 Resets the webview with a fresh on, erasing all history. Also updates the url field and tool buttons appropriately.
 **/
- (void) resetWebView;

@end

