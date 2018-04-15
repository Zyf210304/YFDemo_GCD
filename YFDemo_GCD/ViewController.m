//
//  ViewController.m
//  YFDemo_GCD
//
//  Created by 亚飞 on 2018/4/12.
//  Copyright © 2018年 yafei. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@property (nonatomic, strong) dispatch_queue_t serialQueue;
@property (nonatomic, strong) dispatch_queue_t concurrentQueue;

@property (nonatomic, strong) UIImageView *imageView_1;
@property (nonatomic, strong) UIImageView *imageView_2;
@property (nonatomic, strong) UIImageView *imageView_3;
@end

@implementation ViewController

- (void)viewDidLoad {
    //串行队列
    self.serialQueue = dispatch_queue_create("serialQueue.yf.com", DISPATCH_QUEUE_SERIAL);
    //并行队列
    self.concurrentQueue = dispatch_queue_create("concurrentQueue.yf.com", DISPATCH_QUEUE_CONCURRENT);


    [super viewDidLoad];
    
//    [self GCDDelay];
//    [self GCDGroup];
    [self GCDSemaphore];
}

- (void)GCDDelay {

    //主队列延时
    dispatch_time_t when_main = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 *NSEC_PER_SEC));
    dispatch_after(when_main, dispatch_get_main_queue(), ^{
        NSLog(@"main_%@", [NSThread currentThread]);
    });

    //全局对列延时
    dispatch_time_t when_global = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(4.0 *NSEC_PER_SEC));
    dispatch_after(when_global, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSLog(@"global_%@",[NSThread currentThread]);
    });

    //自定义队列延时
    dispatch_time_t when_custom = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5.0 *NSEC_PER_SEC));
    dispatch_after(when_custom, self.serialQueue, ^{
        NSLog(@"custom_%@", [NSThread currentThread]);
    });

}



- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event {
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSLog(@"%@", [NSThread currentThread]);
    });
}


- (void)GCDGroup {
    [self joinImageView];

    dispatch_group_t group = dispatch_group_create();
    __block UIImage *image_1 = nil;
    __block UIImage *image_2 = nil;

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *imageUrl = [NSURL URLWithString:@"https://timgsa.baidu.com/timg?image&quality=80&size=b9999_10000&sec=1502706256731&di=371f5fd17184944d7e2b594142cd7061&imgtype=0&src=http%3A%2F%2Fimg4.duitang.com%2Fuploads%2Fitem%2F201605%2F14%2F20160514165210_LRCji.jpeg"];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        image_1 = [UIImage imageWithData:imageData];
    });

    dispatch_group_async(group, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSURL *imageUrl = [NSURL URLWithString:@"https://ss3.bdstatic.com/70cFv8Sh_Q1YnxGkpoWK1HF6hhy/it/u=776127947,2002573948&fm=26&gp=0.jpg"];
        NSData *imageData = [NSData dataWithContentsOfURL:imageUrl];
        image_2 = [UIImage imageWithData:imageData];
    });

    //group中所有任务执行完毕，通知该方法执行
    dispatch_group_notify(group, dispatch_get_main_queue(), ^{
        self.imageView_1.image = image_1;
        self.imageView_2.image = image_2;
        //
        UIGraphicsBeginImageContextWithOptions(CGSizeMake(200, 100), NO, 0.0f);
        [image_2 drawInRect:CGRectMake(0, 0, 100, 100)];
        [image_1 drawInRect:CGRectMake(100, 0, 100, 100)];
        UIImage *image_3 = UIGraphicsGetImageFromCurrentImageContext();
        self.imageView_3.image = image_3;
        UIGraphicsEndImageContext();
    });


}

- (void)joinImageView {
    self.imageView_1 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 50, 100, 100)];
    [self.view addSubview:_imageView_1];

    self.imageView_2 = [[UIImageView alloc] initWithFrame:CGRectMake(140, 50, 100, 100)];
    [self.view addSubview:_imageView_2];

    self.imageView_3 = [[UIImageView alloc] initWithFrame:CGRectMake(20, 200, 200, 100)];
    [self.view addSubview:_imageView_3];

    self.imageView_1.layer.borderColor = self.imageView_2.layer.borderColor = self.imageView_3.layer.borderColor = [UIColor grayColor].CGColor;
    self.imageView_1.layer.borderWidth = self.imageView_2.layer.borderWidth = self.imageView_3.layer.borderWidth = 1;


}


-(void)GCDbarrier{

    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"任务1");
    });
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"任务2");
    });

    //    dispatch_barrier_async(self.concurrentQueue, ^{
    //        NSLog(@"任务barrier");
    //    });

    //    NSLog(@"big");
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"任务3");
    });
    //    NSLog(@"apple");
    dispatch_async(self.concurrentQueue, ^{
        NSLog(@"任务4");
    });
}

-(void)GCDSemaphore{
    //
    //dispatch_semaphore_t semaphore = dispatch_semaphore_create(1);
    dispatch_apply(5, self.concurrentQueue, ^(size_t i) {
        //dispatch_semaphore_wait(semaphore, DISPATCH_TIME_FOREVER);
        dispatch_async(self.concurrentQueue, ^{
            NSLog(@"第%@次_%@",@(i),[NSThread currentThread]);
            //dispatch_semaphore_signal(semaphore);
        });
    });
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
