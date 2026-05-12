#import <UIKit/UIKit.h>

@interface UIManager : NSObject

+ (instancetype)shared;
- (void)setupUI;
- (void)showMenu;
- (void)toggleMenu;
- (void)hideMenu;

@end
