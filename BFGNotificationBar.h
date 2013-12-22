//
//  BFGNotificationBar.h
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

#import <Foundation/Foundation.h>

typedef NS_ENUM(NSUInteger, BFGNotificationBarTheme) {
    BFGNotificationBarThemeBlack,
    BFGNotificationBarThemeGreen,
    BFGNotificationBarThemeRed,
    BFGNotificationBarThemeGray,
    BFGNotificationBarThemeBlue,
    BFGNotificationBarThemeYellow
};

@class BFGNotificationBar; // for the block

typedef void (^BFGNotificationBarGestureBlock)(BFGNotificationBar *bar);

@interface BFGNotificationBar : NSObject

@property (nonatomic, copy) NSString *message;
@property (nonatomic, strong) UIImage *backgroundImage;
@property (nonatomic, strong) UIImage *notificationImage;
@property (nonatomic, strong) UIView *targetView;
@property (nonatomic) CGFloat barHeight;
@property (nonatomic) CGFloat topOffset;
@property (nonatomic) CGFloat animationDuration;
@property (nonatomic) CGFloat dismissAfterInterval;
@property (nonatomic, strong) UIView *barGoesBehind;
@property (nonatomic) CGFloat barOpacity;
@property (nonatomic, strong) UIFont *font;
@property (nonatomic, strong) UIColor *textColor;
@property (nonatomic) NSTextAlignment textAlignment;
@property (nonatomic) BOOL tapToDismiss;
@property (nonatomic) BOOL gesturesEnabled;
@property (nonatomic, getter = isShowing) BOOL showing;
@property (nonatomic, strong) BFGNotificationBarGestureBlock tapAction;
@property (nonatomic, strong) BFGNotificationBarGestureBlock swipeUpAction;

+ (UIImage *)backgroundImageForTheme:(BFGNotificationBarTheme)theme;

- (void)show;

@end
