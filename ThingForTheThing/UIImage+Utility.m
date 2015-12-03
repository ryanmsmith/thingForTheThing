//
//  UIImage+Utility.m
//  NCLFramework
//
//  Created by Chad Long on 4/16/13.
//  Copyright (c) 2013 NetJets, Inc. All rights reserved.
//

#import "UIImage+Utility.h"

@implementation UIImage (Utility)

- (UIImage *)imageWithOverlayColor:(UIColor *)color
{
    return [self imageWithBlendColor:color mode:kCGBlendModeSourceIn];
}

- (UIImage *)imageWithBlendColor:(UIColor *)color
{
    return [self imageWithBlendColor:color mode:kCGBlendModeMultiply];
}

- (UIImage *)imageWithBlendColor:(UIColor *)color mode:(CGBlendMode)mode
{
    CGRect rect = CGRectMake(0.0f, 0.0f, self.size.width, self.size.height);
    
    if (&UIGraphicsBeginImageContextWithOptions)
    {
        CGFloat imageScale = 1.0f;
        if ([self respondsToSelector:@selector(scale)])  // The scale property is new with iOS4.
            imageScale = self.scale;
        UIGraphicsBeginImageContextWithOptions(self.size, NO, imageScale);
    }
    
    [self drawInRect:rect];
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSetBlendMode(context, mode);
    
    CGContextSetFillColorWithColor(context, color.CGColor);
    CGContextFillRect(context, rect);
    
    UIImage *image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return image;
}

@end
