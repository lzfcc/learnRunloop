//
//  ViewController.m
//  Runloop
//
//  Created by garin on 2019/4/22.
//  Copyright © 2019年 xiaomi. All rights reserved.
//

#import "ViewController.h"
#import "NSRunLoop+Hook.h"

@interface ViewController ()
@property (strong, nonatomic) NSMachPort *port; //global
@property (strong, nonatomic) NSRunLoop *theRL;
@property (strong, nonatomic) NSThread *thread;
@end

@implementation ViewController

/*
 https://juejin.im/entry/595f832c6fb9a06bc23a9d70
 */

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Runloop";
    // Do any additional setup after loading the view, typically from a nib.
    [self memoryIssue];
}

- (void)basicUsage {
    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(createRunLoopInNewThread) object:nil];
    [_thread setName:thread_name];
    [_thread start];
}

- (void)memoryIssue {
    for (int i = 0; i < 10000; i++) {
        @autoreleasepool {
            NSThread *thread = [[NSThread alloc] initWithTarget:self selector:@selector(runThread) object:nil];
            [thread setName:thread_name];
            [thread start];
            [self performSelector:@selector(stopThread) onThread:thread withObject:nil waitUntilDone:YES];
        }
    }
}

- (void)runThread {
    NSLog(@"current thread = %@", [NSThread currentThread]);
    NSRunLoop *runLoop = [NSRunLoop currentRunLoop];
    static NSMachPort *port;
    if (!port) {
        port = [NSMachPort port];
    }
    [runLoop addPort:port forMode:NSDefaultRunLoopMode];
//    CFRunLoopRun();  //和runloop run有什么区别？为什么结果不一样
    [runLoop run];
//    [runLoop runMode:NSRunLoopCommonModes beforeDate:[NSDate distantFuture]];
}

- (void)stopThread {
    CFRunLoopStop(CFRunLoopGetCurrent());
    NSThread *thread = [NSThread currentThread];
    [thread cancel];
}

- (void)createRunLoopInNewThread {
    _theRL = [NSRunLoop currentRunLoop];
    _port = (NSMachPort *)[NSMachPort port];
    // 添加一个端口作为输入源
    [_theRL addPort:_port forMode:NSDefaultRunLoopMode];

    // 该方法会在当前线程的runloop中创建一个timer，并在当前线程中执行selector
//    [self performSelector:@selector(excuteInNewThread:) withObject:@"🈚️" afterDelay:2];
//    [self performSelector:@selector(excuteInNewThread:) withObject:@"🈶️" afterDelay:3];

    // 注意：这里repeats参数要设为`NO`.
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:YES block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"㊗️🌹🎉");
//    }];
    // 添加一个定时源
//    [_theRL addTimer:timer forMode:NSDefaultRunLoopMode];

    [_theRL addObserver:self forKeyPath:@"state" options:NSKeyValueObservingOptionOld|NSKeyValueObservingOptionNew context:nil];

    [self addObserver];

//    [_theRL run];
//    [_theRL runUntilDate:[NSDate dateWithTimeInterval:10 sinceDate:[NSDate date]]];  //10s after now
    [_theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeInterval:10 sinceDate:[NSDate date]]];

    NSLog(@"runloop已退出"); //只有当runloop退出，这里才会执行。可以通过注册runloop观察者进行验证，这里就不贴代码了，具体代码请到demo里查看。
}

- (void)excuteInNewThread:(NSString *)param {
    NSLog(@"%@", param);
    // 将当前线程的runloop中的port移除
//    [_theRL removePort:_port forMode:NSDefaultRunLoopMode];

    // 退出线程是否能够结束runloop？不能
//    [NSThread exit];

//    CFRunLoopStop(CFRunLoopGetCurrent());
}

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    [self performSelector:@selector(communicateToNewThreadFromMainThread) onThread:_thread withObject:nil waitUntilDone:NO];
}

- (void)communicateToNewThreadFromMainThread {
    NSLog(@"❓这个有啥用❓%@", [NSThread currentThread]);
}

- (void)addObserver {

    CFRunLoopObserverRef observer = CFRunLoopObserverCreateWithHandler(CFAllocatorGetDefault(), kCFRunLoopAllActivities, YES, 0, ^(CFRunLoopObserverRef observer, CFRunLoopActivity activity) {
        switch (activity) {
            case kCFRunLoopEntry:
                NSLog(@"即将进入runloop");
                break;
            case kCFRunLoopBeforeTimers:
                NSLog(@"即将处理 Timer");
                break;
            case kCFRunLoopBeforeSources:
                NSLog(@"即将处理 Sources");
                break;
            case kCFRunLoopBeforeWaiting:
                NSLog(@"即将进入休眠\n💤💤💤💤💤💤💤💤💤💤💤💤💤");
                break;
            case kCFRunLoopAfterWaiting:
                NSLog(@"从休眠中唤醒loop");
                break;
            case kCFRunLoopExit:
                NSLog(@"即将退出runloop");
                break;

            default:
                break;
        }
    });
    CFRunLoopAddObserver(CFRunLoopGetCurrent(), observer, kCFRunLoopDefaultMode);
    CFRelease(observer);
}

@end
