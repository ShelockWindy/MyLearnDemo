//
//  WSGCDViewController.m
//  MyLearnDemo
//
//  Created by 孙威风 on 15/5/7.
//  Copyright (c) 2015年 ___sunweifeng___. All rights reserved.
//

#import "WSGCDViewController.h"
#import <Accelerate/Accelerate.h>

@interface WSGCDViewController ()

@end

@implementation WSGCDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
  /*  dispatch queue分成以下三种：
    
    1）运行在主线程的Main queue，通过dispatch_get_main_queue获取。
   可以看出，dispatch_get_main_queue也是一种dispatch_queue_t。
   
   2）并行队列global dispatch queue，通过dispatch_get_global_queue获取，由系统创建三个不同优先级的dispatch queue。并行队列的执行顺序与其加入队列的顺序相同。
   
   3）串行队列serial queues一般用于按顺序同步访问，可创建任意数量的串行队列，各个串行队列之间是并发的。
   
   当想要任务按照某一个特定的顺序执行时，串行队列是很有用的。串行队列在同一个时间只执行一个任务。我们可以使用串行队列代替锁去保护共享的数据。和锁不同，一个串行队列可以保证任务在一个可预知的顺序下执行。
   
   serial queues通过dispatch_queue_create创建，可以使用函数dispatch_retain和dispatch_release去增加或者减少引用计数。
   

   
   */
    dispatch_async(dispatch_get_global_queue(0, 0), ^{
        //后台执行：
        
    });

    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


//加模糊效果，image是图片，blur是模糊度
- (UIImage *)blurryImage:(UIImage *)image withBlurLevel:(CGFloat)blur {
    //模糊度,
    if ((blur < 0.1f) || (blur > 2.0f)) {
        blur = 0.5f;
    }
    
    //boxSize必须大于0
    int boxSize = (int)(blur * 100);
    boxSize -= (boxSize % 2) + 1;
    NSLog(@"boxSize:%i",boxSize);
    //图像处理
    CGImageRef img = image.CGImage;
    //需要引入#import <Accelerate/Accelerate.h>
    /*
     This document describes the Accelerate Framework, which contains C APIs for vector and matrix math, digital signal processing, large number handling, and image processing.
     本文档介绍了Accelerate Framework，其中包含C语言应用程序接口（API）的向量和矩阵数学，数字信号处理，大量处理和图像处理。
     */
    
    //图像缓存,输入缓存，输出缓存
    vImage_Buffer inBuffer, outBuffer;
    vImage_Error error;
    //像素缓存
    void *  pixelBuffer;
    
    //数据源提供者，Defines an opaque type that supplies Quartz with data.
    CGDataProviderRef inProvider = CGImageGetDataProvider(img);
    // provider’s data.
    CFDataRef inBitmapData = CGDataProviderCopyData(inProvider);
    
    //宽，高，字节/行，data
    inBuffer.width = CGImageGetWidth(img);
    inBuffer.height = CGImageGetHeight(img);
    inBuffer.rowBytes = CGImageGetBytesPerRow(img);
    inBuffer.data = (void*)CFDataGetBytePtr(inBitmapData);
    
    //像数缓存，字节行*图片高
    pixelBuffer = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    
    outBuffer.data = pixelBuffer;
    outBuffer.width = CGImageGetWidth(img);
    outBuffer.height = CGImageGetHeight(img);
    outBuffer.rowBytes = CGImageGetBytesPerRow(img);
    
    
    // 第三个中间的缓存区,抗锯齿的效果
    void *pixelBuffer2 = malloc(CGImageGetBytesPerRow(img) * CGImageGetHeight(img));
    vImage_Buffer outBuffer2;
    outBuffer2.data = pixelBuffer2;
    outBuffer2.width = CGImageGetWidth(img);
    outBuffer2.height = CGImageGetHeight(img);
    outBuffer2.rowBytes = CGImageGetBytesPerRow(img);
    
    //Convolves a region of interest within an ARGB8888 source image by an implicit M x N kernel that has the effect of a box filter.
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer2, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&outBuffer2, &inBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    error = vImageBoxConvolve_ARGB8888(&inBuffer, &outBuffer, NULL, 0, 0, boxSize, boxSize, NULL, kvImageEdgeExtend);
    
    
    if (error) {
        NSLog(@"error from convolution %ld", error);
    }
    
    //    NSLog(@"字节组成部分：%zu",CGImageGetBitsPerComponent(img));
    //颜色空间DeviceRGB
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    //用图片创建上下文,CGImageGetBitsPerComponent(img),7,8
    CGContextRef ctx = CGBitmapContextCreate(
                                             outBuffer.data,
                                             outBuffer.width,
                                             outBuffer.height,
                                             8,
                                             outBuffer.rowBytes,
                                             colorSpace,
                                             CGImageGetBitmapInfo(image.CGImage));
    
    //根据上下文，处理过的图片，重新组件
    CGImageRef imageRef = CGBitmapContextCreateImage (ctx);
    UIImage *returnImage = [UIImage imageWithCGImage:imageRef];
    
    //clean up
    CGContextRelease(ctx);
    CGColorSpaceRelease(colorSpace);
    
    free(pixelBuffer);
    free(pixelBuffer2);
    CFRelease(inBitmapData);
#warning 下面这句有危险！
    //CGColorSpaceRelease(colorSpace);
    CGImageRelease(imageRef);
    
    return returnImage;
}
/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
