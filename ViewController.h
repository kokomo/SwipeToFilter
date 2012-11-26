//
//  ViewController.h
//  SwipeToFilter
//
//  Created by Ryan Romanchuk on 11/16/12.
//  Copyright (c) 2012 Ryan Romanchuk. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GPUImage.h"

@interface ViewController : UIViewController <UIGestureRecognizerDelegate>

@property (strong, nonatomic) IBOutlet GPUImageView *imageView;
@property (weak, nonatomic) IBOutlet UIImageView *testImageView;
@property (strong) UIImage *inputImage;

@property (strong) GPUImageBrightnessFilter *brightnessFilter;
@property (strong) GPUImageContrastFilter *contrastFilter;
@property (strong) GPUImageGaussianBlurFilter *gaussianBlurFilter;
@property (strong) GPUImageSaturationFilter *saturationFilter;
@property (strong) GPUImageMultiplyBlendFilter *multiplyBlendFilter;
@property (strong) GPUImageAlphaBlendFilter *alphaBlendFilter;
@property (strong) GPUImageAlphaBlendFilter *alphaBlendFilterForBubbles;

@property (strong) GPUImagePicture *sourcePicture;
@property (strong) GPUImageFilterGroup *filterGroup;
@property (strong) UIGestureRecognizer *gr;
@property (strong) GPUImagePicture *scratches;
@property (strong) GPUImagePicture *bubbles;

@end
