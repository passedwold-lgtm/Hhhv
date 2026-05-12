#import "FloatingButton.h"

@implementation FloatingButton

+ (instancetype)buttonWithFrame:(CGRect)frame {
    FloatingButton *button = [FloatingButton buttonWithType:UIButtonTypeCustom];
    CGFloat size = 40.0;
    button.frame = CGRectMake(frame.origin.x, frame.origin.y, size, size);
    [button setup];
    return button;
}

- (void)setup {
    self.backgroundColor = [UIColor colorWithRed:110.0/255.0 green:142.0/255.0 blue:251.0/255.0 alpha:0.95];
    self.layer.cornerRadius = self.frame.size.height / 2.0;
    self.layer.shadowColor = [UIColor colorWithWhite:0.0 alpha:0.35].CGColor;
    self.layer.shadowOpacity = 0.3;
    self.layer.shadowRadius = 8.0;
    self.layer.shadowOffset = CGSizeMake(0, 4);
    [self setTitle:@"TÚ" forState:UIControlStateNormal];
    [self setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.titleLabel.font = [UIFont systemFontOfSize:12 weight:UIFontWeightBold];
    [self addTarget:self action:@selector(buttonTapped) forControlEvents:UIControlEventTouchUpInside];
    [self makeDraggable];
}

- (void)buttonTapped {
    [UIView animateWithDuration:0.12 animations:^{
        self.transform = CGAffineTransformMakeScale(0.93, 0.93);
    } completion:^(BOOL finished) {
        [UIView animateWithDuration:0.12 animations:^{
            self.transform = CGAffineTransformIdentity;
        } completion:^(BOOL finished) {
            if (self.onTap) self.onTap();
        }];
    }];
}

- (void)makeDraggable {
    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    pan.cancelsTouchesInView = NO;
    [self addGestureRecognizer:pan];
}

- (void)handlePan:(UIPanGestureRecognizer *)gesture {
    CGPoint translation = [gesture translationInView:self.superview];
    if (gesture.state == UIGestureRecognizerStateBegan) {
        self.lastLocation = self.center;
    }
    self.center = CGPointMake(self.lastLocation.x + translation.x, self.lastLocation.y + translation.y);
    CGRect bounds = self.superview.bounds;
    CGFloat halfWidth = CGRectGetWidth(self.bounds) / 2.0;
    CGFloat halfHeight = CGRectGetHeight(self.bounds) / 2.0;
    self.center = CGPointMake(MAX(halfWidth, MIN(CGRectGetWidth(bounds) - halfWidth, self.center.x)), MAX(halfHeight, MIN(CGRectGetHeight(bounds) - halfHeight, self.center.y)));
}

@end
