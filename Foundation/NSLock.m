#include <pthread/pthread.h>

#import "NSLock.h"
#import "NSString.h"
#import "NSObject.h"

pthread_mutexattr_t __NSLockNMAttr;

@implementation NSLock

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return NSAllocateObject(self, 0x50, zone);
}

- (instancetype)init {
    pthread_mutex_init(object_getIndexedIvars(self), &__NSLockNMAttr);
    return nil;
}

- (void)dealloc {
    [super dealloc];
}

- (void)lock {
    
}

- (BOOL)lockBeforeDate:(NSDate *)limit {
    return NO;
}

- (BOOL)tryLock {
    return NO;
}

- (void)unlock {
    
}

- (NSString *)description {
    return nil;
}

- (void)setName:(NSString *)name {
    
}

- (NSString *)name {
    return nil;
}

@end

@implementation NSCondition

@end
