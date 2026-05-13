#import "MenuView.h"
#import <objc/runtime.h>

@interface MenuView ()
@property (nonatomic, assign) CGFloat contentHeight;
@end

@implementation MenuView

// =========================================================================
// CONFIGURATION: สีตามรูปภาพ (ดำ-ทอง)
// =========================================================================
#define COLOR_BG_MAIN       [UIColor colorWithRed:0.12f green:0.08f blue:0.06f alpha:1.0] 
#define COLOR_BG_ROW        [UIColor colorWithRed:0.18f green:0.13f blue:0.10f alpha:1.0] 
#define COLOR_ACCENT_GOLD   [UIColor colorWithRed:1.00f green:0.71f blue:0.29f alpha:1.0] 
#define COLOR_TEXT_MAIN     [UIColor whiteColor]
#define COLOR_TEXT_DIM      [UIColor colorWithWhite:1.0 alpha:0.5]
#define COLOR_BORDER        [UIColor colorWithWhite:1.0 alpha:0.1]

+ (instancetype)menuWithFrame:(CGRect)frame {
    MenuView *menu = [[MenuView alloc] initWithFrame:frame];
    [menu setup];
    return menu;
}

- (void)setup {
    // Initialize dictionaries and arrays from .h
    self.switches = [NSMutableDictionary dictionary];
    self.sliders = [NSMutableDictionary dictionary];
    self.sliderLabels = [NSMutableDictionary dictionary];
    self.buttons = [NSMutableDictionary dictionary];
    self.textFields = [NSMutableDictionary dictionary];
    self.tabButtons = [NSMutableArray array];
    
    // Main Window Setup
    self.backgroundColor = COLOR_BG_MAIN;
    self.layer.cornerRadius = 30.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.5;
    self.layer.borderColor = [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.4].CGColor;
    self.accentColor = COLOR_ACCENT_GOLD;

    CGFloat sidebarWidth = 75;
    CGFloat headerHeight = 85;
    CGFloat contentStartX = sidebarWidth + 15;
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - contentStartX - 15;

    // --- Sidebar ---
    self.tabSidebar = [[UIView alloc] initWithFrame:CGRectMake(10, 10, sidebarWidth, CGRectGetHeight(self.bounds) - 20)];
    self.tabSidebar.backgroundColor = [COLOR_BG_MAIN colorWithAlphaComponent:0.6];
    self.tabSidebar.layer.cornerRadius = 22.0;
    [self addSubview:self.tabSidebar];

    self.tabScrollView = [[UIScrollView alloc] initWithFrame:self.tabSidebar.bounds];
    self.tabScrollView.showsVerticalScrollIndicator = NO;
    self.tabScrollView.delegate = self;
    [self.tabSidebar addSubview:self.tabScrollView];

    self.tabContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, 0)];
    [self.tabScrollView addSubview:self.tabContainerView];

    // --- Header Pill ---
    UIView *pillView = [[UIView alloc] initWithFrame:CGRectMake(contentStartX, 20, 170, 42)];
    pillView.backgroundColor = [COLOR_BG_ROW colorWithAlphaComponent:0.9];
    pillView.layer.cornerRadius = 21;
    pillView.layer.borderWidth = 1.0;
    pillView.layer.borderColor = [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.5].CGColor;
    [self addSubview:pillView];

    self.tabTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 170, 42)];
    self.tabTitleLabel.text = @"MENU";
    self.tabTitleLabel.textColor = COLOR_ACCENT_GOLD;
    self.tabTitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.tabTitleLabel.textAlignment = NSTextAlignmentCenter;
    [pillView addSubview:self.tabTitleLabel];

    // Close Button
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 55, 20, 35, 35);
    self.closeButton.backgroundColor = [COLOR_BG_ROW colorWithAlphaComponent:0.8];
    self.closeButton.layer.cornerRadius = 17.5;
    self.closeButton.layer.borderWidth = 1.0;
    self.closeButton.layer.borderColor = COLOR_BORDER.CGColor;
    [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];

    // --- Content Area ---
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(contentStartX, headerHeight, contentWidth, CGRectGetHeight(self.bounds) - headerHeight - 20)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    self.scrollView.delegate = self;
    [self addSubview:self.scrollView];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 0)];
    [self.scrollView addSubview:self.contentView];
}

// =========================================================================
// METHOD IMPLEMENTATIONS (ตาม .h)
// =========================================================================

- (void)addTab:(NSArray<NSString *> *)tabNames {
    CGFloat y = 15;
    CGFloat btnSize = 50;

    for (NSInteger i = 0; i < tabNames.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((75 - btnSize) / 2.0, y, btnSize, btnSize);
        btn.layer.cornerRadius = 15;
        btn.tag = i;
        
        if (@available(iOS 13.0, *)) {
            UIImage *img = [UIImage systemImageNamed:@"star.fill"];
            [btn setImage:img forState:UIControlStateNormal];
            btn.tintColor = COLOR_TEXT_DIM;
        } else {
            [btn setTitle:[NSString stringWithFormat:@"%ld", (long)i+1] forState:UIControlStateNormal];
        }
        
        [btn addTarget:self action:@selector(tabButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabScrollView addSubview:btn];
        [self.tabButtons addObject:btn];

        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 0)];
        container.hidden = (i != 0);
        [self.contentView addSubview:container];
        
        // We use a custom internal array to track containers since .h doesn't have it
        NSMutableArray *containers = objc_getAssociatedObject(self, "internalContainers");
        if (!containers) {
            containers = [NSMutableArray array];
            objc_setAssociatedObject(self, "internalContainers", containers, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
        [containers addObject:container];
        y += btnSize + 12;
    }
    self.tabScrollView.contentSize = CGSizeMake(75, y);
    [self setTabIndex:0];
}

- (void)setTabIndex:(NSInteger)index {
    self.selectedTabIndex = index;
    NSMutableArray *containers = objc_getAssociatedObject(self, "internalContainers");
    if (!containers || index >= containers.count) return;

    for (NSUInteger i = 0; i < self.tabButtons.count; i++) {
        UIButton *btn = self.tabButtons[i];
        BOOL selected = (i == index);
        btn.backgroundColor = selected ? [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.3] : [UIColor clearColor];
        btn.tintColor = selected ? COLOR_ACCENT_GOLD : COLOR_TEXT_DIM;
    }

    for (NSUInteger i = 0; i < containers.count; i++) {
      [(UIView *)containers[i] setHidden:(i != index)];
    }
}

- (void)addFeatureSwitch:(NSString *)title description:(NSString *)desc isOn:(BOOL)isOn handler:(MenuSwitchHandler)handler {
    CGFloat width = self.scrollView.frame.size.width;
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, (desc.length > 0) ? 70 : 55)];
    row.backgroundColor = COLOR_BG_ROW;
    row.layer.cornerRadius = 15;
    row.layer.borderWidth = 1.0;
    row.layer.borderColor = COLOR_BORDER.CGColor;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, width - 60, 20)];
    lbl.text = title;
    lbl.textColor = COLOR_TEXT_MAIN;
    lbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [row addSubview:lbl];

    if (desc.length > 0) {
        UILabel *dLabel = [[UILabel alloc] initWithFrame:CGRectMake(15, 32, width - 60, 20)];
        dLabel.text = desc;
        dLabel.textColor = COLOR_TEXT_DIM;
        dLabel.font = [UIFont systemFontOfSize:12];
        [row addSubview:dLabel];
    }

    UIButton *toggle = [UIButton buttonWithType:UIButtonTypeCustom];
    toggle.frame = CGRectMake(width - 40, (row.frame.size.height - 25) / 2, 25, 25);
    toggle.layer.cornerRadius = 12.5;
    toggle.layer.borderWidth = 2.0;
    
    if (isOn) {
        toggle.backgroundColor = COLOR_ACCENT_GOLD;
        toggle.layer.borderColor = COLOR_ACCENT_GOLD.CGColor;
    } else {
        toggle.backgroundColor = [UIColor clearColor];
        toggle.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    }

    objc_setAssociatedObject(toggle, "switchHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(toggle, "state", @(isOn), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [toggle addTarget:self action:@selector(customToggleTapped:) forControlEvents:UIControlEventTouchUpInside];
    [row addSubview:toggle];

    [self addControlView:row height:row.frame.size.height];
}

- (void)addFeatureSwitch:(NSString *)title {
    [self addFeatureSwitch:title description:@"" isOn:NO handler:nil];
}

- (void)addSlider:(NSString *)title min:(CGFloat)min max:(CGFloat)max value:(CGFloat)value handler:(MenuSliderHandler)handler {
    CGFloat width = self.scrollView.frame.size.width;
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 80)];
    row.backgroundColor = COLOR_BG_ROW;
    row.layer.cornerRadius = 15;
    row.layer.borderWidth = 1.0;
    row.layer.borderColor = COLOR_BORDER.CGColor;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, width - 80, 20)];
    lbl.text = title;
    lbl.textColor = COLOR_TEXT_MAIN;
    lbl.font = [UIFont systemFontOfSize:14 weight:UIFontWeightMedium];
    [row addSubview:lbl];

    UILabel *valLbl = [[UILabel alloc] initWithFrame:CGRectMake(width - 60, 12, 45, 20)];
    valLbl.text = [NSString stringWithFormat:@"%.1f", value];
    valLbl.textColor = COLOR_ACCENT_GOLD;
    valLbl.textAlignment = NSTextAlignmentRight;
    valLbl.font = [UIFont monospacedDigitSystemFontOfSize:14 weight:UIFontWeightBold];
    [row addSubview:valLbl];

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(15, 40, width - 30, 25)];
    slider.minimumValue = min;
    slider.maximumValue = max;
    slider.value = value;
    slider.minimumTrackTintColor = COLOR_ACCENT_GOLD;
    slider.maximumTrackTintColor = [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.3];
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(slider, "sliderHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(slider, "valLabel", valLbl, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [row addSubview:slider];

    [self addControlView:row height:80];
}

- (void)addSlider:(NSString *)title max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(void (^)(CGFloat value))handler {
    [self addSlider:title min:min max:max value:value handler:handler];
}

- (void)addButton:(NSString *)title withHandler:(MenuButtonHandler)handler {
    CGFloat width = self.scrollView.frame.size.width;
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(0, 0, width, 50);
    btn.backgroundColor = [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.8];
    [btn setTitle:title forState:UIControlStateNormal];
    [btn setTitleColor:COLOR_TEXT_MAIN forState:UIControlStateNormal];
    btn.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    btn.layer.cornerRadius = 15;
    objc_setAssociatedObject(btn, "btnHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [btn addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addControlView:btn height:50];
}

- (void)addComboSelector:(NSString *)title options:(NSArray *)options selectedIndex:(NSInteger)index handler:(MenuComboHandler)handler {
    CGFloat width = self.scrollView.frame.size.width;
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 70)];
    row.backgroundColor = COLOR_BG_ROW;
    row.layer.cornerRadius = 15;
    row.layer.borderWidth = 1.0;
    row.layer.borderColor = COLOR_BORDER.CGColor;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, width - 30, 20)];
    lbl.text = title;
    lbl.textColor = COLOR_TEXT_DIM;
    lbl.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [row addSubview:lbl];

    UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
    btn.frame = CGRectMake(15, 35, width - 30, 30);
    [btn setTitle:options[index] forState:UIControlStateNormal];
    [btn setTitleColor:COLOR_TEXT_MAIN forState:UIControlStateNormal];
    btn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    objc_setAssociatedObject(btn, "comboOptions", options, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(btn, "comboHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [btn addTarget:self action:@selector(comboTapped:) forControlEvents:UIControlEventTouchUpInside];
    [row addSubview:btn];

    [self addControlView:row height:70];
}

- (void)addTextField:(NSString *)title placeholder:(NSString *)placeholder handler:(MenuTextFieldHandler)handler {
    CGFloat width = self.scrollView.frame.size.width;
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 80)];
    row.backgroundColor = COLOR_BG_ROW;
    row.layer.cornerRadius = 15;
    row.layer.borderWidth = 1.0;
    row.layer.borderColor = COLOR_BORDER.CGColor;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 12, width - 30, 20)];
    lbl.text = title;
    lbl.textColor = COLOR_TEXT_DIM;
    lbl.font = [UIFont systemFontOfSize:13 weight:UIFontWeightMedium];
    [row addSubview:lbl];

    UITextField *tf = [[UITextField alloc] initWithFrame:CGRectMake(15, 35, width - 30, 30)];
    tf.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.3];
    tf.textColor = [UIColor whiteColor];
    tf.placeholder = placeholder;
    tf.layer.cornerRadius = 8;
    tf.borderStyle = UITextBorderStyleNone;
    tf.delegate = self;
    objc_setAssociatedObject(tf, "tfHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [tf addTarget:self action:@selector(textFieldEdited:) forControlEvents:UIControlEventEditingChanged];
    [row addSubview:tf];

    [self addControlView:row height:80];
}

- (void)addLabel:(NSString *)text {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 30)];
    lbl.text = text;
    lbl.textColor = COLOR_TEXT_MAIN;
    lbl.textAlignment = NSTextAlignmentCenter;
    [self addControlView:lbl height:30];
}

- (void)addSectionTitle:(NSString *)title {
    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 30)];
    lbl.text = [title uppercaseString];
    lbl.textColor = COLOR_TEXT_DIM;
    lbl.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    lbl.textAlignment = NSTextAlignmentLeft;
    [self addControlView:lbl height:30];
}

- (void)addThemeSlider:(NSString *)title property:(NSString *)prop max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(MenuSliderHandler)handler {
  #pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-retain-cycles"
[self addSlider:title min:min max:max value:value handler:^(CGFloat val) {
    if ([prop isEqualToString:@"corner"]) self.layer.cornerRadius = val;
}];
#pragma clang diagnostic pop

- (void)makeDraggable {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    self.panGesture.delegate = self;
    [self addGestureRecognizer:self.panGesture];
    self.canMove = YES;
}

- (void)canMove:(BOOL)enabled {
    self.canMove = enabled;
    if (self.panGesture) self.panGesture.enabled = enabled;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    if (!self.canMove) return;
    CGPoint translation = [gesture translationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self.superview];
    }
}

- (void)updateLayout {
    [self setNeedsLayout];
}

- (void)setMenuAccentColor:(UIColor *)color { self.accentColor = color; }
- (void)setMenuGlassEffect:(BOOL)enabled { /* Blur effect logic */ }
- (void)setMenuCornerRadius:(CGFloat)radius { self.layer.cornerRadius = radius; }
- (void)setMenuBorderWidth:(CGFloat)width { self.layer.borderWidth = width; }
- (void)setMenuTitle:(NSString *)title { self.tabTitleLabel.text = title; }
- (void)setMenuSubtitle:(NSString *)subtitle { /* logic */ }
- (void)setFooterText:(NSString *)text { /* logic */ }

- (void)closeMenu {
    [self removeFromSuperview];
}

// =========================================================================
// INTERNAL HELPERS
// =========================================================================

- (void)addControlView:(UIView *)view height:(CGFloat)height {
    NSMutableArray *containers = objc_getAssociatedObject(self, "internalContainers");
    if (!containers) return;
    
    UIView *container = containers[self.selectedTabIndex];
    view.frame = CGRectMake(0, self.contentHeight, CGRectGetWidth(self.scrollView.bounds), height);
    [container addSubview:view];

    self.contentHeight += height + 10;
    container.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), self.contentHeight);
    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), self.contentHeight);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), self.contentHeight);
}

- (void)tabButtonTapped:(UIButton *)sender {
    [self setTabIndex:sender.tag];
}

- (void)customToggleTapped:(UIButton *)sender {
    BOOL state = [objc_getAssociatedObject(sender, "state") boolValue];
    state = !state;
    objc_setAssociatedObject(sender, "state", @(state), OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [UIView animateWithDuration:0.2 animations:^{
        if (state) {
            sender.backgroundColor = COLOR_ACCENT_GOLD;
            sender.layer.borderColor = COLOR_ACCENT_GOLD.CGColor;
        } else {
            sender.backgroundColor = [UIColor clearColor];
            sender.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
        }
    }];

    MenuSwitchHandler handler = objc_getAssociatedObject(sender, "switchHandler");
    if (handler) handler(state);
}

- (void)sliderChanged:(UISlider *)sender {
    UILabel *valLbl = objc_getAssociatedObject(sender, "valLabel");
    if (valLbl) valLbl.text = [NSString stringWithFormat:@"%.1f", sender.value];
    MenuSliderHandler handler = objc_getAssociatedObject(sender, "sliderHandler");
    if (handler) handler(sender.value);
}

- (void)textFieldEdited:(UITextField *)sender {
    MenuTextFieldHandler handler = objc_getAssociatedObject(sender, "tfHandler");
    if (handler) handler(sender.text);
}

- (void)buttonTapped:(UIButton *)sender {
    MenuButtonHandler handler = objc_getAssociatedObject(sender, "btnHandler");
    if (handler) handler();
}

- (void)comboTapped:(UIButton *)sender {
    NSArray *options = objc_getAssociatedObject(sender, "comboOptions");
    MenuComboHandler handler = objc_getAssociatedObject(sender, "comboHandler");
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < options.count; i++) {
        [alert addAction:[UIAlertAction actionWithTitle:options[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [sender setTitle:options[i] forState:UIControlStateNormal];
            if (handler) handler(i);
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

@end
