#import <UIKit/UIKit.h>

typedef void (^MenuSwitchHandler)(BOOL isOn);
typedef void (^MenuSliderHandler)(CGFloat value);
typedef void (^MenuComboHandler)(NSInteger selectedIndex);
typedef void (^MenuTextFieldHandler)(NSString *text);
typedef void (^MenuButtonHandler)(void);

@interface MenuView : UIView <UITextFieldDelegate, UIGestureRecognizerDelegate, UIScrollViewDelegate>

@property (nonatomic, assign) CGPoint lastLocation;
@property (nonatomic, strong) NSMutableDictionary *switches;
@property (nonatomic, strong) NSMutableDictionary *sliders;
@property (nonatomic, strong) NSMutableDictionary *sliderLabels;
@property (nonatomic, strong) NSMutableDictionary *buttons;
@property (nonatomic, strong) NSMutableDictionary *textFields;
@property (nonatomic, strong) UIColor *accentColor;
@property (nonatomic, strong) UILabel *titleLabel;
@property (nonatomic, strong) UILabel *subtitleLabel;
@property (nonatomic, strong) UILabel *tabTitleLabel;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) UIVisualEffectView *blurEffectView;
@property (nonatomic, strong) UIScrollView *tabScrollView;
@property (nonatomic, strong) UIView *tabSidebar;
@property (nonatomic, strong) UIView *tabContainerView;
@property (nonatomic, strong) NSMutableArray *tabButtons;
@property (nonatomic, assign) NSInteger selectedTabIndex;
@property (nonatomic, assign) NSInteger currentCategoryCounter;
@property (nonatomic, strong) UIButton *telegramButton;
@property (nonatomic, strong) UIButton *discordButton;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIImageView *pillIcon;
@property (nonatomic, assign) BOOL canMove;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@property (nonatomic, copy) NSString *telegramURL;
@property (nonatomic, copy) NSString *discordURL;

+ (instancetype)menuWithFrame:(CGRect)frame;
- (void)makeDraggable;
- (void)canMove:(BOOL)enabled;
- (void)addFeatureSwitch:(NSString *)title description:(NSString *)desc isOn:(BOOL)isOn handler:(MenuSwitchHandler)handler;
- (void)addFeatureSwitch:(NSString *)title;
- (void)addSlider:(NSString *)title min:(CGFloat)min max:(CGFloat)max value:(CGFloat)value handler:(MenuSliderHandler)handler;
- (void)addSlider:(NSString *)title max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(void (^)(CGFloat value))handler;
- (void)addButton:(NSString *)title withHandler:(MenuButtonHandler)handler;
- (void)addComboSelector:(NSString *)title options:(NSArray *)options selectedIndex:(NSInteger)index handler:(MenuComboHandler)handler;
- (void)addTextField:(NSString *)title placeholder:(NSString *)placeholder handler:(MenuTextFieldHandler)handler;
- (void)addLabel:(NSString *)text;
- (void)addSectionTitle:(NSString *)title;
- (void)setTabIndex:(NSInteger)index;
- (void)addTab:(NSArray<NSString *> *)tabNames;
- (void)addThemeSlider:(NSString *)title property:(NSString *)prop max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(MenuSliderHandler)handler;
- (void)updateLayout;
- (void)setMenuAccentColor:(UIColor *)color;
- (void)setMenuGlassEffect:(BOOL)enabled;
- (void)setMenuCornerRadius:(CGFloat)radius;
- (void)setMenuBorderWidth:(CGFloat)width;
- (void)setMenuTitle:(NSString *)title;
- (void)setMenuSubtitle:(NSString *)subtitle;
- (void)setFooterText:(NSString *)text;
- (void)closeMenu;

@end
