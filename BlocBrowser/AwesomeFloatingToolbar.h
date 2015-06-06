//
//  AwesomeFloatingToolbar.h
//  BlocBrowser
//
//  Created by Levi Kennedy on 6/6/15.
//  Copyright (c) 2015 Levi Kennedy. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AwesomeFloatingToolbar;

@protocol AwesomeFloatingToolBarDelegate <NSObject>

@optional

- (void) floatingToolBar:(AwesomeFloatingToolbar *)toolbar didSelectButtonWith:(NSString *)title;

@end

@interface AwesomeFloatingToolbar : UIView
- (instancetype) initWithFourTitles:(NSArray *)titles;
- (void)setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title;

@property(nonatomic, weak) id <AwesomeFloatingToolBarDelegate> delegate;
@end
