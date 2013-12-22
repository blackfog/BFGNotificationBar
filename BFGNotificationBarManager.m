//
//  BFGNotificationBarManager.m
//  Created by Craig Pearlman on 2013-12-21.
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

#import "BFGNotificationBarManager.h"
#import "BFGNotificationBar.h"

NSString * const BFGNotificationBarDidHideNotification = @"BFGNotificationBarDidHideNotification";

@interface BFGNotificationBarManager ()

@property (nonatomic, strong) NSMutableArray *queue;
@property (nonatomic, getter = isBarShowing) BOOL barShowing;

@end

@implementation BFGNotificationBarManager

@synthesize queue;
@synthesize barShowing;

#pragma mark - Singleton

+ (BFGNotificationBarManager *)sharedManager {
    static BFGNotificationBarManager *sharedInstance = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[self alloc] init];
    });
    
    return sharedInstance;
}

#pragma mark - Constructor

- (instancetype)init {
    self = [super init];
    
    if (self) {
        self.queue = [NSMutableArray array];
        self.barShowing = NO;
        
        [[NSNotificationCenter defaultCenter] addObserver:self
                                                 selector:@selector(barWasHidden:)
                                                     name:BFGNotificationBarDidHideNotification
                                                   object:nil];
    }
    
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:BFGNotificationBarDidHideNotification
                                                  object:nil];
}

#pragma mark - Public methods

- (void)addNotificationBar:(BFGNotificationBar *)bar {
    [self.queue addObject:bar];
    
    if ([self.queue count] == 1 && ![self isBarShowing]) {
        [self dequeueNext];
    }
}

#pragma mark - Private methods

- (void)dequeueNext {
    BFGNotificationBar *bar = [self.queue firstObject];
    
    if (bar) {
        [self.queue removeObjectAtIndex:0];
        self.barShowing = YES;
        
        dispatch_async(dispatch_get_main_queue(), ^{
            [bar show];
        });
    }
}

- (void)barWasHidden:(NSNotification *)notification {
    self.barShowing = NO;
    [self dequeueNext];
}

@end
