#import "MenuView.h"
#import <objc/runtime.h>

@interface MenuView ()
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, strong) UIView *pillView;
@property (nonatomic, strong) UILabel *tabTitleLabel;
@property (nonatomic, strong) UIButton *closeButton;
@property (nonatomic, strong) UIView *tabSidebar;
@property (nonatomic, strong) UIScrollView *tabScrollView;
@property (nonatomic, strong) UIView *tabContainerView;
@property (nonatomic, strong) UIScrollView *scrollView;
@property (nonatomic, strong) UIView *contentView;
@property (nonatomic, strong) NSMutableArray<UIButton *> *tabButtons;
@property (nonatomic, strong) NSMutableArray<UIView *> *tabContainers;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *tabHeights;
@property (nonatomic, strong) NSArray<NSString *> *tabTitles;
@property (nonatomic, assign) NSInteger currentTabIndex;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIPanGestureRecognizer *panGesture;
@end

@implementation MenuView

// =========================================================================
// CONFIGURATION: ปรับแต่งสีตรงนี้เพื่อให้เหมือนในรูปเป๊ะๆ
// =========================================================================
#define COLOR_BG_MAIN       [UIColor colorWithRed:0.12f green:0.08f blue:0.06f alpha:1.0] // ดำน้ำตาลเข้ม
#define COLOR_BG_ROW        [UIColor colorWithRed:0.18f green:0.13f blue:0.10f alpha:1.0] // แถบเมนู
#define COLOR_ACCENT_GOLD   [UIColor colorWithRed:1.00f green:0.71f blue:0.29f alpha:1.0] // สีทอง
#define COLOR_TEXT_MAIN     [UIColor whiteColor]
#define COLOR_TEXT_DIM      [UIColor colorWithWhite:1.0 alpha:0.5]
#define COLOR_BORDER        [UIColor colorWithWhite:1.0 alpha:0.1]

+ (instancetype)menuWithFrame:(CGRect)frame {
    MenuView *menu = [[MenuView alloc] initWithFrame:frame];
    [menu setup];
    return menu;
}

- (void)setup {
    // --- Main Window Setup ---
    self.backgroundColor = COLOR_BG_MAIN;
    self.layer.cornerRadius = 30.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.5;
    self.layer.borderColor = [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.4].CGColor;

    self.currentTabIndex = 0;
    self.tabButtons = [NSMutableArray array];
    self.tabContainers = [NSMutableArray array];
    self.tabHeights = [NSMutableArray array];

    CGFloat sidebarWidth = 75;
    CGFloat headerHeight = 85;
    CGFloat contentStartX = sidebarWidth + 15;
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - contentStartX - 15;

    // --- Sidebar (แถบไอคอนด้านซ้าย) ---
    self.tabSidebar = [[UIView alloc] initWithFrame:CGRectMake(10, 10, sidebarWidth, CGRectGetHeight(self.bounds) - 20)];
    self.tabSidebar.backgroundColor = [COLOR_BG_MAIN colorWithAlphaComponent:0.6];
    self.tabSidebar.layer.cornerRadius = 22.0;
    [self addSubview:self.tabSidebar];

    self.tabScrollView = [[UIScrollView alloc] initWithFrame:self.tabSidebar.bounds];
    self.tabScrollView.showsVerticalScrollIndicator = NO;
    [self.tabSidebar addSubview:self.tabScrollView];

    self.tabContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, 0)];
    [self.tabScrollView addSubview:self.tabContainerView];

    // --- Header Pill (ทรงแคปซูลตามรูป) ---
    self.pillView = [[UIView alloc] initWithFrame:CGRectMake(contentStartX, 20, 170, 42)];
    self.pillView.backgroundColor = [COLOR_BG_ROW colorWithAlphaComponent:0.9];
    self.pillView.layer.cornerRadius = 21;
    self.pillView.layer.borderWidth = 1.0;
    self.pillView.layer.borderColor = [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.5].CGColor;
    [self addSubview:self.pillView];

    self.tabTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, 170, 42)];
    self.tabTitleLabel.text = @"MENU";
    self.tabTitleLabel.textColor = COLOR_ACCENT_GOLD;
    self.tabTitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.tabTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.pillView addSubview:self.tabTitleLabel];

    // Close Button (ปุ่ม X)
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
    [self addSubview:self.scrollView];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 0)];
    [self.scrollView addSubview:self.contentView];

    // Footer Label
    self.footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentStartX, CGRectGetHeight(self.bounds) - 25, contentWidth, 20)];
    self.footerLabel.text = @"Native Gold Edition";
    self.footerLabel.textColor = COLOR_TEXT_DIM;
    self.footerLabel.font = [UIFont italicSystemFontOfSize:10];
    self.footerLabel.textAlignment = NSTextAlignmentRight;
    [self addSubview:self.footerLabel];
}

// =========================================================================
// UI ELEMENT METHODS (สร้างปุ่มและแถบต่างๆ)
// =========================================================================

- (void)addTab:(NSArray<NSString *> *)tabNames {
    self.tabTitles = tabNames;
    CGFloat y = 15;
    CGFloat btnSize = 50;

    for (NSInteger i = 0; i < tabNames.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((75 - btnSize) / 2.0, y, btnSize, btnSize);
        btn.layer.cornerRadius = 15;
        btn.tag = i;
        
        // ใช้ Symbol จาก iOS 13+ ถ้ามี
        if (@available(iOS 13.0, *)) {
            UIImage *img = [UIImage systemImageNamed:@"star.fill"];
            [btn setImage:img forState:UIControlStateNormal];
            [btn setImageTintColor:COLOR_TEXT_DIM forState:UIControlStateNormal];
        } else {
            [btn setTitle:[NSString stringWithFormat:@"%ld", (long)i+1] forState:UIControlStateNormal];
        }
        
        [btn addTarget:self action:@selector(tabButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabScrollView addSubview:btn];
        [self.tabButtons addObject:btn];

        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 0)];
        container.hidden = (i != 0);
        [self.contentView addSubview:container];
        [self.tabContainers addObject:container];
        [self.tabHeights addObject:@(0)];
        y += btnSize + 12;
    }
    self.tabScrollView.contentSize = CGSizeMake(75, y);
    [self setTabIndex:0];
}

// 1. ปุ่ม Toggle วงกลม (เหมือนในรูปเป๊ะ)
- (void)addFeatureSwitch:(NSString *)title isOn:(BOOL)isOn handler:(MenuSwitchHandler)handler {
    CGFloat width = self.scrollView.frame.size.width;
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 55)];
    row.backgroundColor = COLOR_BG_ROW;
    row.layer.cornerRadius = 15;
    row.layer.borderWidth = 1.0;
    row.layer.borderColor = COLOR_BORDER.CGColor;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, width - 60, 55)];
    lbl.text = title;
    lbl.textColor = COLOR_TEXT_MAIN;
    lbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [row addSubview:lbl];

    UIButton *toggle = [UIButton buttonWithType:UIButtonTypeCustom];
    toggle.frame = CGRectMake(width - 40, 15, 25, 25);
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

    [self addControlView:row height:55];
}

// 2. แถบ Slider สีทอง
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

// 3. ช่องกรอกข้อความ (TextField)
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
    objc_setAssociatedObject(tf, "tfHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [tf addTarget:self action:@selector(textFieldEdited:) forControlEvents:UIControlEventEditingChanged];
    [row addSubview:tf];

    [self addControlView:row height:80];
}

// 4. เมนูเลือกตัวเลือก (Combo Selector)
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

// =========================================================================
// LOGIC & INTERACTION (ระบบทำงาน)
// =========================================================================

- (void)makeDraggable {
    self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    [self addGestureRecognizer:self.panGesture];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self.superview];
    }
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
    valLbl.text = [NSString stringWithFormat:@"%.1f", sender.value];
    MenuSliderHandler handler = objc_getAssociatedObject(sender, "sliderHandler");
    if (handler) handler(sender.value);
}

- (void)textFieldEdited:(UITextField *)sender {
    MenuTextFieldHandler handler = objc_getAssociatedObject(sender, "tfHandler");
    if (handler) handler(sender.text);
}

- (void)comboTapped:(UIButton *)sender {
    NSArray *options = objc_getAssociatedObject(sender, "comboOptions");
    MenuComboHandler handler = objc_getAssociatedObject(sender, "comboHandler");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < options.count; i++) {
        [alert addAction:[UIAlertAction actionWithTitle:options[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            [sender setTitle:options[i] forState:UIControlStateNormal];
            if (handler) handler(i);
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    [[UIApplication sharedApplication].keyWindow.rootViewController presentViewController:alert animated:YES completion:nil];
}

- (void)setTabIndex:(NSInteger)index {
    if (index < 0 || index >= self.tabContainers.count) return;
    self.currentTabIndex = index;

    for (NSUInteger i = 0; i < self.tabButtons.count; i++) {
        UIButton *btn = self.tabButtons[i];
        BOOL selected = (i == index);
        btn.backgroundColor = selected ? [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.3] : [UIColor clearColor];
        [btn setImageTintColor:selected ? COLOR_ACCENT_GOLD : COLOR_TEXT_DIM forState:UIControlStateNormal];
    }

    if (index < self.tabTitles.count) {
        self.tabTitleLabel.text = [self.tabTitles[index] uppercaseString];
    }

    for (NSUInteger i = 0; i < self.tabContainers.count; i++) {
        self.tabContainers[i].hidden = (i != index);
    }

    self.contentHeight = [self.tabHeights[index] floatValue];
    self.contentView.frame = CGRectMake(0, 0, self.scrollView.frame.size.width, self.contentHeight);
    self.scrollView.contentSize = CGSizeMake(self.scrollView.frame.size.width, self.contentHeight);
}

- (void)addControlView:(UIView *)view height:(CGFloat)height {
    UIView *container = self.tabContainers[self.currentTabIndex];
    view.frame = CGRectMake(0, self.contentHeight, CGRectGetWidth(self.scrollView.bounds), height);
    [container addSubview:view];

    self.contentHeight += height + 10;
    container.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), self.contentHeight);
    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), self.contentHeight);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), self.contentHeight);
    
    if (self.currentTabIndex < self.tabHeights.count) {
        self.tabHeights[self.currentTabIndex] = @(self.contentHeight);
    }
}

- (void)tabButtonTapped:(UIButton *)sender { [self setTabIndex:sender.tag]; }
- (void)closeMenu { [self removeFromSuperview]; }

@end
