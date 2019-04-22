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

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"Runloop";
    // Do any additional setup after loading the view, typically from a nib.

    _thread = [[NSThread alloc] initWithTarget:self selector:@selector(createRunLoopInNewThread) object:nil];
    [_thread setName:thread_name];
    [_thread start];
}

- (void)createRunLoopInNewThread {
    _theRL = [NSRunLoop currentRunLoop];
    _port = (NSMachPort *)[NSMachPort port];
    // 添加一个端口作为输入源
    [_theRL addPort:_port forMode:NSDefaultRunLoopMode];

    // 该方法会在当前线程的runloop中创建一个timer，并在当前线程中执行selector
    [self performSelector:@selector(excuteInNewThread:) withObject:@"🈚️" afterDelay:2];
    [self performSelector:@selector(excuteInNewThread:) withObject:@"🈶️" afterDelay:3];

    // 注意：这里repeats参数要设为`NO`.
//    NSTimer *timer = [NSTimer scheduledTimerWithTimeInterval:1.5 repeats:NO block:^(NSTimer * _Nonnull timer) {
//        NSLog(@"🌹🌈");
//    }];
//    // 添加一个定时源
//    [_theRL addTimer:timer forMode:NSDefaultRunLoopMode];



    [_theRL run];
//    [_theRL runUntilDate:[NSDate dateWithTimeInterval:10 sinceDate:[NSDate date]]];  //10s after now
//    [_theRL runMode:NSDefaultRunLoopMode beforeDate:[NSDate dateWithTimeInterval:10 sinceDate:[NSDate date]]];

    NSLog(@"runloop已退出"); //只有当runloop退出，这里才会执行。可以通过注册runloop观察者进行验证，这里就不贴代码了，具体代码请到demo里查看。
}

- (void)excuteInNewThread:(NSString *)param {
    NSLog(@"%@", param);
    // 将当前线程的runloop中的port移除
    //[_theRL removePort:_port forMode:NSDefaultRunLoopMode];
}

@end
