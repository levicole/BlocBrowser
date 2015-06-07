//
//  AwesomeFloatingToolbar.m
//  BlocBrowser
//
//  Created by Levi Kennedy on 6/6/15.
//  Copyright (c) 2015 Levi Kennedy. All rights reserved.
//

#import "AwesomeFloatingToolbar.h"

@interface AwesomeFloatingToolbar()

@property (nonatomic, strong) NSArray *currentTitles;
@property (nonatomic, strong) NSArray *colors;
@property (nonatomic, strong) NSArray *buttons;
@property (nonatomic, weak  ) UILabel *currentLabel;
@property (nonatomic, strong) UITapGestureRecognizer *tapGesture;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, strong) UILongPressGestureRecognizer *longPressGesture;
@property (nonatomic, strong) UIPinchGestureRecognizer *pinchGesture;

@end

@implementation AwesomeFloatingToolbar

- (instancetype) initWithFourTitles:(NSArray *)titles {
    self = [super init];
    if (self) {
        
        // Save the tiles, and set the 4 colors
        self.currentTitles = titles;
        self.colors = @[[UIColor colorWithRed:199/255.0 green:158/255.0 blue:203/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:105/255.0 blue:97/255.0  alpha:1],
                        [UIColor colorWithRed:222/255.0 green:164/255.0 blue:164/255.0 alpha:1],
                        [UIColor colorWithRed:255/255.0 green:179/255.0 blue:71/255.0  alpha:1]];
        
        NSMutableArray *buttonsArray = [[NSMutableArray alloc] init];
        
        //Make 4 labels
        
        for (NSString *currentTitle in self.currentTitles) {
            UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
            button.alpha = 0.25;
            button.enabled = NO;
            
            NSUInteger currentTitleIndex  = [self.currentTitles indexOfObject:currentTitle];
            NSString   *titleForThisLabel = [self.currentTitles objectAtIndex:currentTitleIndex];
            UIColor    *colorForThisLabel = [self.colors objectAtIndex:currentTitleIndex];
            
            button.titleLabel.font            = [UIFont systemFontOfSize:10.0];
            [button setTitle:titleForThisLabel forState:UIControlStateNormal];
            button.backgroundColor = colorForThisLabel;
            [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
            
            [buttonsArray addObject:button];
        }
        
        self.buttons = buttonsArray;

        for (UIButton *thisButton in self.buttons) {
            [self addSubview:thisButton];
            [thisButton addTarget:self action:@selector(buttonClicked:) forControlEvents:UIControlEventTouchUpInside];
        }
        
        self.origin = CGPointZero;
        self.width  = 280;
        self.height = 60;
        
        
        self.tapGesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapFired:)];
        [self addGestureRecognizer:self.tapGesture];
        
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(panFired:)];
        [self addGestureRecognizer:self.panGesture];
        
        self.longPressGesture = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressFired:)];
        [self addGestureRecognizer:self.longPressGesture];
        
        self.pinchGesture = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(pinchFired:)];
        [self addGestureRecognizer:self.pinchGesture];
    }
    return self;
}

- (void) layoutSubviews {
    for (UIButton *thisButton in self.buttons) {
        NSUInteger currentButtonIndex = [self.buttons indexOfObject:thisButton];
        CGFloat buttonHeight = CGRectGetHeight(self.bounds)/2;
        CGFloat buttonWidth  = CGRectGetWidth(self.bounds)/2;
        CGFloat buttonX = 0;
        CGFloat buttonY = 0;
        
        if (currentButtonIndex < 2) {
            buttonY = 0;
        } else {
            buttonY = CGRectGetHeight(self.bounds)/2;
        }
        
        if (currentButtonIndex % 2 == 0) {
            buttonX = 0;
        } else {
            buttonX = CGRectGetWidth(self.bounds)/2;
        }
        
        thisButton.frame = CGRectMake(buttonX, buttonY, buttonWidth, buttonHeight);
    }
}

#pragma mark - Touch Handling
-(void) tapFired:(UITapGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        CGPoint location = [recognizer locationInView:self];
        UIView *tappedView = [self hitTest:location withEvent:nil];
        
        if ([self.buttons containsObject:tappedView]) {
            if ([self.delegate respondsToSelector:@selector(floatingToolBar:didSelectButtonWith:)]) {
                [self.delegate floatingToolBar:self didSelectButtonWith:[((UIButton *)tappedView) currentTitle]];
            }
        }
    }
}

- (void) panFired:(UIPanGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateChanged) {
        CGPoint translation = [recognizer translationInView:self];
        
        NSLog(@"New translation: %@", NSStringFromCGPoint(translation));
        
        if ([self.delegate respondsToSelector:@selector(floatingToolBar:didTryToPanWithOffset:)]) {
            [self.delegate floatingToolBar:self didTryToPanWithOffset:translation];
        }
        [recognizer setTranslation:CGPointZero inView:self];
    }
}

- (void) longPressFired:(UILongPressGestureRecognizer *)recognizer {
    if (recognizer.state == UIGestureRecognizerStateRecognized) {
        // get last color
        UIColor *lastColor = [self.colors lastObject];
        // get the rest of the colors excluding colors.length - 2
        NSRange lengthMinusTwo;
        lengthMinusTwo.location = 0;
        lengthMinusTwo.length = [self.colors count] - 1;
        // create new array with last color first, and the rest
        NSArray *theRest   = [self.colors subarrayWithRange:lengthMinusTwo];
        NSArray *newColors = [@[lastColor] arrayByAddingObjectsFromArray:theRest];
        self.colors = newColors;
        // cycle through the array and set the labels colors
        for (UIButton *button in self.buttons) {
            NSUInteger currentIndexOfLabel = [self.buttons indexOfObject:button];
            if (currentIndexOfLabel != NSNotFound) {
                UIColor *currentColor = [self.colors objectAtIndex:currentIndexOfLabel];
                button.backgroundColor = currentColor;
            }
        }
    }
}

- (void) pinchFired:(UIPinchGestureRecognizer *)recognizer {
    if ([self.delegate respondsToSelector:@selector(floatingToolBar:didTryToPinchWithScale:)]) {
        [self.delegate floatingToolBar:self didTryToPinchWithScale:recognizer.scale];
    }
}

- (UILabel *) labelFromTouches:(NSSet *)touches withEvent:(UIEvent *)event {
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self];
    UIView  *subview = [self hitTest:location withEvent:event];
    
    if ([subview isKindOfClass:[UILabel class]]) {
        return (UILabel *)subview;
    } else {
        return nil;
    }
}

- (void) buttonClicked:(UIButton *)button {
    if ([self.delegate respondsToSelector:@selector(floatingToolBar:didSelectButtonWith:)]) {
        [self.delegate floatingToolBar:self didSelectButtonWith:[button currentTitle]];
    }
}

#pragma mark - Button Enabling

- (void) setEnabled:(BOOL)enabled forButtonWithTitle:(NSString *)title {
    NSUInteger index = [self.currentTitles indexOfObject:title];
    
    if (index != NSNotFound) {
        UIButton *button = [self.buttons objectAtIndex:index];
        button.enabled = enabled;
        button.alpha = enabled ? 1.0 : 0.25;
    }
}

@end
