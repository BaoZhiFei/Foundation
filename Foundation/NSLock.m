#include <pthread.h>
#include <stdlib.h>

#import "NSLock.h"
#import "NSObject.h"
#import "NSString.h"

pthread_mutexattr_t __NSLockNMAttr;

// Timeout is from
// https://github.com/apple/swift-corelibs-foundation/blob/main/Sources/Foundation/NSLock.swift
// unlock method
typedef struct {
  pthread_mutex_t mutex;
  pthread_cond_t cond;
} Timeout;

// Private is from NSLock.h
typedef struct {
  pthread_mutex_t mutex;
  Timeout *timeout;
  NSString *name;
} Private;

@implementation NSLock

+ (instancetype)allocWithZone:(struct _NSZone *)zone {
  return NSAllocateObject(self, sizeof(Private), zone);
}

- (instancetype)init {
  id this = self;
  Private *ivars = (Private *)object_getIndexedIvars(self);
  if (pthread_mutex_init(&ivars->mutex, &__NSLockNMAttr) != 0) {
    [super dealloc];
    this = nil;
  } else {
    ivars->name = nil;
  }
  return this;
}

- (void)dealloc {
  Private *ivars = (Private *)object_getIndexedIvars(self);
  pthread_mutex_destroy(&ivars->mutex);
  Timeout *timeout = ivars->timeout;
  if (timeout) {
    pthread_cond_destroy(&timeout->cond);
    pthread_mutex_destroy(&timeout->mutex);
    free(timeout);
  }
  [ivars->name release];
  [super dealloc];
}

- (void)lock {
  Private *ivars = (Private *)object_getIndexedIvars(self);
  pthread_mutex_lock(&ivars->mutex);
}

- (BOOL)lockBeforeDate:(NSDate *)limit {
  return NO;
}

- (BOOL)tryLock {
  Private *ivars = (Private *)object_getIndexedIvars(self);
  return pthread_mutex_trylock(&ivars->mutex) != 0;
}

- (void)unlock {
  Private *ivars = (Private *)object_getIndexedIvars(self);
  pthread_mutex_unlock(&ivars->mutex);
  Timeout *timeout = ivars->timeout;
  if (timeout) {
    pthread_mutex_lock(&timeout->mutex);
    pthread_cond_broadcast(&timeout->cond);
    pthread_mutex_unlock(&timeout->mutex);
  }
}

- (NSString *)description {
  Private *ivars = (Private *)object_getIndexedIvars(self);
  return
      [NSString stringWithFormat:@"%@{name = %s%@%s}", [super description],
                                 ivars->name ? "'" : "",
                                 ivars->name ?: @"nil", ivars->name ? "'" : ""];
}

- (void)setName:(NSString *)aName {
  Private *ivars = (Private *)object_getIndexedIvars(self);
  NSString *name = ivars->name;
  if (name != aName) {
    [name release];
    ivars->name = [aName copy];
  }
}

- (NSString *)name {
  Private *ivars = (Private *)object_getIndexedIvars(self);
  return ivars->name;
}

@end

@implementation NSCondition

@end
