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

@interface BFGNotificationBarManager ()

@property (nonatomic, strong) NSMutableDictionary *queues;
@property (nonatomic, strong) NSException *unknownQueueException;

@end

@implementation BFGNotificationBarManager

@synthesize queues;
@synthesize unknownQueueException;

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
        self.queues = [NSMutableDictionary dictionary];

        self.unknownQueueException = [NSException exceptionWithName:@"BFGUnknownQueueException"
                                                             reason:@"The requested queue does not exist"
                                                           userInfo:nil];
    }
    
    return self;
}

#pragma mark - Public methods

- (BFGNotificationBarQueueHandle *)createQueue {
    BFGNotificationBarQueueHandle *handle = [NSUUID UUID];
    NSString *queueName = [NSString stringWithFormat:@"com.blackfoggames.NotificationQueue.%@", [handle UUIDString]];

    NSOperationQueue *queue = [[NSOperationQueue alloc] init];
    queue.name = queueName;
    queue.maxConcurrentOperationCount = 1;

    [self.queues setObject:queue forKey:handle];

    return handle;
}

- (void)addNotificationBar:(BFGNotificationBar *)bar toQueue:(BFGNotificationBarQueueHandle *)handle {
    NSOperationQueue *queue = [self.queues objectForKey:handle];

    if (queue) {
        [queue addOperation:bar];
    }
    else {
        @throw self.unknownQueueException;
    }
}

- (void)clearQueue:(BFGNotificationBarQueueHandle *)handle {
    NSOperationQueue *queue = [self.queues objectForKey:handle];

    if (queue) {
        [queue cancelAllOperations];
    }
    else {
        @throw self.unknownQueueException;
    }
}

- (void)pauseQueue:(BFGNotificationBarQueueHandle *)handle {
    NSOperationQueue *queue = [self.queues objectForKey:handle];

    if (queue) {
        if (!queue.isSuspended) {
            [queue setSuspended:YES];
        }
    }
    else {
        @throw self.unknownQueueException;
    }
}

- (void)restartQueue:(BFGNotificationBarQueueHandle *)handle {
    NSOperationQueue *queue = [self.queues objectForKey:handle];

    if (queue) {
        if (queue.isSuspended) {
            [queue setSuspended:NO];
        }
    }
    else {
        @throw self.unknownQueueException;
    }
}

- (NSUInteger)countForQueue:(BFGNotificationBarQueueHandle *)handle {
    NSOperationQueue *queue = [self.queues objectForKey:handle];

    if (queue) {
        return queue.operationCount;
    }
    else {
        @throw self.unknownQueueException;
    }
}

- (void)removeQueue:(BFGNotificationBarQueueHandle *)handle {
    if ([self.queues objectForKey:handle]) {
        [self.queues removeObjectForKey:handle];
    }
    else {
        @throw self.unknownQueueException;
    }
}

#pragma mark - Private methods

// none

@end
