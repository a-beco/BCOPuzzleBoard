//
//  BCOEventQueue.m
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/20.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import "BCOEventQueue.h"
#import "BCOEvent.h"

@implementation BCOEventQueue {
    NSMutableArray *_eventArray;
}

- (id)init
{
    self = [super init];
    if (self) {
        _eventArray = @[].mutableCopy;
    }
    return self;
}

- (void)enqueueEvent:(BCOEvent *)event
{
    if ([event isKindOfClass:[BCOEvent class]]) {
        [_eventArray addObject:event];
    }
}

- (id)dequeueEvent
{
    if ([_eventArray count] > 0) {
        BCOEvent *event = _eventArray[0];
        [_eventArray removeObjectAtIndex:0];
        return event;
    }
    return nil;
}

- (void)clearAllEvents
{
    _eventArray = @[].mutableCopy;
}

@end
