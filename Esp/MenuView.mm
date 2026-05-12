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
@end

@implementation MenuView

// --- สีตามต้นฉบับ ---
#define COLOR_BG_MAIN       [UIColor colorWithRed:0.12f green:0.08f blue:0.06f alpha:1.0] // ดำ-น้ำตาลเข้ม
#define COLOR_BG_ROW        [UIColor colorWithRed:0.18f green:0.13f blue:0.10f alpha:1.0] // แถบเมนู
#define COLOR_ACCENT_GOLD   [UIColor colorWithRed:1.00f green:0.71f blue:0.29f alpha:1.0] // สีทอง
#define COLOR_TEXT_MAIN     [UIColor whiteColor]
#define COLOR_TEXT_DIM      [UIColor colorWithWhite:1.0 alpha:0.6]

+ (instancetype)menuWithFrame:(CGRect)frame {
    MenuView *menu = [[MenuView alloc] initWithFrame:frame];
    [menu setup];
    return menu;
}

- (void)setup {
    // Main Background
    self.backgroundColor = COLOR_BG_MAIN;
    self.layer.cornerRadius = 30.0;
    self.layer.masksToBounds = YES;
    self.layer.borderWidth = 1.0;
    self.layer.borderColor = [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.3].CGColor;

    self.currentTabIndex = 0;
    self.tabButtons = [NSMutableArray array];
    self.tabContainers = [NSMutableArray array];
    self.tabHeights = [NSMutableArray array];

    CGFloat sidebarWidth = 75;
    CGFloat headerHeight = 80;
    CGFloat contentStartX = sidebarWidth + 15;
    CGFloat contentWidth = CGRectGetWidth(self.bounds) - contentStartX - 15;

    // --- Sidebar (แถบเมนูด้านซ้าย) ---
    self.tabSidebar = [[UIView alloc] initWithFrame:CGRectMake(10, 10, sidebarWidth, CGRectGetHeight(self.bounds) - 20)];
    self.tabSidebar.backgroundColor = [COLOR_BG_MAIN colorWithAlphaComponent:0.5];
    self.tabSidebar.layer.cornerRadius = 20.0;
    [self addSubview:self.tabSidebar];

    self.tabScrollView = [[UIScrollView alloc] initWithFrame:self.tabSidebar.bounds];
    self.tabScrollView.showsVerticalScrollIndicator = NO;
    [self.tabSidebar addSubview:self.tabScrollView];

    self.tabContainerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, sidebarWidth, 0)];
    [self.tabScrollView addSubview:self.tabContainerView];

    // --- Header Pill (ส่วนหัวที่เปลี่ยนชื่อตาม Tab) ---
    self.pillView = [[UIView alloc] initWithFrame:CGRectMake(contentStartX, 20, 160, 40)];
    self.pillView.backgroundColor = [COLOR_BG_ROW colorWithAlphaComponent:0.8];
    self.pillView.layer.cornerRadius = 20;
    self.pillView.layer.borderWidth = 1.0;
    self.pillView.layer.borderColor = [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.5].CGColor;
    [self addSubview:self.pillView];

    self.tabTitleLabel = [[UILabel alloc] initWithFrame:CGRectMake(35, 0, 120, 40)];
    self.tabTitleLabel.text = @"MENU";
    self.tabTitleLabel.textColor = COLOR_ACCENT_GOLD;
    self.tabTitleLabel.font = [UIFont systemFontOfSize:16 weight:UIFontWeightBold];
    self.tabTitleLabel.textAlignment = NSTextAlignmentCenter;
    [self.pillView addSubview:self.tabTitleLabel];

    // Close Button (X)
    self.closeButton = [UIButton buttonWithType:UIButtonTypeCustom];
    self.closeButton.frame = CGRectMake(CGRectGetWidth(self.bounds) - 50, 20, 30, 30);
    self.closeButton.backgroundColor = [COLOR_BG_ROW colorWithAlphaComponent:0.8];
    self.closeButton.layer.cornerRadius = 15;
    [self.closeButton setTitle:@"✕" forState:UIControlStateNormal];
    [self.closeButton setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [self.closeButton addTarget:self action:@selector(closeMenu) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:self.closeButton];

    // --- Content ScrollView ---
    self.scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(contentStartX, headerHeight, contentWidth, CGRectGetHeight(self.bounds) - headerHeight - 20)];
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.backgroundColor = [UIColor clearColor];
    [self addSubview:self.scrollView];

    self.contentView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, contentWidth, 0)];
    [self.scrollView addSubview:self.contentView];
}

// --- ฟังก์ชันเพิ่ม Tab แบบในรูป ---
- (void)addTab:(NSArray<NSString *> *)tabNames {
    self.tabTitles = tabNames;
    CGFloat y = 10;
    CGFloat btnSize = 50;

    for (NSInteger i = 0; i < tabNames.count; i++) {
        UIButton *btn = [UIButton buttonWithType:UIButtonTypeCustom];
        btn.frame = CGRectMake((75 - btnSize) / 2.0, y, btnSize, btnSize);
        btn.layer.cornerRadius = 15;
        btn.tag = i;
        
        // จำลองไอคอน (ในงานจริงให้เปลี่ยนเป็น Image)
        [btn setTitle:[NSString stringWithFormat:@"%ld", (long)i+1] forState:UIControlStateNormal];
        [btn setTitleColor:COLOR_TEXT_DIM forState:UIControlStateNormal];
        
        [btn addTarget:self action:@selector(tabButtonTapped:) forControlEvents:UIControlEventTouchUpInside];
        [self.tabScrollView addSubview:btn];
        [self.tabButtons addObject:btn];

        UIView *container = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.scrollView.frame.size.width, 0)];
        container.hidden = (i != 0);
        [self.contentView addSubview:container];
        [self.tabContainers addObject:container];
        [self.tabHeights addObject:@(0)];
        y += btnSize + 10;
    }
    self.tabScrollView.contentSize = CGSizeMake(75, y);
    [self setTabIndex:0];
}

// --- ฟังก์ชันสร้างปุ่ม Toggle วงกลม (เหมือนในรูปเป๊ะ) ---
- (void)addFeatureSwitch:(NSString *)title isOn:(BOOL)isOn handler:(MenuSwitchHandler)handler {
    CGFloat width = self.scrollView.frame.size.width;
    UIView *row = [[UIView alloc] initWithFrame:CGRectMake(0, 0, width, 50)];
    row.backgroundColor = COLOR_BG_ROW;
    row.layer.cornerRadius = 12;
    row.layer.borderWidth = 0.5;
    row.layer.borderColor = [UIColor colorWithWhite:1.0 alpha:0.05].CGColor;

    UILabel *lbl = [[UILabel alloc] initWithFrame:CGRectMake(15, 0, width - 60, 50)];
    lbl.text = title;
    lbl.textColor = COLOR_TEXT_MAIN;
    lbl.font = [UIFont systemFontOfSize:15 weight:UIFontWeightMedium];
    [row addSubview:lbl];

    // สร้าง Custom Toggle Circle
    UIButton *toggle = [UIButton buttonWithType:UIButtonTypeCustom];
    toggle.frame = CGRectMake(width - 40, 15, 25, 25);
    toggle.layer.cornerRadius = 12.5;
    toggle.layer.borderWidth = 2.0;
    
    // สถานะ เปิด/ปิด สีตามรูป
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

    [self addControlView:row height:50];
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

// --- Logic การสลับ Tab ---
- (void)setTabIndex:(NSInteger)index {
    if (index < 0 || index >= self.tabContainers.count) return;
    self.currentTabIndex = index;

    for (NSUInteger i = 0; i < self.tabButtons.count; i++) {
        UIButton *btn = self.tabButtons[i];
        BOOL selected = (i == index);
        btn.backgroundColor = selected ? [COLOR_ACCENT_GOLD colorWithAlphaComponent:0.3] : [UIColor clearColor];
        [btn setTitleColor:selected ? COLOR_ACCENT_GOLD : COLOR_TEXT_DIM forState:UIControlStateNormal];
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

- (void)closeMenu {
    [self removeFromSuperview];
}

@end
