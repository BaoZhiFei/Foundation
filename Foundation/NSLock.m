#include <pthread.h>
#include <stdlib.h>

#import "NSLock.h"
#import "NSString.h"
#import "NSObject.h"

pthread_mutexattr_t __NSLockNMAttr;

// Timeout is from https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/NSLock.swift unlock method
typedef struct {
    pthread_mutex_t mutex;
    pthread_cond_t cond;
} NSLockIndexedIvarsTimeout;

// Private is from NSLock.h
typedef struct {
    pthread_mutex_t mutex;
    NSLockIndexedIvarsTimeout *timeout;
    NSString *name;
} NSLockIndexedIvarsPrivate;

@implementation NSLock

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
    return NSAllocateObject(self, sizeof(NSLockIndexedIvarsPrivate), zone);
}

- (instancetype)init {
    id this = self;
    NSLockIndexedIvarsPrivate *ivars = (NSLockIndexedIvarsPrivate *)object_getIndexedIvars(self);
    if (pthread_mutex_init(&ivars->mutex, &__NSLockNMAttr) != 0) {
        [super dealloc];
        this = nil;
    } else {
        ivars->name = nil;
    }
    return this;
}

- (void)dealloc {
    NSLockIndexedIvarsPrivate *ivars = (NSLockIndexedIvarsPrivate *)object_getIndexedIvars(self);
    pthread_mutex_destroy(&ivars->mutex);
    NSLockIndexedIvarsTimeout *timeout = ivars->timeout;
    if (timeout) {
        pthread_cond_destroy(&timeout->cond);
        pthread_mutex_destroy(&timeout->mutex);
        free(timeout);
    }
    [ivars->name release];
    [super dealloc];
}

- (void)lock {
    NSLockIndexedIvarsPrivate *ivars = (NSLockIndexedIvarsPrivate *)object_getIndexedIvars(self);
    pthread_mutex_lock(&ivars->mutex);
}

- (BOOL)lockBeforeDate:(NSDate *)limit {
    return NO;
}

- (BOOL)tryLock {
    NSLockIndexedIvarsPrivate *ivars = (NSLockIndexedIvarsPrivate *)object_getIndexedIvars(self);
    return pthread_mutex_trylock(&ivars->mutex) != 0;
}

- (void)unlock {
    NSLockIndexedIvarsPrivate *ivars = (NSLockIndexedIvarsPrivate *)object_getIndexedIvars(self);
    pthread_mutex_unlock(&ivars->mutex);
    NSLockIndexedIvarsTimeout *timeout = ivars->timeout;
    if (timeout) {
        pthread_mutex_lock(&timeout->mutex);
        pthread_cond_broadcast(&timeout->cond);
        pthread_mutex_unlock(&timeout->mutex);
    }
}

- (NSString *)description {
    return nil;
}

- (void)setName:(NSString *)aName {
    NSLockIndexedIvarsPrivate *ivars = (NSLockIndexedIvarsPrivate *)object_getIndexedIvars(self);
    NSString *name = ivars->name;
    if (name != aName) {
        [name release];
        ivars->name = [aName copy];
    }
}

- (NSString *)name {
    NSLockIndexedIvarsPrivate *ivars = (NSLockIndexedIvarsPrivate *)object_getIndexedIvars(self);
    return ivars->name;
}

@end

@implementation NSCondition

@end
