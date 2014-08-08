//
//  BFGNotificationBar.m
//  Created by Craig Pearlman on 2013-01-09.
//
// Copyright (c) 2013 Craig Pearlman
//
// Permission is hereby granted, free of charge, to any person obtaining a copy
// of this software and associated documentation files (the "Software"), to deal
// in the Software without restriction, including without limitation the rights
// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software is
// furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be included in
// all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
// THE SOFTWARE.
//

#import "BFGNotificationBar.h"
#import "BFGNotificationBarManager.h"

static NSString * const BFGBackgroundGreen = @"Green";
static NSString * const BFGBackgroundBlack = @"Black";
static NSString * const BFGBackgroundRed = @"BrightRed";
static NSString * const BFGBackgroundGray = @"Gray";
static NSString * const BFGBackgroundBlue = @"Blue";
static NSString * const BFGBackgroundYellow = @"Yellow";

static NSString * const BFGBarBoundryIdentifier = @"BarBoundary";

@interface BFGNotificationBar ()

@property (nonatomic, strong) UIView *bar;
@property (nonatomic, strong) UILabel *label;
@property (nonatomic) CGRect barFrameHidden;
@property (nonatomic) CGRect barFrameVisible;
@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, strong) UIDynamicAnimator *animator;
@property (nonatomic, strong) UIGravityBehavior *gravity;
@property (nonatomic, strong) UICollisionBehavior *collision;
@property (nonatomic, strong) UIDynamicItemBehavior *elasticity;
@property (nonatomic) BOOL finished;

@end

@implementation BFGNotificationBar

@synthesize message;
@synthesize backgroundImage;
@synthesize notificationImage;
@synthesize targetView;
@synthesize barHeight;
@synthesize topOffset;
@synthesize animationDuration;
@synthesize dismissAfterInterval;
@synthesize barGoesBehind;
@synthesize barOpacity;
@synthesize font;
@synthesize textColor;
@synthesize textAlignment;
@synthesize tapToDismiss;
@synthesize gesturesEnabled;
@synthesize showing;
@synthesize tapAction;
@synthesize swipeUpAction;
@synthesize bar;
@synthesize label;
@synthesize barFrameHidden;
@synthesize barFrameVisible;
@synthesize queue;
@synthesize animator;
@synthesize gravity;
@synthesize collision;
@synthesize elasticity;
@synthesize finished;

#pragma mark - Constructor

- (id)init {
    self = [super init];

    if (self) {
        self.message = @"Default notification bar message.";
        self.backgroundImage = [BFGNotificationBar backgroundImageForTheme:BFGNotificationBarThemeGray];
        self.notificationImage = nil;
        self.targetView = nil;
        self.barHeight = 40.0f;
        self.topOffset = 0.0f;
        self.animationDuration = 0.33f;
        self.dismissAfterInterval = 3.0f;
        self.tapToDismiss = NO;
        self.gesturesEnabled = NO;
        self.barGoesBehind = nil;
        self.barOpacity = 0.9f;
        self.font = [UIFont systemFontOfSize:17.0f];
        self.textColor = [UIColor whiteColor];
        self.textAlignment = NSTextAlignmentCenter;
        self.showing = NO;
        self.tapAction = nil;
        self.swipeUpAction = nil;
        self.finished = NO;
    }

    return self;
}

#pragma mark - Class methods

+ (UIImage *)backgroundImageForTheme:(BFGNotificationBarTheme)theme {
    switch (theme) {
        case BFGNotificationBarThemeRed:
            return [UIImage imageNamed:BFGBackgroundRed];
        case BFGNotificationBarThemeBlack:
            return [UIImage imageNamed:BFGBackgroundBlack];
        case BFGNotificationBarThemeGreen:
            return [UIImage imageNamed:BFGBackgroundGreen];
        case BFGNotificationBarThemeGray:
            return [UIImage imageNamed:BFGBackgroundGray];
        case BFGNotificationBarThemeBlue:
            return [UIImage imageNamed:BFGBackgroundBlue];
        case BFGNotificationBarThemeYellow:
            return [UIImage imageNamed:BFGBackgroundYellow];
    }
}

#pragma mark - NSOperation overrides (isFinished covered by the @property)

- (void)main {
    dispatch_async(dispatch_get_main_queue(), ^{
        [self prepareNotificationBar];
        [self slideIn];

        dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(self.dismissAfterInterval * NSEC_PER_SEC));
        dispatch_after(popTime, dispatch_get_main_queue(), ^(void){
            [self slideOut];
        });
    });
}

- (BOOL)isFinished {
    return self.finished;
}

#pragma mark - Private methods

// needed to send the KVO notifications for the NSOperation state
- (void)setFinishedState:(BOOL)newState {
    [self willChangeValueForKey:@"isFinished"];
    self.finished = newState;
    [self didChangeValueForKey:@"isFinished"];
}

- (void)prepareNotificationBar {
    [self calculateFrames];

    self.bar = [[UIView alloc] initWithFrame:self.barFrameHidden];

    UIImageView *barBackground = [[UIImageView alloc] init];
    barBackground.image = self.backgroundImage;
    barBackground.alpha = self.barOpacity;
    [self.bar addSubview:barBackground];
    barBackground.frame = self.barFrameVisible;

    self.label = [[UILabel alloc] init];
    self.label.text = self.message;
    self.label.textColor = self.textColor;
    self.label.backgroundColor = [UIColor clearColor];
    self.label.center = self.bar.center;
    self.label.textAlignment = self.textAlignment;
    self.label.font = self.font;
    [self.bar addSubview:self.label];
    self.label.frame = self.barFrameVisible;
    
    [self setTapGesture];
    [self setSwipeUpGesture];

    [self.targetView addSubview:self.bar];

    if (self.barGoesBehind == nil) {
        [targetView bringSubviewToFront:self.bar];
    }
    else {
        [targetView insertSubview:self.bar belowSubview:self.barGoesBehind];
    }
}

- (void)setTapGesture {
    if (self.gesturesEnabled) {
        if (self.tapAction || self.tapToDismiss) {
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(performTapAction)];
            [self.bar addGestureRecognizer:gesture];
        }
    }
}

- (void)performTapAction {
    if (self.tapAction) {
        self.tapAction(self);
        [self slideOut];
    }
    else if (self.tapToDismiss) {
        [self slideOut];
    }
}

- (void)setSwipeUpGesture {
    if (self.gesturesEnabled) {
        UISwipeGestureRecognizer *gesture = [[UISwipeGestureRecognizer alloc] initWithTarget:self action:@selector(performSwipeUpAction)];
        gesture.direction = UISwipeGestureRecognizerDirectionUp;
        [self.bar addGestureRecognizer:gesture];
    }
}

- (void)performSwipeUpAction {
    if (self.swipeUpAction) {
        self.swipeUpAction(self);
        [self slideOut];
    }
    else {
        [self slideOut];
    }
}

- (void)calculateFrames {
    CGFloat windowWidth = self.targetView.frame.size.width;

    self.barFrameHidden = CGRectMake(0.0f, 0.0f - self.barHeight - self.topOffset - 10.0f, windowWidth, self.barHeight);
    self.barFrameVisible = CGRectMake(0.0f, self.topOffset, windowWidth, self.barHeight);
}

- (void)slideIn {
    self.animator = [[UIDynamicAnimator alloc] initWithReferenceView:self.bar.superview];

    self.gravity = [[UIGravityBehavior alloc] initWithItems:@[self.bar]];
    [self.animator addBehavior:self.gravity];
    
    CGPoint collisionLeft = CGPointMake(self.barFrameVisible.origin.x, self.barFrameVisible.origin.y + self.barFrameVisible.size.height);
    CGPoint collisionRight = CGPointMake(self.barFrameVisible.origin.x + self.barFrameVisible.size.width, self.barFrameVisible.origin.y + self.barFrameVisible.size.height);
    
    self.collision = [[UICollisionBehavior alloc] initWithItems:@[self.bar]];
    [self.collision addBoundaryWithIdentifier:BFGBarBoundryIdentifier fromPoint:collisionLeft toPoint:collisionRight];
    [self.animator addBehavior:self.collision];
    
    self.elasticity = [[UIDynamicItemBehavior alloc] initWithItems:@[self.bar]];
    self.elasticity.elasticity = 0.5;
    [self.animator addBehavior:self.elasticity];
    
    self.showing = YES;
}

- (void)slideOut {
    [UIView animateWithDuration:self.animationDuration
                          delay:0.0
                        options:UIViewAnimationOptionCurveEaseOut
                     animations:^{
                        self.bar.frame = self.barFrameHidden;
                     }
                     completion:^void (BOOL allDone) {
                         if (allDone) {
                             self.showing = NO;
                             [self.bar removeFromSuperview];
                             [self setFinishedState:YES]; // use the KVO one!
                         }
                     }];
}

@end
