#import "MenuView.h"
#import <objc/runtime.h>

@interface MenuView ()
@property (nonatomic, assign) CGFloat contentHeight;
@property (nonatomic, strong) UIView *pillView; // Original pillView, might not be used in new UI
@property (nonatomic, strong) UIView *contentHeaderView; // Original contentHeaderView, might not be used in new UI
@property (nonatomic, strong) UIView *headerTitleView; // Original headerTitleView, might not be used in new UI
@property (nonatomic, strong) UIImageView *headerIconImageView; // Original headerIconImageView, might not be used in new UI
@property (nonatomic, strong) UILabel *headerTitleLabel; // Original headerTitleLabel, might not be used in new UI
@property (nonatomic, strong) UIButton *searchButton; // Original searchButton, might not be used in new UI
@property (nonatomic, strong) UIButton *themeToggleButton; // Original themeToggleButton, might not be used in new UI
@property (nonatomic, strong) NSMutableArray<UIView *> *tabContainers; // Original tabContainers, might not be used in new UI
@property (nonatomic, strong) NSMutableArray<NSNumber *> *tabHeights; // Original tabHeights, might not be used in new UI
@property (nonatomic, strong) NSArray<NSString *> *tabTitles; // Original tabTitles, might not be used in new UI
@property (nonatomic, assign) NSInteger currentTabIndex; // Original currentTabIndex, might not be used in new UI
@property (nonatomic, strong) UILabel *footerLabel; // Original footerLabel, might not be used in new UI

// New UI Elements
@property (nonatomic, strong) UIView *mainContainerView;
@property (nonatomic, strong) UIView *sidebarView;
@property (nonatomic, strong) UIStackView *sidebarStackView;
@property (nonatomic, strong) UIView *mainContentView;
@property (nonatomic, strong) UIView *headerView;
@property (nonatomic, strong) UIView *titleBadgeView;
@property (nonatomic, strong) UIImageView *titleBadgeIcon;
@property (nonatomic, strong) UILabel *titleBadgeLabel;
@property (nonatomic, strong) UIStackView *headerIconsStackView;
@property (nonatomic, strong) UIButton *downloadButton;
@property (nonatomic, strong) UIButton *moonButton;
// Removed redeclaration of closeButton as it's in .h
@property (nonatomic, strong) UIStackView *menuItemsStackView;
@property (nonatomic, strong) UILabel *aimKillHintLabel;

- (void)customizeScrollIndicator;
- (void)addControlView:(UIView *)control height:(CGFloat)height; // Forward declaration for internal use
- (void)closeAllComboDropdowns; // Forward declaration for internal use
- (void)closeComboDropdown:(UIButton *)comboBtn; // Forward declaration for internal use

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

    // Clear existing subviews if any, to ensure a clean slate for the new UI
    for (UIView *subview in self.subviews) {
        [subview removeFromSuperview];
    }

    // Main Container View (mimics the dark rounded rectangle)
    self.mainContainerView = [[UIView alloc] initWithFrame:self.bounds];
    self.mainContainerView.backgroundColor = [UIColor colorWithRed:0.06 green:0.05 blue:0.03 alpha:1.0]; // Dark background
    self.mainContainerView.layer.cornerRadius = 30.0; // More rounded corners
    self.mainContainerView.layer.masksToBounds = YES;
    self.mainContainerView.layer.borderColor = [UIColor colorWithRed:0.1 green:0.08 blue:0.05 alpha:1.0].CGColor; // Border color
    self.mainContainerView.layer.borderWidth = 1.0;
    [self addSubview:self.mainContainerView];

    // Sidebar View
    CGFloat sidebarWidth = 70.0;
    self.sidebarView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, self.mainContainerView.bounds.size.height)];
    self.sidebarView.backgroundColor = [UIColor colorWithRed:0.06 green:0.05 blue:0.03 alpha:1.0]; // Same as main container
    self.sidebarView.layer.borderColor = [UIColor colorWithRed:0.1 green:0.08 blue:0.05 alpha:1.0].CGColor; // Border color
    self.sidebarView.layer.borderWidth = 1.0;
    [self.mainContainerView addSubview:self.sidebarView];

    // Sidebar Icons (using UIStackView for vertical layout)
    self.sidebarStackView = [[UIStackView alloc] init];
    self.sidebarStackView.axis = UILayoutConstraintAxisVertical;
    self.sidebarStackView.distribution = UIStackViewDistributionFillEqually;
    self.sidebarStackView.alignment = UIStackViewAlignmentCenter;
    self.sidebarStackView.spacing = 25.0;
    self.sidebarStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.sidebarView addSubview:self.sidebarStackView];

    [NSLayoutConstraint activateConstraints:@[
        [self.sidebarStackView.topAnchor constraintEqualToAnchor:self.sidebarView.topAnchor constant:20],
        [self.sidebarStackView.leadingAnchor constraintEqualToAnchor:self.sidebarView.leadingAnchor],
        [self.sidebarStackView.trailingAnchor constraintEqualToAnchor:self.sidebarView.trailingAnchor],
        [self.sidebarStackView.bottomAnchor constraintEqualToAnchor:self.sidebarView.bottomAnchor constant:-20]
    ]];

    // Add sidebar icons
    [self addSidebarIconWithSystemName:@"eye" isActive:NO];
    [self addSidebarIconWithSystemName:@"scope" isActive:YES];
    [self addSidebarIconWithSystemName:@"gamecontroller" isActive:NO];
    [self addSidebarIconWithSystemName:@"gearshape" isActive:NO];
    [self addSidebarIconWithSystemName:@"slider.horizontal.3" isActive:NO];

    // Main Content View
    self.mainContentView = [[UIView alloc] initWithFrame:CGRectMake(sidebarWidth, 0, self.mainContainerView.bounds.size.width - sidebarWidth, self.mainContainerView.bounds.size.height)];
    self.mainContentView.backgroundColor = [UIColor clearColor]; // Transparent to show mainContainerView's background
    [self.mainContainerView addSubview:self.mainContentView];

    // Header View
    self.headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.mainContentView.bounds.size.width, 70)]; // Adjust height as needed
    self.headerView.backgroundColor = [UIColor clearColor];
    [self.mainContentView addSubview:self.headerView];

    // Title Badge (AIMBOT)
    self.titleBadgeView = [[UIView alloc] init];
    self.titleBadgeView.backgroundColor = [UIColor colorWithRed:0.1 green:0.08 blue:0.05 alpha:1.0]; // Item background color
    self.titleBadgeView.layer.cornerRadius = 20.0;
    self.titleBadgeView.layer.borderColor = [UIColor colorWithRed:0.2 green:0.15 blue:0.06 alpha:1.0].CGColor;
    self.titleBadgeView.layer.borderWidth = 1.0;
    self.titleBadgeView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.titleBadgeView];

    self.titleBadgeIcon = [[UIImageView alloc] init];
    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:18 weight:UIImageSymbolWeightSemibold];
        self.titleBadgeIcon.image = [[UIImage systemImageNamed:@"scope" withConfiguration:config] imageWithTintColor:[UIColor colorWithRed:1.0 green:0.62 blue:0.0 alpha:1.0] renderingMode:UIImageRenderingModeAlwaysOriginal];
    }
    self.titleBadgeIcon.contentMode = UIViewContentModeScaleAspectFit;
    self.titleBadgeIcon.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleBadgeView addSubview:self.titleBadgeIcon];

    self.titleBadgeLabel = [[UILabel alloc] init];
    self.titleBadgeLabel.text = @"AIMBOT";
    self.titleBadgeLabel.textColor = [UIColor colorWithRed:1.0 green:0.62 blue:0.0 alpha:1.0];
    self.titleBadgeLabel.font = [UIFont systemFontOfSize:18 weight:UIFontWeightBold];
    self.titleBadgeLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.titleBadgeView addSubview:self.titleBadgeLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.titleBadgeView.leadingAnchor constraintEqualToAnchor:self.headerView.leadingAnchor constant:20],
        [self.titleBadgeView.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor],
        [self.titleBadgeView.heightAnchor constraintEqualToConstant:40],
        [self.titleBadgeIcon.leadingAnchor constraintEqualToAnchor:self.titleBadgeView.leadingAnchor constant:15],
        [self.titleBadgeIcon.centerYAnchor constraintEqualToAnchor:self.titleBadgeView.centerYAnchor],
        [self.titleBadgeIcon.widthAnchor constraintEqualToConstant:24],
        [self.titleBadgeIcon.heightAnchor constraintEqualToConstant:24],
        [self.titleBadgeLabel.leadingAnchor constraintEqualToAnchor:self.titleBadgeIcon.trailingAnchor constant:8],
        [self.titleBadgeLabel.trailingAnchor constraintEqualToAnchor:self.titleBadgeView.trailingAnchor constant:-15],
        [self.titleBadgeLabel.centerYAnchor constraintEqualToAnchor:self.titleBadgeView.centerYAnchor]
    ]];

    // Header Action Icons
    self.headerIconsStackView = [[UIStackView alloc] init];
    self.headerIconsStackView.axis = UILayoutConstraintAxisHorizontal;
    self.headerIconsStackView.distribution = UIStackViewDistributionFillEqually;
    self.headerIconsStackView.alignment = UIStackViewAlignmentCenter;
    self.headerIconsStackView.spacing = 10.0;
    self.headerIconsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.headerView addSubview:self.headerIconsStackView];

    [NSLayoutConstraint activateConstraints:@[
        [self.headerIconsStackView.trailingAnchor constraintEqualToAnchor:self.headerView.trailingAnchor constant:-20],
        [self.headerIconsStackView.centerYAnchor constraintEqualToAnchor:self.headerView.centerYAnchor]
    ]];

    self.downloadButton = [self createHeaderActionButtonWithSystemName:@"square.and.arrow.down"];
    self.moonButton = [self createHeaderActionButtonWithSystemName:@"moon.fill"];
    self.closeButton = [self createHeaderActionButtonWithSystemName:@"xmark"];

    [self.headerIconsStackView addArrangedSubview:self.downloadButton];
    [self.headerIconsStackView addArrangedSubview:self.moonButton];
    [self.headerIconsStackView addArrangedSubview:self.closeButton];

    // Menu Items Stack View
    self.menuItemsStackView = [[UIStackView alloc] init];
    self.menuItemsStackView.axis = UILayoutConstraintAxisVertical;
    self.menuItemsStackView.distribution = UIStackViewDistributionFill;
    self.menuItemsStackView.alignment = UIStackViewAlignmentFill;
    self.menuItemsStackView.spacing = 12.0;
    self.menuItemsStackView.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainContentView addSubview:self.menuItemsStackView];

    [NSLayoutConstraint activateConstraints:@[
        [self.menuItemsStackView.topAnchor constraintEqualToAnchor:self.headerView.bottomAnchor constant:10],
        [self.menuItemsStackView.leadingAnchor constraintEqualToAnchor:self.mainContentView.leadingAnchor constant:20],
        [self.menuItemsStackView.trailingAnchor constraintEqualToAnchor:self.mainContentView.trailingAnchor constant:-20]
    ]];

    // Add Menu Items
    [self addMenuItemWithTitle:@"Enable Aimbot"];
    [self addMenuItemWithTitle:@"Aimsilent"];
    [self addMenuItemWithTitle:@"Show Extra Animation"];
    [self addMenuItemWithTitle:@"Aim Kill"];

    // Hint Text
    self.aimKillHintLabel = [[UILabel alloc] init];
    self.aimKillHintLabel.text = @"To turn on Aim Kill fast, select HEADv2 below";
    self.aimKillHintLabel.textColor = [UIColor colorWithRed:1.0 green:0.62 blue:0.0 alpha:1.0]; // Accent orange
    self.aimKillHintLabel.font = [UIFont systemFontOfSize:13 weight:UIFontWeightRegular];
    self.aimKillHintLabel.translatesAutoresizingMaskIntoConstraints = NO;
    [self.mainContentView addSubview:self.aimKillHintLabel];

    [NSLayoutConstraint activateConstraints:@[
        [self.aimKillHintLabel.topAnchor constraintEqualToAnchor:self.menuItemsStackView.bottomAnchor constant:5],
        [self.aimKillHintLabel.leadingAnchor constraintEqualToAnchor:self.mainContentView.leadingAnchor constant:30] // Indent slightly
    ]];

    [self addMenuItemWithTitle:@"AutoFire"];

    // Adjust main content view frame to fit all items
    [self.mainContentView layoutIfNeeded];
    CGFloat newContentHeight = self.menuItemsStackView.frame.origin.y + self.menuItemsStackView.frame.size.height + self.aimKillHintLabel.frame.size.height + 20; // Add some padding
    self.mainContainerView.frame = CGRectMake(self.frame.origin.x, self.frame.origin.y, self.frame.size.width, newContentHeight + self.headerView.frame.size.height + 20); // Adjust main container height
    self.frame = self.mainContainerView.frame;

    // Ensure the main container view is resized to fit its content
    [self.mainContainerView layoutIfNeeded];
    self.mainContainerView.frame = self.bounds;

    // Existing properties that might be needed for functionality but not directly for UI rendering
    self.accentColor = [UIColor colorWithRed:1.0 green:0.62 blue:0.0 alpha:1.0]; // Updated accent color
    // self.tabButtons = [NSMutableArray array]; // Not used in new UI structure
    // self.tabContainers = [NSMutableArray array]; // Not used in new UI structure
    // self.tabHeights = [NSMutableArray array]; // Not used in new UI structure
    // self.switches = [NSMutableDictionary dictionary]; // Will be managed by new menu items
    // self.sliders = [NSMutableDictionary dictionary];
    // self.sliderLabels = [NSMutableDictionary dictionary];
    // self.buttons = [NSMutableDictionary dictionary];
    // self.textFields = [NSMutableDictionary dictionary];

    // Remove or comment out old UI elements that are no longer needed
    // self.blurEffectView = [[UIVisualEffectView alloc] initWithEffect:blurEffect];
    // self.gradientOverlay = [[UIView alloc] initWithFrame:self.bounds];
    // self.tabSidebar = [[UIView alloc] initWithFrame:CGRectMake(12, 12, sidebarWidth, CGRectGetHeight(self.bounds) - 24)];
    // self.tabScrollView = [[UIScrollView alloc] initWithFrame:self.tabSidebar.bounds];
    // self.tabContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, 0)];
    // self.pillView = [[UIView alloc] initWithFrame:CGRectMake(contentStartX + 16, titleY, 178, pillHeight)];
    // self.pillIcon = [[UIImageView alloc] initWithFrame:CGRectMake(12, (pillHeight - 20) / 2.0, 20, 20)];
    // self.tabTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(40, 0, self.pillView.frame.size.width - 48, pillHeight)];
    // self.searchButton = [UIButton buttonWithType:UIButtonTypeCustom];
    // self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom]; // Replaced by new close button
    // self.subtitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentStartX + 16, subtitleY, contentWidth - 32, 16)];
    // self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(contentStartX, headerHeight, contentWidth, CGRectGetHeight(self.bounds) - headerHeight - 28)];
    // self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 0)];
    // self.footerLabel = [[UILabel alloc] initWithFrame:CGRectMake(contentStartX, CGRectGetHeight(self.bounds) - 30, contentWidth, 25)];
}

- (void)addSidebarIconWithSystemName:(NSString *)systemName isActive:(BOOL)isActive {
    UIButton *iconButton = [UIButton buttonWithType:UIButtonTypeCustom];
    iconButton.translatesAutoresizingMaskIntoConstraints = NO;
    [iconButton.widthAnchor constraintEqualToConstant:45].active = YES;
    [iconButton.heightAnchor constraintEqualToConstant:45].active = YES;
    iconButton.layer.cornerRadius = 22.5;
    iconButton.layer.masksToBounds = YES;

    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:24 weight:UIImageSymbolWeightRegular];
        UIImage *image = [UIImage systemImageNamed:systemName withConfiguration:config];
        [iconButton setImage:image forState:UIControlStateNormal];
    }

    if (isActive) {
        iconButton.tintColor = [UIColor colorWithRed:1.0 green:0.62 blue:0.0 alpha:1.0]; // Accent orange
        iconButton.layer.borderColor = [UIColor colorWithRed:1.0 green:0.62 blue:0.0 alpha:1.0].CGColor;
        iconButton.layer.borderWidth = 2.0;
    } else {
        iconButton.tintColor = [UIColor colorWithWhite:0.4 alpha:1.0]; // Icon gray
    }
    [self.sidebarStackView addArrangedSubview:iconButton];
}

- (UIButton *)createHeaderActionButtonWithSystemName:(NSString *)systemName {
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    button.translatesAutoresizingMaskIntoConstraints = NO;
    [button.widthAnchor constraintEqualToConstant:40].active = YES;
    [button.heightAnchor constraintEqualToConstant:40].active = YES;
    button.layer.cornerRadius = 20.0;
    button.backgroundColor = [UIColor colorWithRed:0.1 green:0.08 blue:0.05 alpha:1.0]; // Item background color
    button.layer.borderColor = [UIColor colorWithRed:0.2 green:0.15 blue:0.06 alpha:1.0].CGColor;
    button.layer.borderWidth = 1.0;

    if (@available(iOS 13.0, *)) {
        UIImageSymbolConfiguration *config = [UIImageSymbolConfiguration configurationWithPointSize:20 weight:UIImageSymbolWeightRegular];
        UIImage *image = [UIImage systemImageNamed:systemName withConfiguration:config];
        [button setImage:image forState:UIControlStateNormal];
    }
    button.tintColor = [UIColor colorWithRed:1.0 green:0.62 blue:0.0 alpha:1.0]; // Accent orange
    return button;
}

- (void)addMenuItemWithTitle:(NSString *)title {
    UIView *menuItemView = [[UIView alloc] init];
    menuItemView.backgroundColor = [UIColor colorWithRed:0.1 green:0.08 blue:0.05 alpha:1.0]; // Item background color
    menuItemView.layer.cornerRadius = 30.0;
    menuItemView.layer.borderColor = [UIColor colorWithRed:0.2 green:0.15 blue:0.06 alpha:1.0].CGColor;
    menuItemView.layer.borderWidth = 1.0;
    menuItemView.translatesAutoresizingMaskIntoConstraints = NO;
    [menuItemView.heightAnchor constraintEqualToConstant:60].active = YES; // Fixed height for menu item

    UILabel *label = [[UILabel alloc] init];
    label.text = title;
    label.textColor = [UIColor whiteColor];
    label.font = [UIFont systemFontOfSize:16 weight:UIFontWeightMedium];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [menuItemView addSubview:label];

    UIView *toggleSwitch = [[UIView alloc] init]; // Placeholder for custom toggle switch
    toggleSwitch.backgroundColor = [UIColor colorWithWhite:0.26 alpha:1.0]; // Toggle off color
    toggleSwitch.layer.cornerRadius = 14.0;
    toggleSwitch.translatesAutoresizingMaskIntoConstraints = NO;
    [toggleSwitch.widthAnchor constraintEqualToConstant:28].active = YES;
    [toggleSwitch.heightAnchor constraintEqualToConstant:28].active = YES;
    [menuItemView addSubview:toggleSwitch];

    [NSLayoutConstraint activateConstraints:@[
        [label.leadingAnchor constraintEqualToAnchor:menuItemView.leadingAnchor constant:25],
        [label.centerYAnchor constraintEqualToAnchor:menuItemView.centerYAnchor],
        [toggleSwitch.trailingAnchor constraintEqualToAnchor:menuItemView.trailingAnchor constant:-25],
        [toggleSwitch.centerYAnchor constraintEqualToAnchor:menuItemView.centerYAnchor]
    ]];

    [self.menuItemsStackView addArrangedSubview:menuItemView];
}

#pragma mark - Original MenuView.h methods implementation

- (void)setMenuTitle:(NSString *)title {
    self.titleBadgeLabel.text = title; // Use the new titleBadgeLabel
}

- (void)setMenuSubtitle:(NSString *)subtitle {
    self.aimKillHintLabel.text = subtitle; // Use the new aimKillHintLabel
}

- (void)setFooterText:(NSString *)text {
    // The new UI does not have a dedicated footer label. This method will do nothing.
    NSLog(@"setFooterText: method called, but footer is not visible in the new UI.");
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
    // The new UI uses a solid background, not a blur effect. This method will do nothing.
    NSLog(@"setMenuGlassEffect: method called, but glass effect is not used in the new UI.");
}

- (void)customizeScrollIndicator {
    // This method was related to the old tabScrollView, which is no longer present.
    NSLog(@"customizeScrollIndicator: method called, but scroll indicator customization is not applicable to the new UI.");
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

- (BOOL)gestureRecognizer:(UIGestureRecognizer *)gestureRecognizer shouldRecognizeSimultaneouslyWithGestureRecognizer:(UIGestureRecognizer *)otherGestureRecognizer {
    return YES;
}

- (void)closeButtonTapped:(UIButton *)sender {
    // Implement closing logic here
    [self removeFromSuperview];
}

- (void)addFeatureSwitch:(NSString *)title description:(NSString *)desc isOn:(BOOL)isOn handler:(MenuSwitchHandler)handler {
    // This method is for dynamically adding switches, which is not part of the static UI.
    // We will create a static menu item for now.
    [self addMenuItemWithTitle:title];
    // You might want to store the handler and state if this feature needs to be interactive later.
    NSLog(@"addFeatureSwitch:description:isOn:handler: called for '%@'. Feature added as a static menu item.", title);
}

- (void)addFeatureSwitch:(NSString *)title {
    // This method is for dynamically adding switches, which is not part of the static UI.
    [self addMenuItemWithTitle:title];
    NSLog(@"addFeatureSwitch: called for '%@'. Feature added as a static menu item.", title);
}

- (void)addSlider:(NSString *)title min:(CGFloat)min max:(CGFloat)max value:(CGFloat)value handler:(MenuSliderHandler)handler {
    // This method is for dynamically adding sliders, which is not part of the static UI.
    NSLog(@"addSlider:min:max:value:handler: called for '%@'. Sliders are not directly supported in the current static UI.", title);
}

- (void)addSlider:(NSString *)title max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(void (^)(CGFloat value))handler {
    // This method is for dynamically adding sliders, which is not part of the static UI.
    NSLog(@"addSlider:max:min:value:handler: called for '%@'. Sliders are not directly supported in the current static UI.", title);
}

- (void)addButton:(NSString *)title withHandler:(MenuButtonHandler)handler {
    // This method is for dynamically adding buttons, which is not part of the static UI.
    NSLog(@"addButton:withHandler: called for '%@'. Buttons are not directly supported in the current static UI.", title);
}

- (void)addComboSelector:(NSString *)title options:(NSArray *)options selectedIndex:(NSInteger)index handler:(MenuComboHandler)handler {
    // This method is for dynamically adding combo selectors, which is not part of the static UI.
    NSLog(@"addComboSelector: called for '%@'. Combo selectors are not directly supported in the current static UI.", title);
}

- (void)addTextField:(NSString *)title placeholder:(NSString *)placeholder handler:(MenuTextFieldHandler)handler {
    // This method is for dynamically adding text fields, which is not part of the static UI.
    NSLog(@"addTextField: called for '%@'. Text fields are not directly supported in the current static UI.", title);
}

- (void)addLabel:(NSString *)text {
    // This method is for dynamically adding labels. For now, we'll just log it.
    NSLog(@"addLabel: called with text: '%@'. Labels are not dynamically added in the current static UI.", text);
}

- (void)addSectionTitle:(NSString *)title {
    // This method is for dynamically adding section titles. For now, we'll just log it.
    NSLog(@"addSectionTitle: called with title: '%@'. Section titles are not dynamically added in the current static UI.", title);
}

- (void)setTabIndex:(NSInteger)index {
    // This method is for setting the active tab in the old UI. Not applicable to the new static UI.
    NSLog(@"setTabIndex: called with index: %ld. Tab index is not applicable to the new static UI.", (long)index);
}

- (void)addTab:(NSArray<NSString *> *)tabNames {
    // This method is for dynamically adding tabs to the old sidebar. Not applicable to the new static UI.
    NSLog(@"addTab: called with tabNames: %@. Tabs are not dynamically added in the new static UI.", tabNames);
}

- (void)addThemeSlider:(NSString *)title property:(NSString *)prop max:(CGFloat)max min:(CGFloat)min value:(CGFloat)value handler:(MenuSliderHandler)handler {
    // This method is for dynamically adding theme sliders. Not applicable to the new static UI.
    NSLog(@"addThemeSlider: called for '%@'. Theme sliders are not directly supported in the current static UI.", title);
}

- (void)updateLayout {
    // This method was likely used to re-layout the old dynamic UI. The new UI uses Auto Layout and layoutSubviews.
    [self setNeedsLayout];
    [self layoutIfNeeded];
    NSLog(@"updateLayout: called. Layout is handled by Auto Layout and layoutSubviews.");
}

- (void)setMenuAccentColor:(UIColor *)color {
    self.accentColor = color;
    // You might want to update the tint color of icons or other elements here if they depend on accentColor.
    if (@available(iOS 13.0, *)) {
        self.titleBadgeIcon.image = [self.titleBadgeIcon.image imageWithTintColor:color renderingMode:UIImageRenderingModeAlwaysOriginal];
    } else {
        // Fallback for older iOS versions if needed, or just keep original image
        self.titleBadgeIcon.image = [self.titleBadgeIcon.image imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        self.titleBadgeIcon.tintColor = color;
    }
    self.titleBadgeLabel.textColor = color;
    self.aimKillHintLabel.textColor = color;
    for (UIView *subview in self.sidebarStackView.arrangedSubviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            if (button.layer.borderWidth > 0) { // Assuming active icon has a border
                button.tintColor = color;
                button.layer.borderColor = color.CGColor;
            }
        }
    }
    for (UIView *subview in self.headerIconsStackView.arrangedSubviews) {
        if ([subview isKindOfClass:[UIButton class]]) {
            UIButton *button = (UIButton *)subview;
            button.tintColor = color;
        }
    }
}

- (void)setMenuCornerRadius:(CGFloat)radius {
    self.mainContainerView.layer.cornerRadius = radius;
    self.layer.cornerRadius = radius; // Apply to self as well if it's the main view
}

- (void)setMenuBorderWidth:(CGFloat)width {
    self.mainContainerView.layer.borderWidth = width;
    self.layer.borderWidth = width; // Apply to self as well if it's the main view
}

- (void)closeMenu {
    [self removeFromSuperview];
}

#pragma mark - Internal Helper Methods (from original code, adapted or kept)

- (void)textFieldChanged:(UITextField *)sender {
    MenuTextFieldHandler handler = objc_getAssociatedObject(sender, "menuHandler");
    if (handler) handler(sender.text ?: @"");
}

// Placeholder implementations for original combo selector methods to satisfy the protocol
- (void)comboChanged:(UISegmentedControl *)sender {
    MenuComboHandler handler = objc_getAssociatedObject(sender, "menuHandler");
    if (handler) handler(sender.selectedSegmentIndex);
}

- (void)comboTapped:(UIButton *)sender {
    NSLog(@"comboTapped: called. This functionality is not part of the new static UI.");
}

- (void)comboCloseTapped:(UIButton *)sender {
    NSLog(@"comboCloseTapped: called. This functionality is not part of the new static UI.");
}

- (UIButton *)comboButtonForDropdown:(UIView *)dropdown inView:(UIView *)view {
    NSLog(@"comboButtonForDropdown:inView: called. This functionality is not part of the new static UI.");
    return nil;
}

- (void)comboOptionSelected:(UIButton *)optionBtn {
    NSLog(@"comboOptionSelected: called. This functionality is not part of the new static UI.");
}

- (void)closeComboDropdown:(UIButton *)comboBtn {
    NSLog(@"closeComboDropdown: called. This functionality is not part of the new static UI.");
}

- (void)closeAllComboDropdowns {
    NSLog(@"closeAllComboDropdowns: called. This functionality is not part of the new static UI.");
}

- (void)addControlView:(UIView *)control height:(CGFloat)height {
    // This method was used by the old dynamic UI to add controls to the scroll view.
    // In the new static UI, controls are added directly to menuItemsStackView.
    NSLog(@"addControlView:height: called. Controls are added directly to menuItemsStackView in the new UI.");
}

#pragma mark - Touch Handling (from original code)

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
}

- (void)layoutSubviews {
    [super layoutSubviews];
    self.mainContainerView.frame = self.bounds;
    self.sidebarView.frame = CGRectMake(0, 0, 70, self.bounds.size.height);
    self.mainContentView.frame = CGRectMake(70, 0, self.bounds.size.width - 70, self.bounds.size.height);
    self.headerView.frame = CGRectMake(0, 0, self.mainContentView.bounds.size.width, 70);

    // Recalculate content height for dynamic sizing if needed
    CGFloat currentY = self.headerView.frame.size.height + 10; // Start after header + padding
    for (UIView *arrangedSubview in self.menuItemsStackView.arrangedSubviews) {
        currentY += arrangedSubview.frame.size.height + self.menuItemsStackView.spacing;
    }
    currentY += self.aimKillHintLabel.frame.size.height + 20; // Add hint label height and bottom padding

    // Adjust the height of the main container and self to fit content
    CGFloat desiredHeight = currentY;
    if (self.frame.size.height != desiredHeight) {
        CGRect newFrame = self.frame;
        newFrame.size.height = desiredHeight;
        self.frame = newFrame;
        self.mainContainerView.frame = self.bounds;
        self.sidebarView.frame = CGRectMake(0, 0, 70, self.bounds.size.height);
        self.mainContentView.frame = CGRectMake(70, 0, self.bounds.size.width - 70, self.bounds.size.height);
    }
}

@end
