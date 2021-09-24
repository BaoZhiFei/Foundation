#include <stdatomic.h>

#import "_NSThreadPerformInfo.h"
#import "NSBlock.h"

@interface _NSThreadPerformInfo ()
{
    id _target;
    SEL _selector;
    id _argument;
    NSMutableArray<NSString *> *_modes;
    NSCondition *_waiter;
    atomic_int _state;
}

@end

@implementation _NSThreadPerformInfo

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)aSelector
                      argument:(id)argument
                         modes:(NSArray<NSString *> *)modes
                          wait:(BOOL)wait {
    self = [super init];
    atomic_exchange(&_state, 0);
    _target = [target isKindOfClass:[NSBlock class]] ? [target copy] : [target retain];
    _selector = aSelector;
    _argument = [argument isKindOfClass:[NSBlock class]] ? [argument copy] : [argument retain];
    NSMutableArray<NSString *> *mutableModes = [[NSMutableArray alloc] init];
    for (NSString *mode in modes) {
        if ([mode isEqual:@"NSDefaultRunLoopMode"]) {
            mode = (NSString *)kCFRunLoopDefaultMode;
        }
        [mutableModes addObject:mode];
    }
    _modes = [mutableModes copy];
    if (wait) {
        _waiter = [[NSCondition alloc] init];
    }
    [mutableModes release];
    return self;
}

- (void)signal:(int)state {
    [_waiter lock];
    atomic_exchange(&_state, state);
    [_waiter unlock];
}

- (int)wait {
    int state;
    [_waiter lock];
    while (!_state) {
        [_waiter wait];
    }
    state = _state;
    [_waiter unlock];
    return state;
}

- (void)dealloc {
    [_target release];
    [_argument release];
    [_modes release];
    [_waiter release];
    [super dealloc];
}

@end
