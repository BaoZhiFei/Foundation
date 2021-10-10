#include <pthread/pthread.h>

#import "NSLock.h"
#import "NSString.h"
#import "NSObject.h"

pthread_mutexattr_t __NSLockNMAttr;

typedef struct {
    pthread_mutex_t mutex;
    void *unknown;
    NSString *name;
} NSLockIndexedIvars;

@implementation NSLock

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return NSAllocateObject(self, sizeof(NSLockIndexedIvars), zone);
}

- (instancetype)init {
    id this = self;
    NSLockIndexedIvars *ivars = (NSLockIndexedIvars *)object_getIndexedIvars(self);
    if (pthread_mutex_init(&ivars->mutex, &__NSLockNMAttr) != 0) {
        [super dealloc];
        this = nil;
    } else {
        ivars->name = nil;
    }
    return this;
}

- (void)dealloc {
    [super dealloc];
}

- (void)lock {
    NSLockIndexedIvars *ivars = (NSLockIndexedIvars *)object_getIndexedIvars(self);
    pthread_mutex_lock(&ivars->mutex);
}

- (BOOL)lockBeforeDate:(NSDate *)limit {
    return NO;
}

- (BOOL)tryLock {
    NSLockIndexedIvars *ivars = (NSLockIndexedIvars *)object_getIndexedIvars(self);
    return pthread_mutex_trylock(&ivars->mutex) != 0;
}

- (void)unlock {
    
}

- (NSString *)description {
    return nil;
}

- (void)setName:(NSString *)aName {
    NSLockIndexedIvars *ivars = (NSLockIndexedIvars *)object_getIndexedIvars(self);
    NSString *name = ivars->name;
    if (name != aName) {
        [name release];
        ivars->name = [aName copy];
    }
}

- (NSString *)name {
    NSLockIndexedIvars *ivars = (NSLockIndexedIvars *)object_getIndexedIvars(self);
    return ivars->name;
}

@end

@implementation NSCondition

@end
