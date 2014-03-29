//
//  BCOTimer.m
//  PazDra
//
//  Created by 阿部耕平 on 2014/02/03.
//  Copyright (c) 2014年 Kohei Abe. All rights reserved.
//

#import "BCOTimer.h"

@interface BCOTimer ()

@property (nonatomic, strong) NSTimer *timer;
@property (nonatomic, readwrite, getter = isRunning) BOOL running;
@property (nonatomic, readwrite) NSTimeInterval interval;
@property (nonatomic, readwrite) NSTimeInterval runningTime;

@end

@implementation BCOTimer {
    NSTimeInterval _interval;
    NSInteger _countLimit;
    NSInteger _count;
}

- (id)initWithDelegate:(id<BCOTimerDelegate>)delegate
{
    self = [super init];
    if (self) {
        _delegate = delegate;
    }
    return self;
}

- (void)startTimerWithInterval:(NSTimeInterval)interval
                    runForTime:(NSTimeInterval)runningTime
{
    if (interval > runningTime) return;
    if (self.running) [self destroy];
    
    self.interval       = interval;
    self.runningTime    = runningTime;
    self.running        = YES;
    _countLimit = runningTime / interval;
    _count = 0;
    
    self.timer = [NSTimer scheduledTimerWithTimeInterval:interval
                                                  target:self
                                                selector:@selector(timer:)
                                                userInfo:nil
                                                 repeats:YES];
}

- (void)destroy
{
    if (_timer) {
        [_timer invalidate];
        _timer = nil;
    }
    self.running = NO;
}

- (void)timer:(NSTimer *)timer
{
    if ([_delegate respondsToSelector:@selector(timerDidFired:count:progressTime:)]) {
        [_delegate timerDidFired:self count:_count progressTime:(_count + 1) * _interval];
    }
    
    _count++;
    if (_count == _countLimit) {
        if ([_delegate respondsToSelector:@selector(timerDidEnd:)]) {
            [_delegate timerDidEnd:self];
        }
        [self destroy];
    }
}

@end
