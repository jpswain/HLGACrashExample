//
//  HLViewController.m
//  HLGACrashExample
//
//  Created by Jamie Swain on 11/6/13.
//

#import "HLViewController.h"
#import <mach/mach_time.h>
#import <objc/runtime.h>


@interface HLViewController () {
    dispatch_source_t timer;
}

@property (nonatomic, strong) UILabel *timeDisplay;
@property (nonatomic, strong) UILabel *gaSentStatusDisplay;

@end

@implementation HLViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    self.view.backgroundColor = [UIColor cyanColor];
    self.timeDisplay = [[UILabel alloc] initWithFrame:CGRectMake(10.f, 10.f, 300.f, 100.f)];
    self.timeDisplay.font = [UIFont systemFontOfSize:20.f];
    [self.view addSubview:self.timeDisplay];
    self.timeDisplay.backgroundColor = [UIColor clearColor];
    self.timeDisplay.textColor = [UIColor blackColor];
    
    
    self.gaSentStatusDisplay = [[UILabel alloc] initWithFrame:CGRectMake(10.f, CGRectGetMaxY(self.timeDisplay.frame) + 10.f, 300.f, 100.f)];
    self.gaSentStatusDisplay.font = [UIFont systemFontOfSize:20.f];
    [self.view addSubview:self.gaSentStatusDisplay];
    self.gaSentStatusDisplay.backgroundColor = [UIColor clearColor];
    self.gaSentStatusDisplay.textColor = [UIColor blackColor];

    self.gaSentStatusDisplay.text = @"GA exceptions queued=NO";
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(observe_gaNotificationsSent:) name:@"queued_GA_exceptions" object:nil];
}

- (void)dealloc {
    [[NSNotificationCenter defaultCenter] removeObserver:self];     
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)observe_gaNotificationsSent:(NSNotification *)note {
    self.gaSentStatusDisplay.text = @"GA exceptions queued=YES";
}

- (void)viewDidAppear:(BOOL)animated {
    

    NSTimeInterval started = [self _now];
    __weak __typeof(self) wSelf = self;
    void (^timerBlock)(void) = ^{
        CGFloat elapsed = [wSelf _now] - started;
//        NSLog(@"elapsed: %.1f", elapsed);
        wSelf.timeDisplay.text = [NSString stringWithFormat:@"%.1f", elapsed];
    };

    if (!timer) {
        timer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER,
                                       0, 0, dispatch_get_main_queue());
        dispatch_source_set_timer(timer, DISPATCH_TIME_NOW, 0.05 * NSEC_PER_SEC, 0.02 * NSEC_PER_SEC);
        dispatch_source_set_event_handler(timer, timerBlock);
        dispatch_resume(timer);
    }
}


- (NSTimeInterval)_now {
    static mach_timebase_info_data_t info;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        mach_timebase_info(&info);
    });
    
    NSTimeInterval t = mach_absolute_time();
    t *= info.numer;
    t /= info.denom;
    return t / NSEC_PER_SEC;
}


@end
