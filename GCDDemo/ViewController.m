//
//  ViewController.m
//  GCDDemo
//
//  Created by apple on 16/1/18.
//  Copyright © 2016年 apple. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *image;

@end


@implementation ViewController


-(void) touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self once];
}

-(void)loadImage
{
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        // 1. 网络上图片的URL
        NSURL *url = [NSURL URLWithString:@"http://att2.citysbs.com/hangzhou/image1/2010/06/28-14/middle_20100628_479774d896cf207fed251P3nfB3V8Pmp.jpg"];
        
        // 2. 获取网络图片数据，二进制
        NSData *data = [NSData dataWithContentsOfURL:url];
        
        // 3. 二进制数据转换成图片
        UIImage *image = [UIImage imageWithData:data];
        
        // 4.通知主线程更新UI
        dispatch_async(dispatch_get_main_queue(), ^{
            self.image.image = image;
        });
        
    });

}

-(void) delayExecute
{
    // 延迟时间
    dispatch_time_t when = dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC));
    NSLog(@"start at %@", [NSDate new]);
    
    // 指定队列，延迟指定时间后执行任务
    dispatch_after(when, dispatch_get_global_queue(0, 0), ^{
        NSLog(@"end at %@", [NSDate new]);
        NSLog(@"%@", [NSThread currentThread]);
    });
}

-(void) group
{
    // 实例化一个调度组
    dispatch_group_t group = dispatch_group_create();
    
    // 创建或者获取队列
    dispatch_queue_t queue1 = dispatch_get_global_queue(0, 0);
    
    // 将任务放入队列，包进到指定group
    dispatch_group_async(group, queue1, ^{
        NSLog(@"下载小说A----%@", [NSThread currentThread]);
    });
    
    // 创建或者获取队列
    dispatch_queue_t queue2 = dispatch_queue_create("xf", DISPATCH_QUEUE_CONCURRENT);
    dispatch_group_async(group, queue2, ^{
        NSLog(@"下载小说B----%@", [NSThread currentThread]);
    });
    
    // 创建或者获取队列
    dispatch_queue_t queue3 = dispatch_queue_create("xf", DISPATCH_QUEUE_SERIAL);
    dispatch_group_async(group, queue3, ^{
        NSLog(@"下载小说C----%@", [NSThread currentThread]);
    });
    
    // 创建或者获取队列
    dispatch_queue_t queue4 = dispatch_get_main_queue();
    dispatch_group_notify(group, queue4, ^{
        NSLog(@"下载完成，请观看----%@", [NSThread currentThread]);
    });
}

-(void)once
{
    static dispatch_once_t onceToken = -1;
    NSLog(@"out onceToken is %ld", onceToken);
    dispatch_once(&onceToken, ^{
        NSLog(@"in onceToken is %ld", onceToken);
        NSLog(@"执行了一次！");
    });
    
    NSLog(@"完成");
}


/**
 *  串行队列+同步方式执行任务
 *  任务顺序：先进先出
 *  线程启动方式：不开启新线程，全部在当前线程中执行
 */
-(void) test1
{
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("xf", DISPATCH_QUEUE_SERIAL);
    
    // 循环调用，确定任务的放置于启动顺序
    for (int i = 0; i < 10; i++)
    {
        // 启动任务
        dispatch_sync(queue,^{
            NSLog(@"execute task : %d in thread : %@", i, [NSThread currentThread]);
        });
    }
    
    NSLog(@"%@", @"完成!");
}

/**
 *  串行队列+异步方式执行任务
 *  任务顺序：先进先出
 *  线程启动方式：开启新线程且只开启一个新线程，全部在新线程中执行
 */
-(void) test2
{
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("xf", DISPATCH_QUEUE_SERIAL);
    
    // 循环调用，确定任务的放置于启动顺序
    for (int i = 0; i < 10; i++)
    {
        // 启动任务
        dispatch_async(queue,^{
            NSLog(@"execute task : %d in thread : %@", i, [NSThread currentThread]);
        });
    }
    
    NSLog(@"%@", @"完成!");
}

/**
 *  并发队列+同步方式执行任务
 *  任务顺序：先进先出
 *  线程启动方式：不开启新线程，全部在当前线程中执行
 */
-(void) test3
{
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("xf", DISPATCH_QUEUE_CONCURRENT);
    
    // 循环调用，确定任务的放置于启动顺序
    for (int i = 0; i < 10; i++)
    {
        // 启动任务
        dispatch_sync(queue,^{
            NSLog(@"execute task : %d in thread : %@", i, [NSThread currentThread]);
        });
    }
    
    NSLog(@"%@", @"完成!");
}

/**
 *  并发队列+异步方式执行任务
 *  任务顺序：无序
 *  线程启动方式：开启多个线程，在多个线程中可以同时执行多个任务
 */
-(void) test4
{
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("xf", DISPATCH_QUEUE_CONCURRENT);
    
    // 循环调用，确定任务的放置于启动顺序
    for (int i = 0; i < 10; i++)
    {
        // 启动任务
        dispatch_async(queue,^{
            NSLog(@"execute task : %d in thread : %@", i, [NSThread currentThread]);
        });
    }
    
    NSLog(@"%@", @"完成!");
}

/**
 *  主队列+同步方式执行任务
 *  任务顺序：卡死
 *  线程启动方式：卡死
 */
-(void) test5
{
    // 创建队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 循环调用，确定任务的放置于启动顺序
    for (int i = 0; i < 10; i++)
    {
        // 启动任务
        dispatch_sync(queue,^{
            NSLog(@"execute task : %d in thread : %@", i, [NSThread currentThread]);
        });
    }
    
    NSLog(@"%@", @"完成!");
}

/**
 *  主队列+异步方式执行任务
 *  任务顺序：先进先出
 *  线程启动方式：不开启新线程，只在主线程中执行（需要等到主线程中当前任务完成后再执行后续任务，可观察到先打印“完成”）
 */
-(void) test6
{
    // 创建队列
    dispatch_queue_t queue = dispatch_get_main_queue();
    
    // 循环调用，确定任务的放置于启动顺序
    for (int i = 0; i < 10; i++)
    {
        // 启动任务
        dispatch_async(queue,^{
            NSLog(@"execute task : %d in thread : %@", i, [NSThread currentThread]);
        });
    }
    
    NSLog(@"%@", @"完成!");
}

/**
 *  全局队列+同步方式执行任务
 *  任务顺序：先进先出
 *  线程启动方式：不开启新线程，只在主线程中执行
 */
-(void) test7
{
    // 创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // 循环调用，确定任务的放置于启动顺序
    for (int i = 0; i < 10; i++)
    {
        // 启动任务
        dispatch_sync(queue,^{
            NSLog(@"execute task : %d in thread : %@", i, [NSThread currentThread]);
        });
    }
    
    NSLog(@"%@", @"完成!");
}

/**
 *  全局队列+异步方式执行任务
 *  任务顺序：无序
 *  线程启动方式：开启多个新线程，不同任务可在不同线程中并发执行
 */
-(void) test8
{
    // 创建队列
    dispatch_queue_t queue = dispatch_get_global_queue(0, 0);
    
    // 循环调用，确定任务的放置于启动顺序
    for (int i = 0; i < 10; i++)
    {
        // 启动任务
        dispatch_async(queue,^{
            NSLog(@"execute task : %d in thread : %@", i, [NSThread currentThread]);
        });
    }
    
    NSLog(@"%@", @"完成!");
}

/**
 *  同步执行下的相同串行队列的卡死分析
 */
-(void) testForSyncAndSerial
{
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("xf", DISPATCH_QUEUE_SERIAL);
    // 异步启动任务,他将在新的线程中执行，作为测试的根线程
    dispatch_async(queue,^{
        NSLog(@"execute task1 in thread : %@  start!" , [NSThread currentThread]);
        // 在当前线程中使用与根线程相同的串行队列进行新任务的同步执行
        dispatch_sync(queue,^{
            NSLog(@"execute task2 in thread : %@" , [NSThread currentThread]);
        });
        NSLog(@"execute task1 in thread : %@  end!", [NSThread currentThread]);
    });
    
    NSLog(@"%@", @"完成!");
}


/**
 *  同步执行下的相同串行队列的卡死分析
 */
-(void) testForSyncAndConcurrent
{
    // 创建队列
    dispatch_queue_t queue = dispatch_queue_create("xf", DISPATCH_QUEUE_CONCURRENT);
    // 异步启动任务,他将在新的线程中执行，作为测试的根线程
    dispatch_async(queue,^{
        NSLog(@"execute task1 in thread : %@  start!" , [NSThread currentThread]);
        // 在当前线程中使用与根线程相同的串行队列进行新任务的同步执行
        for (int i = 0; i < 10; i++)
        {
        dispatch_sync(queue,^{
            NSLog(@"execute task %d in thread : %@" , i, [NSThread currentThread]);
        });
        }
        NSLog(@"execute task1 in thread : %@  end!", [NSThread currentThread]);
    });
    
    NSLog(@"%@", @"完成!");
}




@end
