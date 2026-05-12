#import "UIManager.h"
#import "MenuView.h"
#import "FloatingButton.h"
#import "../Helper/Vars.h"
#include "Other/dobby_defines.h"
#import "Other/H5hook.h"
#include "Other/Paste.h"



#define Hook(x, y, z) \
{ \
    NSString* result_##y = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), x, nullptr); \
    if (result_##y) { \
        void* result = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), x, (void *) y); \
        *(void **) (&z) = (void*) result; \
    } \
}

extern void old_AutoFire(void *_this, int32_t pFireStatus, int32_t pFireMode);
extern void (*_AutoFire)(void *_this, int32_t pFireStatus, int32_t pFireMode);
void initAutoFireHook(void);

void initAutoFireHook(void) {
    static bool hookInitialized = false;
    if (hookInitialized) return;
    hookInitialized = true;

    NSString *patchResult = StaticInlineHookPatch(("Frameworks/UnityFramework.framework/UnityFramework"), 0x56524D4, nullptr);
    NSLog(@"[AutoFire] patch result: %@", patchResult ?: @"<nil>");

    void *original = StaticInlineHookFunction(("Frameworks/UnityFramework.framework/UnityFramework"), 0x56524D4, (void *)old_AutoFire);
    if (original) {
        *(void **)(&_AutoFire) = original;
        NSLog(@"[AutoFire] installed original=%p", original);
    } else {
        NSLog(@"[AutoFire] hook install failed");
    }
}

void SetNinjaRunSpeedPreset(int preset);

#import <mach/mach.h>
#import <vector>

typedef struct {
    unsigned long long start;
    unsigned long long end;
} AddrRange;

enum {
    JR_Search_Type_ULong = 0,
    JR_Search_Type_UInt = 1,
};

#ifdef __cplusplus
class JRMemoryEngine {
public:
    JRMemoryEngine(mach_port_t task) {
        (void)task;
    }
    void JRScanMemory(AddrRange range, const void *value, int type) {
        (void)range;
        (void)value;
        (void)type;
        results_.clear();
    }
    std::vector<void*> getAllResults() {
        return results_;
    }
    void JRWriteMemory(unsigned long long address, const void *value, int type) {
        (void)address;
        (void)value;
        (void)type;
    }
private:
    std::vector<void*> results_;
};
#endif

@interface UIManager ()
@property (nonatomic, strong) FloatingButton *floatingButton;
@property (nonatomic, strong) MenuView *menu;
@property (nonatomic, strong) UIView *hideRecordView;
@property (nonatomic, strong) UITextField *hideRecordTextField;
@property (nonatomic, strong) UIButton *ninjaRunButtonView;
@property (nonatomic, strong) UISwitch *ninjaRunSwitch;
@property (nonatomic, assign) BOOL ninjaRunButtonVisible;
@property (nonatomic, assign) BOOL hideRecordContentEnabled;
@end

@implementation UIManager

+ (instancetype)shared {
    static UIManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[UIManager alloc] init];
    });
    return sharedInstance;
}

- (instancetype)init {
    self = [super init];
    if (self) {
        _hideRecordContentEnabled = NO;
        _ninjaRunButtonVisible = YES;
        if (@available(iOS 11.0, *)) {
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(screenCaptureChanged:) name:UIScreenCapturedDidChangeNotification object:nil];
            [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidTakeScreenshot:) name:UIApplicationUserDidTakeScreenshotNotification object:nil];
        }
    }
    return self;
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)screenCaptureChanged:(NSNotification *)notification {
    if (self.hideRecordContentEnabled) {
        [self updateHideRecordPlacement];
    }
}

- (void)applicationDidTakeScreenshot:(NSNotification *)notification {
    if (self.hideRecordContentEnabled) {
        [self updateHideRecordPlacement];
    }
}

- (UIView *)createHideRecordHostView {
    if (self.hideRecordView) {
        return self.hideRecordView;
    }

    UITextField *secureTextField = [[UITextField alloc] initWithFrame:[UIScreen mainScreen].bounds];
    secureTextField.secureTextEntry = YES;
    secureTextField.hidden = YES;

    UIView *hostView = [[UIView alloc] initWithFrame:[UIScreen mainScreen].bounds];
    hostView.backgroundColor = [UIColor clearColor];
    hostView.userInteractionEnabled = YES;
    [hostView addSubview:secureTextField];

    CALayer *layer = secureTextField.layer;
    if (layer.sublayers.count > 0) {
        id delegate = layer.sublayers[0].delegate;
        if ([delegate isKindOfClass:[UIView class]]) {
            hostView = (UIView *)delegate;
            hostView.frame = [UIScreen mainScreen].bounds;
            hostView.backgroundColor = [UIColor clearColor];
            hostView.userInteractionEnabled = YES;
        }
    }

    self.hideRecordTextField = secureTextField;
    self.hideRecordView = hostView;
    return self.hideRecordView;
}

- (void)updateHideRecordPlacement {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) window = [UIApplication sharedApplication].windows.firstObject;
    if (!window) return;

    if (self.hideRecordContentEnabled) {
        UIView *hostView = [self createHideRecordHostView];
        if (!hostView.superview) {
            [window addSubview:hostView];
        }
        if (self.menu.superview != hostView) {
            [self.menu removeFromSuperview];
            [hostView addSubview:self.menu];
        }
        if (self.floatingButton.superview != hostView) {
            [self.floatingButton removeFromSuperview];
            [hostView addSubview:self.floatingButton];
        }
        [window bringSubviewToFront:hostView];
        [hostView bringSubviewToFront:self.floatingButton];
        return;
    }

    if (self.menu.superview == self.hideRecordView) {
        [self.menu removeFromSuperview];
    }
    if (self.floatingButton.superview == self.hideRecordView) {
        [self.floatingButton removeFromSuperview];
    }
        if (self.hideRecordView.superview) {
            [self.hideRecordView removeFromSuperview];
        }
        if (!self.menu.superview) {
            [window addSubview:self.menu];
        }
        if (!self.floatingButton.superview) {
            [window addSubview:self.floatingButton];
        }
        [window bringSubviewToFront:self.floatingButton];
        [window bringSubviewToFront:self.menu];
}

- (void)setupUI {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) window = [UIApplication sharedApplication].windows.firstObject;
    if (!window) return;

    CGSize screenSize = window.bounds.size;
    CGRect buttonFrame = CGRectMake(screenSize.width - 62, screenSize.height / 2 - 20, 40, 40);
    if (!self.floatingButton) {
        self.floatingButton = [FloatingButton buttonWithFrame:buttonFrame];
        __weak UIManager *weakSelf = self;
        self.floatingButton.onTap = ^{
            [weakSelf toggleMenu];
        };
    }
    [window addSubview:self.floatingButton];
    [window bringSubviewToFront:self.floatingButton];
    [self updateNinjaRunButtonVisibility];

    if (!self.menu) {
        CGFloat menuWidth = MIN(360, screenSize.width - 40);
        CGFloat menuHeight = MIN(520, screenSize.height - 80);
        CGRect menuFrame = CGRectMake((screenSize.width - menuWidth) / 2, (screenSize.height - menuHeight) / 2, menuWidth, menuHeight);
        self.menu = [MenuView menuWithFrame:menuFrame];
        [self.menu canMove:YES];
        [self.menu setMenuTitle:@"MENU NATIVE IOS"];
        [self.menu setMenuSubtitle:@"Dev Hoàng Xuân Tú"];
        [self.menu addTab:@[@"ESP", @"AIMBOT", @"MEMORY", @"SETTINGS", @"INFO"]];

       
        [self.menu addFeatureSwitch:@"Enable ESP" description:@"Draw enemy boxes, names, and distance" isOn:Vars.Enable handler:^(BOOL isOn) {
            Vars.Enable = isOn;
        }];
        [self.menu addFeatureSwitch:@"ESP Lines" description:@"Render enemy tracking lines to enemies" isOn:Vars.lines handler:^(BOOL isOn) {
            Vars.lines = isOn;
        }];
        [self.menu addFeatureSwitch:@"ESP Box" description:@"Render enemy bounding boxes" isOn:Vars.Box handler:^(BOOL isOn) {
            Vars.Box = isOn;
        }];
        [self.menu addFeatureSwitch:@"ESP Name" description:@"Show enemy names" isOn:Vars.Name handler:^(BOOL isOn) {
            Vars.Name = isOn;
        }];
        [self.menu addFeatureSwitch:@"ESP Distance" description:@"Display distance to enemies" isOn:Vars.Distance handler:^(BOOL isOn) {
            Vars.Distance = isOn;
        }];
        [self.menu addFeatureSwitch:@"ESP Health" description:@"Show enemy health" isOn:Vars.Health handler:^(BOOL isOn) {
            Vars.Health = isOn;
        }];
        [self.menu addFeatureSwitch:@"ESP Skeleton" description:@"Render enemy skeleton" isOn:Vars.skeleton handler:^(BOOL isOn) {
            Vars.skeleton = isOn;
        }];
 [self.menu addFeatureSwitch:@"ESP Enemy Count" description:@"Show number of enemies" isOn:Vars.enemycount handler:^(BOOL isOn) {
            Vars.enemycount = isOn;
        }];
        [self.menu setTabIndex:1];
        
        [self.menu addFeatureSwitch:@"Enable Aimbot" description:@"Automatic aiming assistance" isOn:Vars.Aimbot handler:^(BOOL isOn) {
            Vars.Aimbot = isOn;
        }];
        [self.menu addFeatureSwitch:@"Auto Fire" description:@"Toggle automatic firing" isOn:Vars.AutoFire handler:^(BOOL isOn) {
            Vars.AutoFire = isOn;
        }];
        [self.menu addFeatureSwitch:@"Silent Aim" description:@"Redirect hits toward a target without visible aiming" isOn:Vars.SilentAim handler:^(BOOL isOn) {
            Vars.SilentAim = isOn;
        }];
        [self.menu addFeatureSwitch:@"Silent Aim Wall Check" description:@"Require line-of-sight for silent aim" isOn:Vars.SilentAimCheckWall handler:^(BOOL isOn) {
            Vars.SilentAimCheckWall = isOn;
        }];
        [self.menu addComboSelector:@"Silent Aim Hitbox" options:@[@"Head", @"Hip"] selectedIndex:Vars.SilentAimHitbox handler:^(NSInteger selectedIndex) {
            Vars.SilentAimHitbox = (int)selectedIndex;
        }];
        [self.menu addFeatureSwitch:@"Rotate 360" description:@"Rotate the local player around Y axis" isOn:Vars.Rotate360 handler:^(BOOL isOn) {
            Vars.Rotate360 = isOn;
        }];
        [self.menu addSlider:@"Rotate Speed" min:1 max:100 value:Vars.RotateSpeed handler:^(CGFloat value) {
            Vars.RotateSpeed = value;
        }];
        [self.menu addComboSelector:@"Aim When" options:@[@"Always", @"Fire", @"Scope", @"Fire + Scope"] selectedIndex:Vars.AimWhen handler:^(NSInteger selectedIndex) {
            Vars.AimWhen = (int)selectedIndex;
        }];
        [self.menu addComboSelector:@"Aim Mode" options:@[@"AimFOV", @"Aim360", @"Aim180"] selectedIndex:Vars.AimType handler:^(NSInteger selectedIndex) {
            Vars.AimType = (int)selectedIndex;
        }];
        [self.menu addComboSelector:@"Aim Target" options:@[@"Head", @"Neck", @"Belly"] selectedIndex:Vars.AimTarget handler:^(NSInteger selectedIndex) {
            Vars.AimTarget = (int)selectedIndex;
        }];
        [self.menu addSlider:@"Aim FOV" min:0 max:500 value:Vars.AimFov handler:^(CGFloat value) {
            Vars.AimFov = value;
        }];
        [self.menu addSlider:@"Aim360 Radius" min:0 max:500 value:Vars.Aim360Radius handler:^(CGFloat value) {
            Vars.Aim360Radius = value;
        }];
        [self.menu addFeatureSwitch:@"Aim360 Visible" description:@"Prefer visible enemies in 360 aim" isOn:Vars.Aim360PrioritizeVisible handler:^(BOOL isOn) {
            Vars.Aim360PrioritizeVisible = isOn;
        }];
        [self.menu addSlider:@"Aim180 Angle" min:0 max:360 value:Vars.Aim180Angle handler:^(CGFloat value) {
            Vars.Aim180Angle = value;
        }];
        [self.menu addFeatureSwitch:@"Aim180 Front Only" description:@"Limit 180 aim to front-facing targets" isOn:Vars.Aim180FrontOnly handler:^(BOOL isOn) {
            Vars.Aim180FrontOnly = isOn;
        }];
        [self.menu addFeatureSwitch:@"Ignore Downed" description:@"Skip knocked enemies" isOn:Vars.IgnoreDowned handler:^(BOOL isOn) {
            Vars.IgnoreDowned = isOn;
        }];

        [self.menu setTabIndex:2];
      
        __weak UIManager *weakSelf = self;
        [self.menu addFeatureSwitch:@"Memory Hack" description:@"Enable memory-based enhancements" isOn:NO handler:^(BOOL isOn) {
            Vars.OOF = isOn;
        }];
       
        [self.menu addFeatureSwitch:@"Speed Fast" description:@"Display the draggable Ninja Run quick toggle" isOn:self.ninjaRunButtonVisible handler:^(BOOL isOn) {
            UIManager *strongSelf = weakSelf;
            strongSelf.ninjaRunButtonVisible = isOn;
            [strongSelf updateNinjaRunButtonVisibility];
        }];
       
        [self.menu addSlider:@"Speed" min:0.1 max:10 value:Vars.NinjaRunSpeed handler:^(CGFloat value) {
            Vars.NinjaRunSpeed = value;
        }];
        [self.menu addSlider:@"Speed Height" min:0 max:20 value:Vars.NinjaRunHeight handler:^(CGFloat value) {
            Vars.NinjaRunHeight = value;
        }];
    
       
        [self.menu addFeatureSwitch:@"Up Player One" description:@"Slowly raise nearby enemies" isOn:Vars.UpPlayerOne handler:^(BOOL isOn) {
            Vars.UpPlayerOne = isOn;
        }];
        [self.menu addFeatureSwitch:@"Run Up Player" description:@"Quickly lift nearby enemies" isOn:Vars.RunUpPlayer handler:^(BOOL isOn) {
            Vars.RunUpPlayer = isOn;
        }];
       
        [self.menu addFeatureSwitch:@"Run Telekill" description:@"Teleport nearby enemies around you" isOn:Vars.RunTelekill handler:^(BOOL isOn) {
            Vars.RunTelekill = isOn;
        }];
        [self.menu addSlider:@"Telekill Distance" min:0 max:100 value:Vars.TelekillDistance handler:^(CGFloat value) {
            Vars.TelekillDistance = value;
        }];
        [self.menu addSlider:@"Telekill Speed" min:0.1 max:2 value:Vars.TelekillSpeed handler:^(CGFloat value) {
            Vars.TelekillSpeed = value;
        }];
        [self.menu addTextField:@"Memory Address" placeholder:@"0x1234ABCD" handler:^(NSString *text) {
            // Placeholder: store or use text value in cheats
        }];
        [self.menu addComboSelector:@"Memory Mode" options:@[@"Normal", @"Fast", @"Stealth"] selectedIndex:0 handler:^(NSInteger selectedIndex) {
            // Placeholder: adjust memory mode
        }];

        [self.menu setTabIndex:3];
     
        [self.menu addFeatureSwitch:@"Ẩn nội dung ghi" description:@"Hide menu content during screen recording" isOn:self.hideRecordContentEnabled handler:^(BOOL isOn) {
            UIManager *strongSelf = weakSelf;
            strongSelf.hideRecordContentEnabled = isOn;
            [strongSelf updateHideRecordPlacement];
        }];

        [self.menu addComboSelector:@"Theme Color" options:@[@"Red", @"White", @"Black", @"Yellow", @"Purple"] selectedIndex:0 handler:^(NSInteger selectedIndex) {
            UIColor *color = [UIColor colorWithRed:110.0/255.0 green:142.0/255.0 blue:251.0/255.0 alpha:1.0];
            float alpha = Vars.themeColor.w;
            switch (selectedIndex) {
                case 0:
                    color = [UIColor colorWithRed:220.0/255.0 green:38.0/255.0 blue:38.0/255.0 alpha:alpha];
                    Vars.themeColor = ImVec4(220.0/255.0, 38.0/255.0, 38.0/255.0, alpha);
                    break;
                case 1:
                    color = [UIColor colorWithWhite:1.0 alpha:alpha];
                    Vars.themeColor = ImVec4(1.0f, 1.0f, 1.0f, alpha);
                    break;
                case 2:
                    color = [UIColor colorWithWhite:0.0 alpha:alpha];
                    Vars.themeColor = ImVec4(0.0f, 0.0f, 0.0f, alpha);
                    break;
                case 3:
                    color = [UIColor colorWithRed:229.0/255.0 green:184.0/255.0 blue:23.0/255.0 alpha:alpha];
                    Vars.themeColor = ImVec4(229.0/255.0, 184.0/255.0, 23.0/255.0, alpha);
                    break;
                case 4:
                    color = [UIColor colorWithRed:128.0/255.0 green:60.0/255.0 blue:214.0/255.0 alpha:alpha];
                    Vars.themeColor = ImVec4(128.0/255.0, 60.0/255.0, 214.0/255.0, alpha);
                    break;
            }
            [weakSelf.menu setMenuAccentColor:color];
        }];
        [self.menu addSlider:@"Độ dày viền" min:0.2 max:8 value:Vars.EspBorderThickness handler:^(CGFloat value) {
            Vars.EspBorderThickness = value;
        }];
        [self.menu addThemeSlider:@"Accent Strength" property:@"accent" max:100 min:0 value:50 handler:^(CGFloat value) {
            CGFloat normalized = MAX(0.4, value / 100.0);
            UIColor *current = weakSelf.menu.accentColor ?: [UIColor colorWithRed:110.0/255.0 green:142.0/255.0 blue:251.0/255.0 alpha:1.0];
            CGFloat red, green, blue, alpha;
            if ([current getRed:&red green:&green blue:&blue alpha:&alpha]) {
                [weakSelf.menu setMenuAccentColor:[UIColor colorWithRed:red green:green blue:blue alpha:normalized]];
                Vars.themeColor = ImVec4(red, green, blue, normalized);
            } else {
                [weakSelf.menu setMenuAccentColor:[UIColor colorWithRed:110.0/255.0 green:142.0/255.0 blue:251.0/255.0 alpha:normalized]];
                Vars.themeColor = ImVec4(110.0/255.0, 142.0/255.0, 251.0/255.0, normalized);
            }
        }];

        [self.menu addSlider:@"ESP Scale Speed" min:10 max:100 value:Vars.EspScaleSpeed handler:^(CGFloat value) {
            Vars.EspScaleSpeed = value;
        }];

        [self.menu setTabIndex:4];
    
        [self.menu addLabel:@"Dev Hoàng Xuân Tú"];
      
        [self.menu addLabel:@"Build version 0.1(DFGXKSODWAFG)"];
        [self.menu addLabel:@"Created on 12 4 2026 05:30:02 UTC"];
        [self.menu addLabel:@"Game version 1.123.X"];
        [self.menu addButton:@"Logout" withHandler:^{
            [weakSelf toggleMenu];
        }];
        [self.menu setTabIndex:3];
    }
}

- (void)showMenu {
    UIWindow *window = [UIApplication sharedApplication].keyWindow;
    if (!window) window = [UIApplication sharedApplication].windows.firstObject;
    if (!window) return;

    if (self.hideRecordContentEnabled) {
        [self updateHideRecordPlacement];
    }

    if (!self.menu.superview) {
        self.menu.alpha = 1.0;
        [window addSubview:self.menu];
        [window bringSubviewToFront:self.menu];
    }
}

- (void)toggleMenu {
    if (self.menu.superview) {
        [self.menu removeFromSuperview];
    } else {
        if (self.hideRecordContentEnabled) {
            [self updateHideRecordPlacement];
        }

        UIWindow *window = [UIApplication sharedApplication].keyWindow;
        if (!window) window = [UIApplication sharedApplication].windows.firstObject;
        if (!window) return;

        if (!self.menu.superview) {
            self.menu.alpha = 1.0;
            [window addSubview:self.menu];
        }
        [window bringSubviewToFront:self.menu];
    }
}

- (void)updateNinjaRunButtonVisibility {
    if (self.ninjaRunButtonVisible) {
        [self ninjaRunModeUI];
    } else {
        if (self.ninjaRunButtonView.superview) {
            [self.ninjaRunButtonView removeFromSuperview];
        }
        self.ninjaRunButtonView = nil;
        self.ninjaRunSwitch = nil;
    }
}

- (void)hideMenu {
    if (self.menu.superview) {
        [self.menu removeFromSuperview];
    }
}

- (void)ninjaRunModeUI {
    if (self.ninjaRunButtonView) return;

    self.ninjaRunButtonView = [[UIButton alloc] initWithFrame:CGRectMake(305, 390, 58, 54)];
    self.ninjaRunButtonView.backgroundColor = [UIColor colorWithRed:41/255.0 green:41/255.0 blue:41/255.0 alpha:0.8];
    self.ninjaRunButtonView.layer.borderColor = [UIColor colorWithRed:25/255.0 green:118/255.0 blue:210/255.0 alpha:1.0].CGColor;
    self.ninjaRunButtonView.layer.borderWidth = 1.0;
    self.ninjaRunButtonView.layer.cornerRadius = 13;
    self.ninjaRunButtonView.clipsToBounds = YES;
    self.ninjaRunButtonView.layer.shadowOpacity = 0;
    self.ninjaRunButtonView.layer.shadowColor = [UIColor clearColor].CGColor;
    self.ninjaRunButtonView.layer.shadowRadius = 0;
    self.ninjaRunButtonView.alpha = 1.0f;

    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(5, 1, 58, 20)];
    label.text = @"Tasuda";
    label.font = [UIFont fontWithName:@"CourierNewPS-BoldMT" size:10];
    label.textColor = [UIColor colorWithRed:25/255.0 green:118/255.0 blue:210/255.0 alpha:1.0];
    label.backgroundColor = [UIColor clearColor];
    [self.ninjaRunButtonView addSubview:label];

    self.ninjaRunSwitch = [[UISwitch alloc] initWithFrame:CGRectMake(3.5, 20, 51, 31)];
    self.ninjaRunSwitch.onTintColor = [UIColor colorWithRed:25/255.0 green:118/255.0 blue:210/255.0 alpha:1.0];
    self.ninjaRunSwitch.thumbTintColor = [UIColor whiteColor];
    self.ninjaRunSwitch.backgroundColor = [UIColor clearColor];
    [self.ninjaRunSwitch addTarget:self action:@selector(ninjaRunSwitchChanged:) forControlEvents:UIControlEventValueChanged];
    [self.ninjaRunButtonView addSubview:self.ninjaRunSwitch];

    UIPanGestureRecognizer *panGesture = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handleNinjaRunDrag:)];
    [self.ninjaRunButtonView addGestureRecognizer:panGesture];

    UIWindow *mainWindow = [UIApplication sharedApplication].keyWindow;
    if (!mainWindow) mainWindow = [UIApplication sharedApplication].windows.firstObject;
    if (mainWindow) {
        [mainWindow addSubview:self.ninjaRunButtonView];
    }
}

- (void)ninjaRunSwitchChanged:(UISwitch *)sender {
    Vars.NinjaRun = sender.on;
}

- (void)handleNinjaRunDrag:(UIPanGestureRecognizer *)gesture {
    UIView *draggedView = gesture.view;
    CGPoint translation = [gesture translationInView:draggedView.superview];
    CGPoint newCenter = CGPointMake(draggedView.center.x + translation.x, draggedView.center.y + translation.y);
    draggedView.center = newCenter;
    [gesture setTranslation:CGPointZero inView:draggedView.superview];
}


@end