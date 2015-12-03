//
//  UIImage+Utility.h
//  NCLFramework
//
//  Created by Chad Long on 4/16/13.
//  Copyright (c) 2013 NetJets, Inc. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface UIImage (Utility)

- (UIImage *)imageWithOverlayColor:(UIColor *)color;
- (UIImage *)imageWithBlendColor:(UIColor *)color;
- (UIImage *)imageWithBlendColor:(UIColor *)color mode:(CGBlendMode)mode;

@end
