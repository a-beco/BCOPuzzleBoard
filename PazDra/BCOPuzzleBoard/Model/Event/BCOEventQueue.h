//
//  BCOEventQueue.h
//  PazDra
//
//  Created by 阿部耕平 on 2013/12/20.
//  Copyright (c) 2013年 Kohei Abe. All rights reserved.
//

#import <Foundation/Foundation.h>

@class BCOEvent;
@interface BCOEventQueue : NSObject

- (void)enqueueEvent:(BCOEvent *)event;
- (id)dequeueEvent;
- (void)clearAllEvents;
                      
@end
