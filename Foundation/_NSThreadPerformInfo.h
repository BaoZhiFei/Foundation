#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

@interface _NSThreadPerformInfo : NSObject

- (instancetype)initWithTarget:(id)target
                      selector:(SEL)aSelector
                      argument:(id)argument
                         modes:(NSArray<NSString *> *)modes
                          wait:(BOOL)wait;

- (void)signal:(int)state;

- (int)wait;

@end

NS_ASSUME_NONNULL_END
