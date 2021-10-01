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
    id this = self;
    void *ivars = object_getIndexedIvars(self);
    if (pthread_mutex_init(ivars, &__NSLockNMAttr) != 0) {
        [super dealloc];
        this = nil;
    } else {
        // 0x48 is lock name
        *((int64_t *)(ivars + 0x48)) = 0;
    }
    return this;
}

- (void)dealloc {
    [super dealloc];
}

- (void)lock {
    pthread_mutex_lock((pthread_mutex_t *)object_getIndexedIvars(self));
}

- (BOOL)lockBeforeDate:(NSDate *)limit {
    return NO;
}

- (BOOL)tryLock {
    return !pthread_mutex_trylock((pthread_mutex_t *)object_getIndexedIvars(self));
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
