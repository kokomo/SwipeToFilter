//
//  ViewController.m
//  SwipeToFilter
//
//  Created by Ryan Romanchuk on 11/16/12.
//  Copyright (c) 2012 Ryan Romanchuk. All rights reserved.
//

#import "ViewController.h"
@interface ViewController () {
    float windowWidth;
    float windowHeight;
    float widthMidpoint;
    float heightMidpoint;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    windowHeight = self.imageView.frame.size.height;
    windowWidth = self.imageView.frame.size.width;
    widthMidpoint = windowWidth / 2;
    heightMidpoint = widthMidpoint / 2;
    
    UIImage *inputImage = [UIImage imageNamed:@"kitten.jpg"];
    self.gr = [[UIGestureRecognizer alloc] init];
    self.gr.delegate = self;
    self.gr.delaysTouchesEnded = NO;
    [self.imageView addGestureRecognizer:self.gr];
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:inputImage smoothlyScaleOutput:YES];
   
    self.filterGroup = [[GPUImageFilterGroup alloc] init];
    self.brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    self.gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    self.contrastFilter = [[GPUImageContrastFilter alloc] init];
    self.saturationFilter = [[GPUImageSaturationFilter alloc] init];
    self.alphaBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    
    
    
    [self.brightnessFilter forceProcessingAtSize:self.imageView.sizeInPixels]; // This is now needed to make the filter run at the smaller output size
    
    [self.brightnessFilter addTarget:self.saturationFilter];
    self.filterGroup.initialFilters = [NSArray arrayWithObjects:self.brightnessFilter, nil];
    self.filterGroup.terminalFilter = self.saturationFilter;
    
    [self.sourcePicture addTarget:self.filterGroup];
    [self.filterGroup addTarget:self.imageView];
    [self.sourcePicture processImage];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesBegan:touches withEvent:event];
    
    DLog(@"touches began touches: %@  event %@", touches, event);
}

- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesMoved:touches withEvent:event];
    UITouch *touch = [touches anyObject];
    CGPoint location = [touch locationInView:self.imageView];
    CGPoint prevLocation = [touch previousLocationInView:self.imageView];
    
    if (location.x - prevLocation.x > 0) {
        DLog(@"finger touch went right");
        float filterValue = (location.x - -1) * (1 - -1) / (windowWidth - 0) + -1;
        DLog(@"x: %f filter value: %f", location.x, filterValue);
        self.brightnessFilter.brightness = filterValue;
        [self.sourcePicture processImage];

    } else {
        DLog(@"finger touch went left");
        float filterValue = (location.x - -1) * (1 - -1) / (windowWidth - 0) + -1;
        DLog(@"x: %f filter value: %f", location.x, filterValue);
        self.brightnessFilter.brightness = filterValue;
        [self.sourcePicture processImage];
    }
    if (location.y - prevLocation.y > 0) {
        //finger touch went upwards
        DLog(@"finger touch went up");
        float filterValue = (location.y - 0) * (2 - -0) / (windowHeight - 0) + 0;
        DLog(@"new filter value %f", filterValue);
        self.saturationFilter.saturation = filterValue;
        [self.sourcePicture processImage];

    } else {
        //finger touch went downwards
        DLog(@"finger touch went downwards");
        float filterValue = (location.y - 0) * (2 - -0) / (windowHeight - 0) + 0;
        DLog(@"new filter value %f", filterValue);
        self.saturationFilter.saturation = filterValue;
        [self.sourcePicture processImage];

    }
    //DLog(@"done");
}


- (float)scaleRange:(float)value fromMinValue:(float)fromMinValue fromMaxValue:(float)fromMaxValue toMinValue:(float)toMinValue toMaxValue:(float)toMaxValue
{

    return (value - fromMinValue) * (toMaxValue - toMinValue) / (fromMaxValue - fromMinValue) + toMinValue;

}


- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesEnded:touches withEvent:event];
    DLog(@"touches ended");

}


- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event {
    [super touchesCancelled:touches withEvent:event];
    DLog(@"touches canceled");
}


- (void)viewDidUnload {
    [super viewDidUnload];
}
@end
