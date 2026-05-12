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
- (void)customizeScrollIndicator;
@end

@implementation MenuView

+ (instancetype)menuWithFrame:(CGRect)frame {
    MenuView *menu = [[MenuView alloc] initWithFrame:frame];
    [menu setup];
    return menu;
}

- (void)setup {
    self.backgroundColor = [UIColor clearColor];
    self.layer.cornerRadius = 18.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.12].CGColor;
    self.alpha = 0.92;
    self.currentCategoryCounter = 0;
    self.selectedTabIndex = 0;
    self.canMove = NO;

    self.accentColor = [UIColor colorWithRed:110.0/255.0 green:142.0/255.0 blue:251.0/255.0 alpha:1.0];
    self.tabButtons = [NSMutableArray array];
    self.tabContainers = [NSMutableArray array];
    self.tabHeights = [NSMutableArray array];
    self.switches = [NSMutableDictionary dictionary];
    self.sliders = [NSMutableDictionary dictionary];
    self.sliderLabels = [NSMutableDictionary dictionary];
    self.buttons = [NSMutableDictionary dictionary];
    self.textFields = [NSMutableDictionary dictionary];

    UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleDark];
    self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    self.blurEffectView.frame = self.bounds;
    self.blurEffectView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.blurEffectView];

    UIView *gradientOverlay = [[UIView alloc] initWithFrame:self.bounds];
    gradientOverlay.backgroundColor = [UIColor colorWithRed:10.0/255.0 green:10.0/255.0 blue:22.0/255.0 alpha:0.55];
    gradientOverlay.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self addSubview:gradientOverlay];

    CGFloat sidebarWidth = 76;
    CGFloat headerHeight = 78;
    CGFloat contentStartX = sidebarWidth + 12;
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - contentStartX;

    self.tabSidebar = [[UIView alloc] initWithFrame:CGRectMake(12, 12, sidebarWidth, CGRectGetHeight(self.bounds) - 24)];
    self.tabSidebar.backgroundColor = [UIColor colorWithRed:6.0/255.0 green:6.0/255.0 blue:18.0/255.0 alpha:0.90];
    self.tabSidebar.layer.cornerRadius = 18.0;
    self.tabSidebar.layer.masksToBounds = YES;
    self.tabSidebar.autoresizingMask = UIViewAutoresizingFlexibleHeight;
    [self addSubview:self.tabSidebar];

    self.tabScrollView = [[UIScrollView alloc] initWithFrame:self.tabSidebar.bounds];
    self.tabScrollView.showsVerticalScrollIndicator = YES;
    self.tabScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.tabScrollView.delegate = self;
    self.tabScrollView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.tabSidebar addSubview:self.tabScrollView];

    self.tabContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, 0)];
    [self.tabScrollView addSubview:self.tabContainerView];

    [self customizeScrollIndicator];

    UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(sidebarWidth - 1, 0, 1, CGRectGetHeight(self.bounds))];
    separator.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.07];
    [self.tabSidebar addSubview:separator];

    self.tabButtons = [NSMutableArray array];

    CGFloat titleY = 16;
    CGFloat pillHeight = 42;
    self.pillView = [[UIView alloc] initWithFrame:CGRectMake(contentStartX + 16, titleY, 178, pillHeight)];
    self.pillView.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.07];
    self.pillView.layer.cornerRadius = pillHeight / 2;
    self.pillView.layer.borderWidth = 1.0;
    self.pillView.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.08].CGColor;
    [self addSubview:self.pillView];

    self.pillIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, (pillHeight - 20) / 2.0, 20, 20)];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *iconConfig = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightSemibold];
        self.pillIcon.image = [[UIImage systemImageNamed:@"scope" withConfiguration:iconConfig] imageWithTintColor:self.accentColor renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    self.pillIcon.contentMode = UIViewContentModeScaleAspectFit;
    [self.pillView addSubview:self.pillIcon];

    self.tabTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.pillView.frame.size.width - 48, pillHeight)];
    self.tabTitleLabel.text = @"AIMBOT";
    self.tabTitleLabel.textColor = [UIColor whiteColor];
    self.tabTitleLabel.font = [UIFont systemFontOfSize:14 weight:UIFontWeightSemibold];
    self.tabTitleLabel.textAlignment = NSTextAlignmentLeft;
    [self.pillView addSubview:self.tabTitleLabel];

    self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.searchButton.frame = CGRectMake(self.pillView.frame.size.width - 32, (pillHeight - 20) / 2.0, 20, 20);
    if (@available(iOS 13.0, *)) {
        [self.searchButton setImage:[UIImage systemImageNamed:@"magnifyingglass"] forState:UIControlStateNormal];
    }
    self.searchButton.tintColor = [UIColor colorWithWhite:0.7 alpha:1.0];
    [self.pillView addSubview:self.searchButton];

    CGFloat buttonSize = 42;
    CGFloat buttonY = titleY + (pillHeight - buttonSize) / 2.0;

    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - buttonSize - 16, buttonY, buttonSize, buttonSize);
    self.closeButton.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.10];
    self.closeButton.layer.cornerRadius = 12.0;
    self.closeButton.contentHorizontalAlignment = UIControlContentHorizontalAlignmentCenter;
    self.closeButton.contentVerticalAlignment = UIControlContentVerticalAlignmentCenter;
    self.closeButton.tintColor = [UIColor whiteColor];
    self.closeButton.imageView.contentMode = UIViewContentModeCenter;
    self.closeButton.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *closeConfig = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightSemibold];
        UIImage *closeImage = [UIImage systemImageNamed:@"xmark" withConfiguration:closeConfig];
        [self.closeButton setImage:closeImage forState:UIControlStateNormal];
    } else {
        [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
        self.closeButton.titleLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightSemibold];
    }
    [self.closeButton addTarget:self action:@selector(closeButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];

    CGFloat subtitleY = titleY + pillHeight + 10;
    self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentStartX + 16, subtitleY, contentWidth - 32, 16)];
    self.subtitleLabel.text = @"";
    self.subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.40];
    self.subtitleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    self.subtitleLabel.textAlignment = NSTextAlignmentLeft;
    [self addSubview:self.subtitleLabel];

    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(contentStartX, headerHeight, contentWidth, CGRectGetHeight(self.bounds) - headerHeight - 28)];
    self.scrollView.showsVerticalScrollIndicator = YES;
    self.scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 0)];
    [self.scrollView addSubview:self.contentView];

    self.footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentStartX, CGRectGetHeight(self.bounds) - 30, contentWidth, 25)];
    self.footerLabel.textAlignment = NSTextAlignmentCenter;
    self.footerLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.22];
    self.footerLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    self.footerLabel.text = @"◈ Hoang Xuan Tu • Mod Menu";
    [self addSubview:self.footerLabel];
}

- (void)setMenuTitle:(NSString *)title {
    self.titleLabel.text = title;
}

- (void)setMenuSubtitle:(NSString *)subtitle {
    self.subtitleLabel.text = subtitle;
}

- (void)setFooterText:(NSString *)text {
    self.footerLabel.text = text;
}

- (void)makeDraggable {
    if (!self.panGesture) {
        self.panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        self.panGesture.delegate = self;
        [self addGestureRecognizer:self.panGesture];
    }
    self.canMove = YES;
}

- (void)setMenuGlassEffect:(BOOL)enabled {
    self.blurEffectView.hidden = !enabled;
}

- (void)customizeScrollIndicator {
    // Keep the sidebar indicator visible and consistent with the dark theme.
    self.tabScrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
    if (@available(iOS 13.0, *)) {
        self.tabScrollView.verticalScrollIndicatorInsets = UIEdgeInsetsMake(0, 0, 0, -4);
    }
}

- (void)canMove:(BOOL)canMove {
    if (canMove && self.gestureRecognizers.count == 0) {
        UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
        [self addGestureRecognizer:pan];
    }
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateChanged || gesture.state == UIGestureRecognizerStateEnded) {
        CGRect frame = self.frame;
        frame.origin.x += translation.x;
        frame.origin.y += translation.y;
        self.frame = frame;
        [gesture setTranslation:CGPointZero inView:self.superview];
    }
}

- (void)addTab:(NSArray<NSString *> *)titles {
    for (UIButton *button in self.tabButtons) {
        [button removeFromSuperview];
    }
    [self.tabButtons removeAllObjects];
    [self.tabContainers makeObjectsPerformSelector:@selector(removeFromSuperview)];
    [self.tabContainers removeAllObjects];
    [self.tabHeights removeAllObjects];

    self.tabTitles = [titles copy];
    NSDictionary<NSString *, NSString *> *iconMap = @{
        @"esp": @"eye",
        @"aimbot": @"scope",
        @"memory": @"cube.box",
        @"settings": @"gearshape",
        @"cheats": @"hammer",
        @"info": @"info.circle"
    };

    CGFloat sidebarWidth = CGRectGetWidth(self.tabSidebar.bounds);
    CGFloat tabButtonSize = 42.0;
    CGFloat tabSpacing = 10.0;
    CGFloat y = 18.0;
    CGFloat buttonX = (sidebarWidth - tabButtonSize) / 2.0;

    for (NSUInteger i = 0; i < titles.count; i++) {
        NSString *tabName = titles[i];
        UIButton *tabButton = [UIButton buttonWithType:UIButtonTypeCustom];
        tabButton.frame = CGRectMake(buttonX, y, tabButtonSize, tabButtonSize);
        tabButton.layer.cornerRadius = 12.0;
        tabButton.layer.borderWidth = 1.0;
        tabButton.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.08].CGColor;
        tabButton.backgroundColor = [UIColor clearColor];
        tabButton.tintColor = [UIColor colorWithWhite:1.0 alpha:0.65];
        tabButton.imageView.contentMode = UIViewContentModeScaleAspectFit;
        tabButton.adjustsImageWhenHighlighted = NO;

        NSString *symbolName = iconMap[[tabName lowercaseString]] ?: @"star";
        UIImage *iconImage = nil;
        if (@available(iOS 13.0, *)) {
            iconImage = [UIImage systemImageNamed:symbolName];
            if (iconImage) {
                iconImage = [iconImage imageWithTintColor:[UIColor colorWithWhite:1.0 alpha:0.65] renderingMode:UIImageRenderingModeAlwaysOriginal];
                [tabButton setImage:iconImage forState:UIControlStateNormal];
                tabButton.imageEdgeInsets = UIEdgeInsetsMake(8, 8, 8, 8);
            }
        }
        if (!iconImage) {
            [tabButton setTitle:[tabName uppercaseString] forState:UIControlStateNormal];
            tabButton.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
            [tabButton setTitleColor:[UIColor colorWithWhite:1.0 alpha:0.65] forState:UIControlStateNormal];
        }

        tabButton.tag = i;
        [tabButton addTarget:self action:@selector(tabButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabScrollView addSubview:tabButton];
        [self.tabButtons addObject:tabButton];

        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), 8)];
        container.backgroundColor = [UIColor clearColor];
        container.hidden = (i != 0);
        [self.contentView addSubview:container];
        [self.tabContainers addObject:container];
        [self.tabHeights addObject:@(8)];

        y += tabButtonSize + tabSpacing;
    }

    self.tabScrollView.contentSize = CGSizeMake(sidebarWidth, y);
    if (self.tabButtons.count > 0) {
        [self setTabIndex:0];
    }
}

- (void)setTabIndex:(NSInteger)index {
    if (index < 0 || index >= self.tabContainers.count) return;
    self.currentTabIndex = index;
    self.selectedTabIndex = index;

    for (NSUInteger i = 0; i < self.tabButtons.count; i++) {
        UIButton *button = self.tabButtons[i];
        BOOL selected = button.tag == index;
        button.backgroundColor = selected ? [self.accentColor colorWithAlphaComponent:0.22] : [UIColor clearColor];
        button.layer.borderColor = selected ? [self.accentColor CGColor] : [UIColor colorWithWhite:1.0 alpha:0.08].CGColor;
        button.layer.borderWidth = selected ? 1.5 : 1.0;
        button.tintColor = selected ? [UIColor whiteColor] : [UIColor colorWithWhite:1.0 alpha:0.65];
        if (@available(iOS 13.0, *)) {
            UIImage *image = button.imageView.image;
            if (image) {
                [button setImage:[image imageWithTintColor:selected ? [UIColor whiteColor] : [UIColor colorWithWhite:1.0 alpha:0.65] renderingMode:UIImageRenderingModeAlwaysOriginal] forState:UIControlStateNormal];
            }
        }
    }

    NSString *tabName = self.tabTitles[index];
    self.tabTitleLabel.text = [tabName uppercaseString];
    NSDictionary<NSString *, NSString *> *iconMap = @{
        @"esp": @"eye",
        @"aimbot": @"scope",
        @"memory": @"cube.box",
        @"settings": @"gearshape",
        @"cheats": @"hammer",
        @"info": @"info.circle"
    };
    NSString *symbolName = iconMap[[tabName lowercaseString]] ?: @"star";
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *iconConfig = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightSemibold];
        self.pillIcon.image = [[UIImage systemImageNamed:symbolName withConfiguration:iconConfig] imageWithTintColor:self.accentColor renderingMode:UIImageRenderingModeAlwaysOriginal];
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

- (void)tabButtonTapped:(UIButton *)sender {
    [self setTabIndex:sender.tag];
}

- (void)closeButtonTapped:(UIButton *)sender {
    [self closeMenu];
}

- (void)addSectionTitle:(NSString *)title {
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds) - 32, 48)];
    box.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.05];
    box.layer.cornerRadius = 18;
    box.layer.borderWidth = 1.0;
    box.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08].CGColor;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 14, CGRectGetWidth(box.bounds) - 32, 18)];
    titleLabel.text = [title uppercaseString];
    titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.68];
    [box addSubview:titleLabel];

    [self addControlView:box height:CGRectGetHeight(box.bounds)];
}

- (void)addFeatureSwitch:(NSString *)title description:(NSString *)desc isOn:(BOOL)isOn handler:(MenuSwitchHandler)handler {
    CGFloat contentWidth = self.scrollView.frame.size.width;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(16, 0, contentWidth - 32, 48)];
    container.tag = self.currentCategoryCounter + 1000;
    container.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
    container.layer.cornerRadius = 12.0;
    container.layer.borderWidth = 1.0;
    container.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.08].CGColor;
    
    UIView *verticalBar = [[UIView alloc] initWithFrame:CGRectMake(0, 10, 3, container.frame.size.height - 20)];
    verticalBar.backgroundColor = self.accentColor;
    verticalBar.layer.cornerRadius = 1.5;
    verticalBar.tag = 9997;
    [container addSubview:verticalBar];
    
    CGFloat labelHeight = 18;
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(14, 7, container.frame.size.width - 92, labelHeight)];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    [container addSubview:label];
    
    UILabel *descLabel = [[UILabel alloc] initWithFrame:CGRectMake(14, 7 + labelHeight, container.frame.size.width - 92, 14)];
    descLabel.text = desc;
    descLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.42];
    descLabel.font = [UIFont systemFontOfSize:8.5 weight:UIFontWeightRegular];
    [container addSubview:descLabel];
    
    CGFloat switchWidth = 51 * 0.8;
    CGFloat switchHeight = 31 * 0.8;
    CGFloat switchY = (container.frame.size.height - switchHeight) / 2.0;
    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(container.frame.size.width - switchWidth - 16, switchY, switchWidth, switchHeight)];
    toggle.transform = CGAffineTransformMakeScale(0.8, 0.8);
    toggle.onTintColor = self.accentColor;
    toggle.on = isOn;
    [toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(toggle, "switchHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [container addSubview:toggle];
    
    [self addControlView:container height:CGRectGetHeight(container.bounds)];
    self.switches[title] = toggle;
}

- (void)addFeatureSwitch:(NSString *)title {
    [self addFeatureSwitch:title description:@"Custom feature" isOn:NO handler:nil];
}

- (void)addSlider:(NSString *)title min:(CGFloat)min max:(CGFloat)max value:(CGFloat)value handler:(MenuSliderHandler)handler {
    [self addSlider:title max:max min:min value:value handler:handler];
}

- (void)addSlider:(NSString *)title max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(void (^)(CGFloat value))handler {
    CGFloat contentWidth = self.scrollView.frame.size.width;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(16, 0, contentWidth - 32, 48)];
    container.tag = self.currentCategoryCounter + 1000;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width - 80, 16)];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    [container addSubview:titleLabel];

    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(container.frame.size.width - 50, 0, 50, 16)];
    valueLabel.textColor = self.accentColor;
    valueLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightBold];
    valueLabel.textAlignment = NSTextAlignmentRight;
    valueLabel.text = [NSString stringWithFormat:@"%.1f", value];
    [container addSubview:valueLabel];

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(0, 20, container.frame.size.width, 24)];
    slider.minimumValue = min;
    slider.maximumValue = max;
    slider.value = value;
    slider.minimumTrackTintColor = self.accentColor;
    UIImage *thumbImage = [self createSliderThumbImage];
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    [slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [slider addTarget:self action:@selector(sliderValueChanged:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(slider, "sliderHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(slider, "valueLabel", valueLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [container addSubview:slider];

    [self addControlView:container height:CGRectGetHeight(container.bounds)];
    self.sliders[title] = slider;
    self.sliderLabels[title] = valueLabel;
}

- (void)addButton:(NSString *)title withHandler:(void (^)(void))handler {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = self.accentColor;
    [button setTitle:[title uppercaseString] forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    button.layer.cornerRadius = 14.0;
    button.layer.masksToBounds = YES;
    button.layer.shadowColor = [UIColor blackColor].CGColor;
    button.layer.shadowOpacity = 0.12;
    button.layer.shadowRadius = 6.0;
    button.layer.shadowOffset = CGSizeMake(0, 3);
    objc_setAssociatedObject(button, "menuHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self addControlView:button height:46];
}

- (void)addTextField:(NSString *)title placeholder:(NSString *)placeholder handler:(MenuTextFieldHandler)handler {
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds) - 32, 90)];
    box.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.05];
    box.layer.cornerRadius = 18.0;
    box.layer.borderWidth = 1.0;
    box.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.10].CGColor;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 14, CGRectGetWidth(box.bounds) - 32, 18)];
    titleLabel.text = [title uppercaseString];
    titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.85];
    [box addSubview:titleLabel];

    UITextField *field = [[UITextField alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(titleLabel.frame) + 10, CGRectGetWidth(box.bounds) - 32, 38)];
    field.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08];
    field.textColor = [UIColor whiteColor];
    field.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName:[UIColor colorWithWhite:1.0 alpha:0.5]}];
    field.layer.cornerRadius = 14.0;
    field.layer.borderWidth = 1.0;
    field.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08].CGColor;
    field.leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 12, 0)];
    field.leftViewMode = UITextFieldViewModeAlways;
    field.returnKeyType = UIReturnKeyDone;
    field.textColor = [UIColor whiteColor];
    field.font = [UIFont systemFontOfSize:12];
    field.delegate = self;
    objc_setAssociatedObject(field, "menuHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [box addSubview:field];

    [self addControlView:box height:CGRectGetHeight(box.bounds)];
}

- (void)textFieldChanged:(UITextField *)sender {
    MenuTextFieldHandler handler = objc_getAssociatedObject(sender, "menuHandler");
    if (handler) handler(sender.text ?: @"");
}

- (void)addComboSelector:(NSString *)title options:(NSArray *)options selectedIndex:(NSInteger)selectedIndex handler:(MenuComboHandler)handler {
    CGFloat contentWidth = self.scrollView.frame.size.width;
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(16, 0, contentWidth - 32, 56)];
    container.tag = self.currentCategoryCounter + 1000;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, container.frame.size.width, 16)];
    titleLabel.text = title;
    titleLabel.textColor = [UIColor whiteColor];
    titleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightMedium];
    [container addSubview:titleLabel];

    UIButton *comboBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    comboBtn.frame = CGRectMake(0, 20, container.frame.size.width, 32);
    comboBtn.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.05];
    comboBtn.layer.cornerRadius = self.layer.cornerRadius * 0.3;
    comboBtn.layer.borderWidth = 1.0;
    comboBtn.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.1].CGColor;
    [comboBtn setTitle:options[selectedIndex] forState:UIControlStateNormal];
    [comboBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    comboBtn.titleLabel.font = [UIFont systemFontOfSize:10];
    comboBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
    comboBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);

    UIButton *arrowBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    arrowBtn.frame = CGRectMake(comboBtn.frame.size.width - 24, 0, 20, 32);
    [arrowBtn setTitle:@"▶" forState:UIControlStateNormal];
    [arrowBtn setTitleColor:[UIColor colorWithWhite:0.5 alpha:1.0] forState:UIControlStateNormal];
    arrowBtn.titleLabel.font = [UIFont systemFontOfSize:11];
    arrowBtn.tag = 8888;
    [arrowBtn addTarget:self action:@selector(comboTapped:) forControlEvents:UIControlEventTouchUpInside];
    [comboBtn addSubview:arrowBtn];
    [comboBtn addTarget:self action:@selector(comboTapped:) forControlEvents:UIControlEventTouchUpInside];

    UIButton *closeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    closeBtn.frame = CGRectMake(comboBtn.frame.size.width - 24, 0, 20, 32);
    [closeBtn setTitle:@"⤬" forState:UIControlStateNormal];
    [closeBtn setTitleColor:[UIColor colorWithRed:1.0 green:0.23 blue:0.19 alpha:1.0] forState:UIControlStateNormal];
    closeBtn.titleLabel.font = [UIFont systemFontOfSize:15];
    closeBtn.hidden = YES;
    closeBtn.tag = 8889;
    [closeBtn addTarget:self action:@selector(comboCloseTapped:) forControlEvents:UIControlEventTouchUpInside];
    [comboBtn addSubview:closeBtn];

    objc_setAssociatedObject(comboBtn, "comboOptions", options, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(comboBtn, "comboHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(comboBtn, "comboSelectedIndex", @(selectedIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(comboBtn, "comboArrow", arrowBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(comboBtn, "comboCloseBtn", closeBtn, OBJC_ASSOCIATION_RETAIN_NONATOMIC);

    [container addSubview:comboBtn];
    [self addControlView:container height:CGRectGetHeight(container.bounds)];
}

- (void)comboChanged:(UISegmentedControl *)sender {
    MenuComboHandler handler = objc_getAssociatedObject(sender, "menuHandler");
    if (handler) handler(sender.selectedSegmentIndex);
}

- (void)comboTapped:(UIButton *)sender {
    UIButton *comboBtn = nil;
    if (objc_getAssociatedObject(sender, "comboOptions")) {
        comboBtn = sender;
    } else if ([sender.superview isKindOfClass:[UIButton class]]) {
        comboBtn = (UIButton *)sender.superview;
    }
    if (![comboBtn isKindOfClass:[UIButton class]]) return;

    NSArray *options = objc_getAssociatedObject(comboBtn, "comboOptions");
    UIButton *arrow = objc_getAssociatedObject(comboBtn, "comboArrow");
    UIButton *closeBtn = objc_getAssociatedObject(comboBtn, "comboCloseBtn");
    UIView *existingDropdown = objc_getAssociatedObject(comboBtn, "comboDropdown");
    if (existingDropdown && existingDropdown.superview) {
        [self closeComboDropdown:comboBtn];
        return;
    }

    [self closeAllComboDropdowns];
    arrow.hidden = YES;
    closeBtn.hidden = NO;
    closeBtn.alpha = 1.0;

    CGFloat dropdownWidth = comboBtn.frame.size.width;
    CGFloat itemHeight = 32;
    CGFloat maxHeight = 160;
    CGFloat dropdownHeight = MIN(options.count * itemHeight, maxHeight);

    CGPoint containerPoint = [comboBtn convertPoint:CGPointMake(0, CGRectGetMaxY(comboBtn.frame)) toView:self];
    UIView *dropdown = [[UIView alloc] initWithFrame:CGRectMake(containerPoint.x, containerPoint.y, dropdownWidth, dropdownHeight)];
    dropdown.backgroundColor = [UIColor colorWithRed:12.0/255.0 green:12.0/255.0 blue:28.0/255.0 alpha:0.97];
    dropdown.layer.cornerRadius = self.layer.cornerRadius * 0.3;
    dropdown.layer.borderWidth = 1.0;
    dropdown.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.2].CGColor;
    dropdown.layer.shadowColor = [UIColor blackColor].CGColor;
    dropdown.layer.shadowOffset = CGSizeMake(0, 4);
    dropdown.layer.shadowOpacity = 0.3;
    dropdown.layer.shadowRadius = 8;
    dropdown.tag = 7777;
    self.scrollView.scrollEnabled = NO;

    UIScrollView *scrollView = nil;
    if (options.count > 5) {
        scrollView = [[UIScrollView alloc] initWithFrame:dropdown.bounds];
        scrollView.contentSize = CGSizeMake(dropdownWidth, options.count * itemHeight);
        scrollView.showsVerticalScrollIndicator = YES;
        scrollView.indicatorStyle = UIScrollViewIndicatorStyleWhite;
        [dropdown addSubview:scrollView];
    }

    UIView *itemsContainer = scrollView ? scrollView : dropdown;
    for (NSInteger i = 0; i < options.count; i++) {
        UIButton *optionBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        optionBtn.frame = CGRectMake(0, i * itemHeight, dropdownWidth, itemHeight - 1);
        [optionBtn setTitle:options[i] forState:UIControlStateNormal];
        [optionBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
        optionBtn.titleLabel.font = [UIFont systemFontOfSize:10];
        optionBtn.contentHorizontalAlignment = UIControlContentHorizontalAlignmentLeft;
        optionBtn.titleEdgeInsets = UIEdgeInsetsMake(0, 12, 0, 0);
        optionBtn.tag = i;

        NSNumber *selectedIndex = objc_getAssociatedObject(comboBtn, "comboSelectedIndex");
        if (selectedIndex && selectedIndex.integerValue == i) {
            optionBtn.backgroundColor = [self.accentColor colorWithAlphaComponent:0.2];
        } else {
            optionBtn.backgroundColor = [UIColor clearColor];
        }

        [optionBtn addTarget:self action:@selector(comboOptionSelected:) forControlEvents:UIControlEventTouchUpInside];
        [itemsContainer addSubview:optionBtn];

        if (i < options.count - 1) {
            UIView *separator = [[UIView alloc] initWithFrame:CGRectMake(12, itemHeight - 1, dropdownWidth - 24, 1)];
            separator.backgroundColor = [UIColor colorWithWhite:1.0 alpha:0.07];
            [optionBtn addSubview:separator];
        }
    }

    CGFloat maxY = CGRectGetMaxY(self.scrollView.frame);
    if (dropdown.frame.origin.y + dropdownHeight > maxY) {
        dropdown.frame = CGRectMake(containerPoint.x, containerPoint.y - dropdownHeight - comboBtn.frame.size.height, dropdownWidth, dropdownHeight);
    }

    [self addSubview:dropdown];
    objc_setAssociatedObject(comboBtn, "comboDropdown", dropdown, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    objc_setAssociatedObject(dropdown, "comboButton", comboBtn, OBJC_ASSOCIATION_ASSIGN);

    dropdown.alpha = 0;
    dropdown.transform = CGAffineTransformMakeScale(0.95, 0.95);
    [UIView animateWithDuration:0.2 animations:^{
        dropdown.alpha = 1.0;
        dropdown.transform = CGAffineTransformIdentity;
    }];

    UITapGestureRecognizer *tapOutside = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(closeComboDropdownsOnTap:)];
    tapOutside.cancelsTouchesInView = NO;
    [self addGestureRecognizer:tapOutside];
    objc_setAssociatedObject(dropdown, "tapOutsideGesture", tapOutside, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (void)comboCloseTapped:(UIButton *)sender {
    UIButton *comboBtn = (UIButton *)sender.superview;
    if (![comboBtn isKindOfClass:[UIButton class]]) return;
    [self closeComboDropdown:comboBtn];
}

- (UIButton *)comboButtonForDropdown:(UIView *)dropdown inView:(UIView *)view {
    for (UIView *subview in view.subviews) {
        if ([subview isKindOfClass:[UIButton class]] && objc_getAssociatedObject((UIButton *)subview, "comboDropdown") == dropdown) {
            return (UIButton *)subview;
        }
        UIButton *found = [self comboButtonForDropdown:dropdown inView:subview];
        if (found) return found;
    }
    return nil;
}

- (void)comboOptionSelected:(UIButton *)optionBtn {
    UIView *dropdown = optionBtn.superview;
    while (dropdown && dropdown.tag != 7777) {
        dropdown = dropdown.superview;
    }
    if (!dropdown) return;

    UIButton *comboBtn = objc_getAssociatedObject(dropdown, "comboButton");
    if (![comboBtn isKindOfClass:[UIButton class]]) {
        comboBtn = [self comboButtonForDropdown:dropdown inView:self.contentView];
    }
    if (!comboBtn) return;

    NSArray *options = objc_getAssociatedObject(comboBtn, "comboOptions");
    void (^handler)(NSInteger) = objc_getAssociatedObject(comboBtn, "comboHandler");
    NSInteger selectedIndex = optionBtn.tag;
    [comboBtn setTitle:options[selectedIndex] forState:UIControlStateNormal];
    objc_setAssociatedObject(comboBtn, "comboSelectedIndex", @(selectedIndex), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    if (handler) handler(selectedIndex);

    [self closeComboDropdown:comboBtn];
}

- (void)closeComboDropdown:(UIButton *)comboBtn {
    UIView *dropdown = objc_getAssociatedObject(comboBtn, "comboDropdown");
    UIButton *arrow = objc_getAssociatedObject(comboBtn, "comboArrow");
    UIButton *closeBtn = objc_getAssociatedObject(comboBtn, "comboCloseBtn");
    if (dropdown) {
        UITapGestureRecognizer *tapGesture = objc_getAssociatedObject(dropdown, "tapOutsideGesture");
        if (tapGesture) {
            [self removeGestureRecognizer:tapGesture];
        }
        [UIView animateWithDuration:0.2 animations:^{
            dropdown.alpha = 0;
            dropdown.transform = CGAffineTransformMakeScale(0.95, 0.95);
        } completion:^(BOOL finished) {
            [dropdown removeFromSuperview];
        }];
        objc_setAssociatedObject(comboBtn, "comboDropdown", nil, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        self.scrollView.scrollEnabled = YES;
    }
    closeBtn.hidden = YES;
    arrow.hidden = NO;
    arrow.alpha = 1.0;
}

- (void)closeAllComboDropdowns {
    NSArray<UIView *> *subviews = [self.contentView subviews];
    for (UIView *subview in subviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIView *dropdown = objc_getAssociatedObject((UIButton *)subview, "comboDropdown");
            if (dropdown && dropdown.superview) {
                [self closeComboDropdown:(UIButton *)subview];
            }
        }
        for (UIView *child in subview.subviews) {
            if ([child isKindOfClass:[UIButton class]]) {
                UIView *dropdown = objc_getAssociatedObject((UIButton *)child, "comboDropdown");
                if (dropdown && dropdown.superview) {
                    [self closeComboDropdown:(UIButton *)child];
                }
            }
        }
    }
}

- (void)closeComboDropdownsOnTap:(UITapGestureRecognizer *)gesture {
    CGPoint location = [gesture locationInView:self];
    BOOL tappedInDropdown = NO;
    for (UIView *subview in self.subviews) {
        if (subview.tag == 7777) {
            if (CGRectContainsPoint(subview.frame, location)) {
                tappedInDropdown = YES;
                break;
            }
        }
    }
    if (!tappedInDropdown) {
        [self closeAllComboDropdowns];
    }
}

- (void)addThemeSlider:(NSString *)title property:(NSString *)property max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(MenuSliderHandler)handler {
    [self addSlider:title max:max min:min value:value handler:handler];
    UISlider *slider = self.sliders[title];
    if (slider) {
        objc_setAssociatedObject(slider, "themeProp", property, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
}

- (void)addLabel:(NSString *)text {
    UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds) - 32, 24)];
    container.backgroundColor = [UIColor clearColor];

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(container.bounds), CGRectGetHeight(container.bounds))];
    label.text = text;
    label.textColor = [UIColor colorWithWhite:1.0 alpha:0.82];
    label.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    label.numberOfLines = 0;
    [container addSubview:label];

    [self addControlView:container height:CGRectGetHeight(container.bounds)];
}

- (void)setMenuAccentColor:(UIColor *)color {
    if (!color) return;
    self.accentColor = color;
    for (UIButton *button in self.tabButtons) {
        BOOL selected = button.tag == self.selectedTabIndex;
        button.backgroundColor = selected ? [self.accentColor colorWithAlphaComponent:0.22] : [UIColor clearColor];
        button.tintColor = selected ? [UIColor whiteColor] : [UIColor colorWithWhite:1.0 alpha:0.65];
        button.layer.borderColor = selected ? [self.accentColor CGColor] : [UIColor colorWithWhite:1.0 alpha:0.08].CGColor;
        button.layer.borderWidth = selected ? 1.5 : 1.0;
    }
    if (self.selectedTabIndex >= 0 && self.selectedTabIndex < self.tabButtons.count) {
        NSString *tabName = self.tabTitles[self.selectedTabIndex];
        NSDictionary<NSString *, NSString *> *iconMap = @{
            @"esp": @"eye",
            @"aimbot": @"scope",
            @"memory": @"cube.box",
            @"settings": @"gearshape",
            @"cheats": @"hammer",
            @"info": @"info.circle"
        };
        NSString *symbolName = iconMap[[tabName lowercaseString]] ?: @"star";
        if (@available(iOS 13.0, *)) {
            UIImageSymbolConfiguration *iconConfig = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightSemibold];
            self.pillIcon.image = [[UIImage systemImageNamed:symbolName withConfiguration:iconConfig] imageWithTintColor:self.accentColor renderingMode:UIImageRenderingModeAlwaysOriginal];
        }
    }
    for (NSString *key in self.sliders) {
        UISlider *slider = self.sliders[key];
        slider.minimumTrackTintColor = self.accentColor;
    }
    for (NSString *key in self.switches) {
        UISwitch *sw = self.switches[key];
        sw.onTintColor = self.accentColor;
    }
}

- (void)setMenuCornerRadius:(CGFloat)radius {
    self.layer.cornerRadius = radius;
}

- (void)setMenuBorderWidth:(CGFloat)borderWidth {
    self.layer.borderWidth = borderWidth;
}

- (void)updateLayout {
    CGFloat width = CGRectGetWidth(self.bounds);
    CGFloat sidebarWidth = 76.0;
    CGFloat headerHeight = 78.0;
    CGFloat leftPadding = 12.0;
    CGFloat contentStartX = leftPadding + sidebarWidth;
    CGFloat contentWidth = width - contentStartX - 16.0;

    self.tabSidebar.frame = CGRectMake(leftPadding, 12, sidebarWidth, CGRectGetHeight(self.bounds) - 24);
    self.tabScrollView.frame = self.tabSidebar.bounds;
    self.tabContainerView.frame = CGRectMake(0, 0, sidebarWidth, CGRectGetHeight(self.tabContainerView.frame));

    self.pillView.frame = CGRectMake(contentStartX + 16, 16, 178, 42);
    self.searchButton.frame = CGRectMake(CGRectGetWidth(self.pillView.bounds) - 32, (CGRectGetHeight(self.pillView.bounds) - 20) / 2.0, 20, 20);
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 42 - 16, 16, 42, 42);
    self.subtitleLabel.frame = CGRectMake(contentStartX + 16, CGRectGetMaxY(self.pillView.frame) + 10, contentWidth - 32, 16);

    self.scrollView.frame = CGRectMake(contentStartX, headerHeight, contentWidth, CGRectGetHeight(self.bounds) - headerHeight - 28);
    self.contentView.frame = CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds), self.contentHeight);
    self.scrollView.contentSize = CGSizeMake(CGRectGetWidth(self.scrollView.bounds), self.contentHeight);

    self.footerLabel.frame = CGRectMake(contentStartX, CGRectGetHeight(self.bounds) - 30, contentWidth, 20);

    for (UIView *container in self.tabContainers) {
        CGRect frame = container.frame;
        frame.size.width = CGRectGetWidth(self.scrollView.bounds);
        container.frame = frame;
    }

    if (self.selectedTabIndex >= 0 && self.selectedTabIndex < self.tabButtons.count) {
        UIButton *selectedButton = self.tabButtons[self.selectedTabIndex];
        if (selectedButton) {
            selectedButton.layer.borderColor = [self.accentColor CGColor];
        }
    }
}

- (void)layoutSubviews {
    [super layoutSubviews];
    [self updateLayout];
}

- (void)addControlView:(UIView *)view height:(CGFloat)height {
    UIView *container = [self activeContentContainer];
    CGFloat width = CGRectGetWidth(self.scrollView.bounds);
    view.frame = CGRectMake(16, self.contentHeight, width - 32, height);
    [container addSubview:view];

    self.contentHeight += height + 10;
    container.frame = CGRectMake(0, 0, width, self.contentHeight);
    self.contentView.frame = CGRectMake(0, 0, width, self.contentHeight);
    self.scrollView.contentSize = CGSizeMake(width, self.contentHeight);

    if (self.currentTabIndex >= 0 && self.currentTabIndex < self.tabHeights.count) {
        self.tabHeights[self.currentTabIndex] = @(self.contentHeight);
    }
}

- (void)addSwitchWithTitle:(NSString *)title description:(NSString *)description isOn:(BOOL)isOn handler:(MenuSwitchHandler)handler {
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds) - 32, 68)];
    box.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.05];
    box.layer.cornerRadius = 22;
    box.layer.borderWidth = 0.0;
    box.layer.borderColor = [UIColor clearColor].CGColor;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, 16, CGRectGetWidth(box.bounds) - 104, 20)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:15 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor whiteColor];
    [box addSubview:titleLabel];

    UILabel *subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(18, CGRectGetMaxY(titleLabel.frame) + 4, CGRectGetWidth(box.bounds) - 104, 16)];
    subtitleLabel.text = description;
    subtitleLabel.font = [UIFont systemFontOfSize:11 weight:UIFontWeightRegular];
    subtitleLabel.textColor = [UIColor colorWithWhite:1.0 alpha:0.55];
    [box addSubview:subtitleLabel];

    UISwitch *toggle = [[UISwitch alloc] initWithFrame:CGRectMake(CGRectGetWidth(box.bounds) - 66, (CGRectGetHeight(box.bounds) - 31) / 2.0, 51, 31)];
    toggle.onTintColor = [UIColor colorWithRed:110.0/255.0 green:142.0/255.0 blue:251.0/255.0 alpha:1.0];
    toggle.on = isOn;
    [toggle addTarget:self action:@selector(switchChanged:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(toggle, "menuHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [box addSubview:toggle];

    [self addControlView:box height:CGRectGetHeight(box.bounds)];
}

- (void)addSliderWithTitle:(NSString *)title min:(CGFloat)min max:(CGFloat)max value:(CGFloat)value handler:(MenuSliderHandler)handler {
    UIView *box = [[UIView alloc] initWithFrame:CGRectMake(0, 0, CGRectGetWidth(self.scrollView.bounds) - 32, 86)];
    box.backgroundColor = [[UIColor whiteColor] colorWithAlphaComponent:0.05];
    box.layer.cornerRadius = 18.0;
    box.layer.borderWidth = 1.0;
    box.layer.borderColor = [[UIColor whiteColor] colorWithAlphaComponent:0.08].CGColor;

    UILabel *titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, 12, CGRectGetWidth(box.bounds) - 32, 18)];
    titleLabel.text = title;
    titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightSemibold];
    titleLabel.textColor = [UIColor whiteColor];
    [box addSubview:titleLabel];

    UILabel *valueLabel = [[UILabel alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(titleLabel.frame) + 2, CGRectGetWidth(box.bounds) - 32, 16)];
    valueLabel.text = [NSString stringWithFormat:@"%.0f", value];
    valueLabel.font = [UIFont systemFontOfSize:10 weight:UIFontWeightMedium];
    valueLabel.textColor = self.accentColor;
    [box addSubview:valueLabel];

    UISlider *slider = [[UISlider alloc] initWithFrame:CGRectMake(16, CGRectGetMaxY(valueLabel.frame) + 10, CGRectGetWidth(box.bounds) - 32, 24)];
    slider.minimumValue = min;
    slider.maximumValue = max;
    slider.value = value;
    slider.minimumTrackTintColor = self.accentColor;
    UIImage *thumbImage = [self createSliderThumbImage];
    [slider setThumbImage:thumbImage forState:UIControlStateNormal];
    [slider setThumbImage:thumbImage forState:UIControlStateHighlighted];
    [slider addTarget:self action:@selector(sliderChanged:) forControlEvents:UIControlEventValueChanged];
    objc_setAssociatedObject(slider, "menuHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    objc_setAssociatedObject(slider, "valueLabel", valueLabel, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    [box addSubview:slider];

    self.sliders[title] = slider;
    self.sliderLabels[title] = valueLabel;

    [self addControlView:box height:CGRectGetHeight(box.bounds)];
}

- (void)addButtonWithTitle:(NSString *)title handler:(void (^)(void))handler {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeSystem];
    button.backgroundColor = self.accentColor;
    [button setTitle:title forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    button.titleLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightBold];
    button.layer.cornerRadius = 12.0;
    objc_setAssociatedObject(button, "menuHandler", handler, OBJC_ASSOCIATION_COPY_NONATOMIC);
    [button addTarget:self action:@selector(buttonTapped:) forControlEvents:UIControlEventTouchUpInside];

    [self addControlView:button height:42];
}

- (void)switchChanged:(UISwitch *)sender {
    MenuSwitchHandler handler = objc_getAssociatedObject(sender, "menuHandler");
    if (!handler) {
        handler = objc_getAssociatedObject(sender, "switchHandler");
    }
    if (handler) handler(sender.on);
}

- (void)sliderValueChanged:(UISlider *)sender {
    [self sliderChanged:sender];
}

- (void)sliderChanged:(UISlider *)sender {
    UILabel *label = objc_getAssociatedObject(sender, "valueLabel");
    if ([label isKindOfClass:[UILabel class]]) {
        label.text = [NSString stringWithFormat:@"%.1f", sender.value];
    }
    MenuSliderHandler handler = objc_getAssociatedObject(sender, "menuHandler");
    if (handler) handler(sender.value);
    void (^sliderHandler)(CGFloat) = objc_getAssociatedObject(sender, "sliderHandler");
    if (sliderHandler) sliderHandler(sender.value);

    NSString *themeProp = objc_getAssociatedObject(sender, "themeProp");
    if ([themeProp isEqualToString:@"opacity"]) {
        self.alpha = sender.value;
    } else if ([themeProp isEqualToString:@"corner"]) {
        [self setMenuCornerRadius:sender.value];
    } else if ([themeProp isEqualToString:@"border"]) {
        [self setMenuBorderWidth:sender.value];
    }
}

- (UIImage *)createSliderThumbImage {
    CGFloat thumbSize = 12.0;
    UIGraphicsBeginImageContextWithOptions(CGSizeMake(thumbSize, thumbSize), NO, 0.0);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGRect thumbRect = CGRectMake(0, 0, thumbSize, thumbSize);
    CGContextSetFillColorWithColor(context, [UIColor whiteColor].CGColor);
    CGContextFillEllipseInRect(context, thumbRect);
    CGContextSetStrokeColorWithColor(context, [UIColor colorWithWhite:0.3 alpha:1.0].CGColor);
    CGContextSetLineWidth(context, 0.5);
    CGContextStrokeEllipseInRect(context, thumbRect);
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return image;
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
