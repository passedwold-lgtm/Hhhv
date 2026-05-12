#import "MenuView.h"
#import <objc/runtime.h>

@interface MenuView ()
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, strong) UIView *pillView;
@property (nonatomic, strong) UIView *contentHeaderView;
@property (nonatomic, strong) UIView *headerTitleView;
@property (nonatomic, strong) UIImageView *headerIconImageView;
@property (nonatomic, strong) UILabel *headerTitleLabel;
@property (nonatomic, strong) UIButton *searchButton;
@property (nonatomic, strong) UIButton *themeToggleButton;
@property (nonatomic, strong) NSMutableArray<UIView *> *tabContainers;
@property (nonatomic, strong) NSMutableArray<NSNumber *> *tabHeights;
@property (nonatomic, strong) NSArray<NSString *> *tabTitles;
@property (nonatomic, assign) NSInteger currentTabIndex;
@property (nonatomic, strong) UILabel *footerLabel;
@property (nonatomic, strong) UIVisualEffectView *glassEffectView;
- (void)customizeScrollIndicator;
@end

@implementation MenuView

+ (instancetype)menuWithFrame:(CGRect)frame {
    MenuView *menu = [[MenuView alloc] initWithFrame:frame];
    [menu setup];
    return menu;
}

- (void)setup {
    // --- Native iOS Glass Morphism Setup ---
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 28.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 0.5;
    self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.25].CGColor;
    
    self.currentCategoryCounter = 0;
    self.selectedTabIndex = 0;
    self.canMove = NO;
    
    // Modern iOS Accent Color
    self.accentColor = [UIColor systemBlueColor];
    
    self.tabButtons = [NSMutableArray array];
    self.tabContainers = [NSMutableArray array];
    self.tabHeights = [NSMutableArray array];
    self.switches = [NSMutableDictionary dictionary];
    self.sliders = [NSMutableDictionary dictionary];
    self.sliderLabels = [NSMutableDictionary dictionary];
    self.buttons = [NSMutableDictionary dictionary];
    self.textFields = [NSMutableDictionary dictionary];

    // Main Glass Background with iOS Version Check
    UIBlurEffect *blurEffect;
    if (@available(iOS 13.0, *)) {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleSystemThinMaterialDark];
    } else {
        blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    }
    
    self.glassEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.glassEffectView.frame = self.bounds;
    self.glassEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.glassEffectView];
    self.blurEffectView = self.glassEffectView; // Link to property in .h

    // Subtle Gradient for Depth
    UIView *vibrancyOverlay = [[UIView alloc] initWithFrame:self.bounds];
    vibrancyOverlay.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.03];
    vibrancyOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:vibrancyOverlay];

    CGFloat sidebarWidth = 80;
    CGFloat headerHeight = 85;
    CGFloat contentStartX = sidebarWidth + 12;
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - contentStartX - 12;

    // --- Sidebar (Tabs) ---
    self.tabSidebar = [[UIView alloc] initWithFrame:CGRectMake(12, 12, sidebarWidth, CGRectGetHeight(self.bounds) - 24)];
    self.tabSidebar.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.15];
    self.tabSidebar.layer.cornerRadius = 22.0;
    self.tabSidebar.layer.masksToBounds = YES;
    self.tabSidebar.layer.borderWidth = 0.5;
    self.tabSidebar.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;
    self.tabSidebar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.tabSidebar];

    self.tabScrollView = [[UIScrollView alloc] initWithFrame:self.tabSidebar.bounds];
    self.tabScrollView.showsVerticalScrollIndicator = NO;
    self.tabScrollView.delegate = self;
    self.tabScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tabSidebar addSubview:self.tabScrollView];

    self.tabContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, 0)];
    [self.tabScrollView addSubview:self.tabContainerView];

    // --- Header Section (Pill View) ---
    CGFloat titleY = 20;
    CGFloat pillHeight = 44;
    self.pillView = [[UIView alloc] initWithFrame:CGRectMake(contentStartX, titleY, 180, pillHeight)];
    self.pillView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.1];
    self.pillView.layer.cornerRadius = pillHeight / 2;
    self.pillView.layer.borderWidth = 0.5;
    self.pillView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.15].CGColor;
    [self addSubview:self.pillView];

    self.pillIcon = [[UIImageView alloc] initWithFrame:CGRectMake(14, (pillHeight - 22) / 2.0, 22, 22)];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *iconConfig = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightBold];
        self.pillIcon.image = [[UIImage systemImageNamed:@"sparkles" withConfiguration:iconConfig] imageWithTintColor:self.accentColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    self.pillIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.pillView addSubview:self.pillIcon];

    self.tabTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(44, 0, self.pillView.frame.size.width - 50, pillHeight)];
    self.tabTitleLabel.text = @"DASHBOARD";
    self.tabTitleLabel.textColor = [UIColor whiteColor];
    self.tabTitleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightBold];
    [self.pillView addSubview:self.tabTitleLabel];

    // Close Button
    CGFloat buttonSize = 36;
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - buttonSize - 16, titleY + (pillHeight - buttonSize) / 2.0, buttonSize, buttonSize);
    self.closeButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.15];
    self.closeButton.layer.cornerRadius = buttonSize / 2;
    self.closeButton.tintColor = [UIColor whiteColor];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *closeConfig = [UIImageSymbolConfiguration configurationWithPointSize:14 weight:UIImageSymbolWeightBold];
        [self.closeButton setImage:[UIImage systemImageNamed:@"xmark" withConfiguration:closeConfig] forState:UIControlStateNormal];
    } else {
        [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
    }
    [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];

    // --- Content Area ---
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(contentStartX, headerHeight, contentWidth, CGRectGetHeight(self.bounds) - headerHeight - 40)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 0)];
    [self.scrollView addSubview:self.contentView];

    // Footer
    self.footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentStartX, CGRectGetHeight(self.bounds) - 35, contentWidth, 25)];
    self.footerLabel.textAlignment = NSTextAlignmentCenter;
    self.footerLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.3];
    self.footerLabel.font = [UIFont italicSystemFontOfSize:11];
    self.footerLabel.text = @"Native iOS Glass Edition";
    [self addSubview:self.footerLabel];
}

// --- Implementation of missing methods from .h ---

- (void)addTab:(NSArray<NSString *> *)tabNames {
    self.tabTitles = tabNames;
    CGFloat y = 10;
    CGFloat tabButtonSize = 56;
    CGFloat tabSpacing = 12;
    
    NSDictionary<NSString *, NSString *> *iconMap = @{
        @"esp": @"eye",
        @"aimbot": @"scope",
        @"memory": @"cube.box",
        @"settings": @"gearshape",
        @"cheats": @"hammer",
        @"info": @"info.circle"
    };

    for (NSInteger i = 0; i < tabNames.count; i++) {
        NSString *tabName = tabNames[i];
        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tabButton.frame = CGRectMake((80 - tabButtonSize) / 2.0, y, tabButtonSize, tabButtonSize);
        tabButton.layer.cornerRadius = 16.0;
        tabButton.backgroundColor = [UIColor clearColor];
        tabButton.tag = i;
        
        NSString *symbolName = iconMap[[tabName lowercaseString]] ?: @"star";
        if (@available(iOS 13.0, *)) {
            UIImage *iconImage = [UIImage systemImageNamed:symbolName];
            [tabButton setImage:[iconImage imageWithTintColor:[UIColor colorWithWhite:1.0 alpha:0.4] renderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
        } else {
            [tabButton setTitle:[tabName substringToIndex:MIN(3, tabName.length)] forState:UIControlStateNormal];
        }
        
        [tabButton addTarget:self action:@selector(tabButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabScrollView addSubview:tabButton];
        [self.tabButtons addObject:tabButton];

        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), 0)];
        container.hidden = (i != 0);
        [self.contentView addSubview:container];
        [self.tabContainers addObject:container];
        [self.tabHeights addObject:@(0)];

        y += tabButtonSize + tabSpacing;
    }
    self.tabScrollView.contentSize = CGSizeMake(80, y);
    if (self.tabButtons.count > 0) [self setTabIndex:0];
}

- (void)addComboSelector:(NSString *)title options:(NSArray *)options selectedIndex:(NSInteger)index handler:(MenuComboHandler)handler {
    CGFloat contentWidth = self.scrollView.frame.size.width;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 70)];
    container.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    container.layer.cornerRadius = 16.0;
    container.layer.borderWidth = 0.5;
    container.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 10, contentWidth - 32, 20)];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    [container addSubview:titleLabel];

    UIButton *comboBtn = [UIButton buttonWithType:UIButtonTypeSystem];
    comboBtn.frame = CGRectMake(16, 35, contentWidth - 32, 30);
    [comboBtn setTitle:options[index] forState:UIControlStateNormal];
    [comboBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    comboBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    
    objc_setAssociatedObject(comboBtn, "comboOptions", options, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(comboBtn, "comboHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [comboBtn addTarget:self action:@selector(comboTapped:) forControlEvents:UIControlEventTouchUpInside];
    [container addSubview:comboBtn];

    [self addControlView:container height:CGRectGetHeight(container.bounds) + 8];
}

- (void)comboTapped:(UIButton *)sender {
    NSArray *options = objc_getAssociatedObject(sender, "comboOptions");
    MenuComboHandler handler = objc_getAssociatedObject(sender, "comboHandler");
    
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"Select Option" message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    for (NSInteger i = 0; i < options.count; i++) {
        [alert addAction:[UIAlertAction actionWithTitle:options[i] style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action) {
            [sender setTitle:options[i] forState:UIControlStateNormal];
            if (handler) handler(i);
        }]];
    }
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleCancel handler:nil]];
    
    UIViewController *root = [UIApplication sharedApplication].keyWindow.rootViewController;
    [root presentViewController:alert animated:YES completion:nil];
}

- (void)addLabel:(NSString *)text {
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 30)];
    label.text = text;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:13];
    label.textAlignment = NSTextAlignmentCenter;
    [self addControlView:label height:30];
}

- (void)addThemeSlider:(NSString *)title property:(NSString *)prop max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(MenuSliderHandler)handler {
    [self addSlider:title max:max min:min value:value handler:^(CGFloat val) {
        objc_setAssociatedObject(self, [prop UTF8String], @(val), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        if (handler) handler(val);
    }];
}

- (void)makeDraggable {
    if (!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panGesture.delegate = self;
        [self addGestureRecognizer:self.panGesture];
    }
    self.canMove = YES;
}

- (void)canMove:(BOOL)enabled {
    self.canMove = enabled;
    self.panGesture.enabled = enabled;
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateChanged) {
        self.center = CGPointMake(self.center.x + translation.x, self.center.y + translation.y);
        [gesture setTranslation:CGPointZero inView:self.superview];
    }
}

- (void)updateLayout {
    // Basic layout update logic
    [self setNeedsLayout];
}

// --- UI Element Methods ---

- (void)addSectionTitle:(NSString *)title {
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), 40)];
    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(8, 15, CGRectGetWidth(box.bounds) - 16, 20)];
    titleLabel.text = [title uppercaseString];
    titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.5];
    [box addSubview:titleLabel];
    [self addControlView:box height:CGRectGetHeight(box.bounds)];
}

- (void)addFeatureSwitch:(NSString *)title description:(NSString *)desc isOn:(BOOL)isOn handler:(MenuSwitchHandler)handler {
    CGFloat contentWidth = self.scrollView.frame.size.width;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 64)];
    container.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    container.layer.cornerRadius = 16.0;
    container.layer.borderWidth = 0.5;
    container.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;
    
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, container.frame.size.width - 80, 20)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightSemibold];
    [container addSubview:label];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 34, container.frame.size.width - 80, 16)];
    descLabel.text = desc;
    descLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.4];
    descLabel.font = [UIFont systemFontOfSize:12];
    [container addSubview:descLabel];
    
    UISwitch *toggle = [[UISwitch alloc] init];
    toggle.center = CGPointMake(container.frame.size.width - 40, container.frame.size.height / 2);
    toggle.onTintColor = self.accentColor;
    toggle.on = isOn;
    [toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(toggle, "switchHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [container addSubview:toggle];
    
    [self addControlView:container height:CGRectGetHeight(container.bounds) + 8];
}

- (void)addFeatureSwitch:(NSString *)title {
    [self addFeatureSwitch:title description:@"Custom feature" isOn:NO handler:nil];
}

- (void)addSlider:(NSString *)title min:(CGFloat)min max:(CGFloat)max value:(CGFloat)value handler:(MenuSliderHandler)handler {
    [self addSlider:title max:max min:min value:value handler:handler];
}

- (void)addSlider:(NSString *)title max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(void (^)(CGFloat value))handler {
    CGFloat contentWidth = self.scrollView.frame.size.width;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 80)];
    container.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    container.layer.cornerRadius = 16.0;
    container.layer.borderWidth = 0.5;
    container.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, container.frame.size.width - 80, 20)];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    [container addSubview:titleLabel];

    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(container.frame.size.width - 66, 12, 50, 20)];
    valueLabel.textColor = self.accentColor;
    valueLabel.font = [UIFont monospacedDigitSystemFontOfSize:14 weight:UIFontWeightBold];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.text = [NSString stringWithFormat:@"%.1f", value];
    [container addSubview:valueLabel];

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(16, 44, container.frame.size.width - 32, 30)];
    slider.minimumValue = min;
    slider.maximumValue = max;
    slider.value = value;
    slider.minimumTrackTintColor = self.accentColor;
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(slider, "sliderHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(slider, "valueLabel", valueLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [container addSubview:slider];

    [self addControlView:container height:CGRectGetHeight(container.bounds) + 8];
}

- (void)addButton:(NSString *)title withHandler:(MenuButtonHandler)handler {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = [self.accentColor colorWithAlphaComponent:0.8];
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    button.layer.cornerRadius = 16.0;
    button.clipsToBounds = YES;
    objc_setAssociatedObject(button, "menuHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addControlView:button height:54];
}

- (void)addTextField:(NSString *)title placeholder:(NSString *)placeholder handler:(MenuTextFieldHandler)handler {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), 90)];
    container.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.06];
    container.layer.cornerRadius = 16.0;
    container.layer.borderWidth = 0.5;
    container.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, container.frame.size.width - 32, 20)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.6];
    [container addSubview:titleLabel];

    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(16, 42, container.frame.size.width - 32, 36)];
    field.backgroundColor = [UIColor colorWithWhite:0.0 alpha:0.2];
    field.textColor = [UIColor whiteColor];
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:0.3]}];
    field.layer.cornerRadius = 10.0;
    field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    field.leftViewMode = UITextFieldViewModeAlways;
    objc_setAssociatedObject(field, "menuHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [container addSubview:field];
    [self addControlView:container height:CGRectGetHeight(container.bounds) + 8];
}

- (void)addControlView:(UIView *)view height:(CGFloat)height {
    UIView *container = [self activeContentContainer];
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    view.frame = CGRectMake(0, self.contentHeight, width, height);
    [container addSubview:view];

    self.contentHeight += height + 10;
    container.frame = CGRectMake(0, 0, width, self.contentHeight);
    self.contentView.frame = CGRectMake(0, 0, width, self.contentHeight);
    self.scrollView.contentSize = CGSizeMake(width, self.contentHeight);

    if (self.currentTabIndex >= 0 && self.currentTabIndex < self.tabHeights.count) {
        self.tabHeights[self.currentTabIndex] = @(self.contentHeight);
    }
}

// --- Setters & Logic ---

- (void)setTabIndex:(NSInteger)index {
    if (index < 0 || index >= self.tabContainers.count) return;
    self.currentTabIndex = index;
    self.selectedTabIndex = index;

    for (NSUInteger i = 0; i < self.tabButtons.count; i++) {
        UIButton *button = self.tabButtons[i];
        BOOL selected = button.tag == index;
        
        [UIView animateWithDuration:0.3 animations:^{
            button.backgroundColor = selected ? [self.accentColor colorWithAlphaComponent:0.3] : [UIColor clearColor];
            button.layer.borderColor = selected ? [self.accentColor colorWithAlphaComponent:0.5].CGColor : [UIColor clearColor].CGColor;
            button.layer.borderWidth = selected ? 1.0 : 0.0;
            button.transform = selected ? CGAffineTransformMakeScale(1.05, 1.05) : CGAffineTransformIdentity;
            
            if (@available(iOS 13.0, *)) {
                UIImage *image = button.imageView.image;
                if (image) {
                    [button setImage:[image imageWithTintColor:selected ? [UIColor whiteColor] : [UIColor colorWithWhite:1.0 alpha:0.4] renderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
                }
            }
        }];
    }

    if (index < self.tabTitles.count) {
        self.tabTitleLabel.text = [self.tabTitles[index] uppercaseString];
    }
    
    for (NSUInteger i = 0; i < self.tabContainers.count; i++) {
        self.tabContainers[i].hidden = (i != index);
    }

    self.contentHeight = [self.tabHeights[index] floatValue];
    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), self.contentHeight);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), self.contentHeight);
}

- (UIView *)activeContentContainer {
    if (self.currentTabIndex >= 0 && self.currentTabIndex < self.tabContainers.count) {
        return self.tabContainers[self.currentTabIndex];
    }
    return self.contentView;
}

- (void)setMenuAccentColor:(UIColor *)color { self.accentColor = color; }
- (void)setMenuGlassEffect:(BOOL)enabled { self.glassEffectView.hidden = !enabled; }
- (void)setMenuCornerRadius:(CGFloat)radius { self.layer.cornerRadius = radius; }
- (void)setMenuBorderWidth:(CGFloat)width { self.layer.borderWidth = width; }
- (void)setMenuTitle:(NSString *)title { self.tabTitleLabel.text = title; }
- (void)setMenuSubtitle:(NSString *)subtitle { /* Optional: Implement if needed */ }
- (void)setFooterText:(NSString *)text { self.footerLabel.text = text; }

- (void)tabButtonTapped:(UIButton *)sender { [self setTabIndex:sender.tag]; }
- (void)closeButtonTapped:(UIButton *)sender { [self closeMenu]; }

- (void)switchChanged:(UISwitch *)sender {
    MenuSwitchHandler handler = objc_getAssociatedObject(sender, "switchHandler");
    if (handler) handler(sender.on);
}

- (void)sliderValueChanged:(UISlider *)sender {
    UILabel *label = objc_getAssociatedObject(sender, "valueLabel");
    if ([label isKindOfClass:[UILabel class]]) {
        label.text = [NSString stringWithFormat:@"%.1f", sender.value];
    }
    void (^handler)(CGFloat) = objc_getAssociatedObject(sender, "sliderHandler");
    if (handler) handler(sender.value);
}

- (void)buttonTapped:(UIButton *)sender {
    void (^handler)(void) = objc_getAssociatedObject(sender, "menuHandler");
    if (handler) handler();
}

- (void)closeMenu {
    [UIView animateWithDuration:0.2 animations:^{
        self.alpha = 0.0;
    } completion:^(BOOL finished) {
        [self removeFromSuperview];
    }];
}

@end
