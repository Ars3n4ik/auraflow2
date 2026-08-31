#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import <substrate.h>

static CAGradientLayer *gradientLayer = nil;
static CADisplayLink *displayLink = nil;
static CGFloat hueOffset = 0.0;

void updateGradient() {
    if (!gradientLayer) return;
    
    hueOffset += 0.005;
    if (hueOffset > 1.0) hueOffset = 0.0;
    
    // 3 цвета для более красивого градиента
    CGFloat h1 = fmodf(hueOffset * 0.7, 1.0);
    CGFloat h2 = fmodf(hueOffset * 0.7 + 0.33, 1.0);
    CGFloat h3 = fmodf(hueOffset * 0.7 + 0.66, 1.0);
    
    UIColor *c1 = [UIColor colorWithHue:h1 saturation:0.7 brightness:0.9 alpha:0.20];
    UIColor *c2 = [UIColor colorWithHue:h2 saturation:0.7 brightness:0.9 alpha:0.20];
    UIColor *c3 = [UIColor colorWithHue:h3 saturation:0.7 brightness:0.9 alpha:0.20];
    
    gradientLayer.colors = @[(id)c1.CGColor, (id)c2.CGColor, (id)c3.CGColor];
    
    // Меняем направление градиента
    gradientLayer.startPoint = CGPointMake(sinf(hueOffset * 4.0) * 0.5 + 0.5,
                                           cosf(hueOffset * 3.0) * 0.5 + 0.5);
    gradientLayer.endPoint = CGPointMake(cosf(hueOffset * 4.0) * 0.5 + 0.5,
                                         sinf(hueOffset * 3.0) * 0.5 + 0.5);
}

// Хук на все UIWindow (работает и на Lock Screen)
%hook UIWindow

- (void)layoutSubviews {
    %orig;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        // Создаём контейнер
        UIView *container = [[UIView alloc] initWithFrame:self.bounds];
        container.backgroundColor = [UIColor clearColor];
        container.userInteractionEnabled = NO;
        container.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self insertSubview:container atIndex:0];
        
        // Создаём градиент
        gradientLayer = [CAGradientLayer layer];
        gradientLayer.frame = self.bounds;
        gradientLayer.colors = @[(id)[UIColor colorWithRed:0.2 green:0.6 blue:0.9 alpha:0.2].CGColor,
                                 (id)[UIColor colorWithRed:0.9 green:0.3 blue:0.6 alpha:0.2].CGColor,
                                 (id)[UIColor colorWithRed:0.3 green:0.9 blue:0.6 alpha:0.2].CGColor];
        gradientLayer.startPoint = CGPointMake(0, 0);
        gradientLayer.endPoint = CGPointMake(1, 1);
        [container.layer addSublayer:gradientLayer];
        
        // Создаём объект-таргет для CADisplayLink
        static id target = nil;
        static dispatch_once_t targetToken;
        dispatch_once(&targetToken, ^{
            target = [[NSObject alloc] init];
            class_addMethod([target class], @selector(update), (IMP)updateGradient, "v@:");
        });
        
        displayLink = [CADisplayLink displayLinkWithTarget:target selector:@selector(update)];
        displayLink.preferredFramesPerSecond = 30; // экономим батарею
        [displayLink addToRunLoop:[NSRunLoop mainRunLoop] forMode:NSRunLoopCommonModes];
    });
}

%end
