#import <UIKit/UIKit.h>

@interface FloatingButton : UIButton

@property (nonatomic, assign) CGPoint lastLocation;
@property (nonatomic, copy) void (^onTap)(void);

+ (instancetype)buttonWithFrame:(CGRect)frame;
- (void)makeDraggable;

@end
