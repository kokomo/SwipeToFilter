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
    BOOL touchPastMidpoint;
}

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    windowHeight = self.view.frame.size.height;
    windowWidth = self.view.frame.size.width;
    widthMidpoint = windowWidth / 2;
    heightMidpoint = widthMidpoint / 2;
    
    self.filterGroup = [[GPUImageFilterGroup alloc] init];
    self.brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    self.gaussianBlurFilter = [[GPUImageGaussianBlurFilter alloc] init];
    self.contrastFilter = [[GPUImageContrastFilter alloc] init];
    self.saturationFilter = [[GPUImageSaturationFilter alloc] init];
    self.brightnessFilter.brightness = 0;
    self.alphaBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    self.alphaBlendFilter.mix = 0.5;
    self.alphaBlendFilterForBubbles = [[GPUImageAlphaBlendFilter alloc] init];
    self.alphaBlendFilterForBubbles.mix = 0.0;
    
    self.bubbles = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"bubbles.png"]];
    
    self.inputImage = [UIImage imageNamed:@"samplephoto.jpg"];
    self.gr = [[UIGestureRecognizer alloc] init];
    self.gr.delegate = self;
    self.gr.delaysTouchesEnded = NO;
    [self.imageView addGestureRecognizer:self.gr];
    
   
    
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:self.inputImage smoothlyScaleOutput:YES];
    
    //pass1
    self.scratches = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"scratches.png"]];    
    [self.alphaBlendFilter addTarget:self.imageView];
    [self.sourcePicture addTarget:self.alphaBlendFilter];
    [self.scratches addTarget:self.alphaBlendFilter];
    [self.scratches processImage];
    [self.sourcePicture processImage];
    
    touchPastMidpoint = NO;
    
    
//    [self.brightnessFilter forceProcessingAtSize:self.imageView.sizeInPixels]; // This is now needed to make the filter run at the smaller output size
//    
//    [self.brightnessFilter addTarget:self.saturationFilter];
//    self.filterGroup.initialFilters = [NSArray arrayWithObjects:self.brightnessFilter, nil];
//    self.filterGroup.terminalFilter = self.saturationFilter;
//    
//    [self.sourcePicture addTarget:self.filterGroup];
//    [self.filterGroup addTarget:self.imageView];
//    [self.sourcePicture processImage];

	// Do any additional setup after loading the view, typically from a nib.
}

- (void)setupScratches {
    touchPastMidpoint = NO;
    DLog(@"current targets %@", self.alphaBlendFilterForBubbles.targets);
    [self.alphaBlendFilterForBubbles removeAllTargets];
    [self.sourcePicture removeAllTargets];
    [self.bubbles removeAllTargets];
    
    self.alphaBlendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    self.alphaBlendFilter.mix = 0;
    self.scratches = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"scratches.png"]];
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:self.inputImage smoothlyScaleOutput:YES];

    //pass1
    [self.alphaBlendFilter addTarget:self.imageView];
    [self.sourcePicture addTarget:self.alphaBlendFilter];
    [self.scratches addTarget:self.alphaBlendFilter];
    [self.scratches processImage];
    [self.sourcePicture processImage];
}

- (void)setupBubbles {
    touchPastMidpoint = YES;
    DLog(@"current targets %@", self.alphaBlendFilter.targets);
    [self.alphaBlendFilter removeAllTargets];
    [self.sourcePicture removeAllTargets];
    [self.scratches removeAllTargets];
    
    self.bubbles = [[GPUImagePicture alloc] initWithImage:[UIImage imageNamed:@"bubbles.png"]];
    self.sourcePicture = [[GPUImagePicture alloc] initWithImage:self.inputImage smoothlyScaleOutput:YES];
    self.alphaBlendFilterForBubbles = [[GPUImageAlphaBlendFilter alloc] init];
    self.alphaBlendFilterForBubbles.mix = 0;
    [self.alphaBlendFilterForBubbles addTarget:self.imageView];
    [self.sourcePicture addTarget:self.alphaBlendFilterForBubbles];
    [self.bubbles addTarget:self.alphaBlendFilterForBubbles];
    [self.bubbles processImage];
    [self.sourcePicture processImage];

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
    CGPoint location = [touch locationInView:self.view];
    CGPoint prevLocation = [touch previousLocationInView:self.view];
    
    if (location.x - prevLocation.x > 0) {
        DLog(@"finger touch went right");
        if (location.x < widthMidpoint) {
             //DLog(@"before midpoint")
            float x = widthMidpoint - location.x;
            float filterValue = [self scaleRange:x fromMinValue:0 fromMaxValue:widthMidpoint toMinValue:0 toMaxValue:1];
            //DLog(@"x: %f filter value: %f", location.x, filterValue);
            self.alphaBlendFilter.mix = filterValue;
            if (touchPastMidpoint) {
                [self setupScratches];
            }
            [self.scratches processImage];
            [self.sourcePicture processImage];
        } else {
            //DLog(@"past midpoint");
            float filterValue = [self scaleRange:location.x fromMinValue:widthMidpoint fromMaxValue:windowWidth toMinValue:0 toMaxValue:1];
            //DLog(@"x: %f filter value: %f", location.x, filterValue);
            self.alphaBlendFilterForBubbles.mix = filterValue;
            if (!touchPastMidpoint) {
                [self setupBubbles];
            }
            [self.bubbles processImage];
            [self.sourcePicture processImage];
        }
        
        
    } else {
        //DLog(@"finger touch went left");
        if (location.x < widthMidpoint) {
            //DLog(@"before midpoint")
            float x = widthMidpoint - location.x;
            float filterValue = [self scaleRange:x fromMinValue:0 fromMaxValue:widthMidpoint toMinValue:0 toMaxValue:1];
            //DLog(@"x: %f filter value: %f", location.x, filterValue);
            self.alphaBlendFilter.mix = filterValue;
            if (touchPastMidpoint) {
                [self setupScratches];
            }
            [self.scratches processImage];
            [self.sourcePicture processImage];
        } else {
            //DLog(@"past midpoint");
            float filterValue = [self scaleRange:location.x fromMinValue:widthMidpoint fromMaxValue:windowWidth toMinValue:0 toMaxValue:1];
            //DLog(@"x: %f filter value: %f", location.x, filterValue);
            self.alphaBlendFilterForBubbles.mix = filterValue;
            if (!touchPastMidpoint) {
                [self setupBubbles];
            }
            [self.bubbles processImage];
            [self.sourcePicture processImage];
        }

    }
    if (location.y - prevLocation.y > 0) {
        //finger touch went upwards
        DLog(@"finger touch went up");
        float filterValue = [self scaleRange:location.y fromMinValue:0 fromMaxValue:windowHeight toMinValue:-1 toMaxValue:1];
        DLog(@"new filter value %f", filterValue);
        self.brightnessFilter.brightness = filterValue;
        [self.sourcePicture processImage];

    } else {
        //finger touch went downwards
        //DLog(@"finger touch went downwards");
        float filterValue = [self scaleRange:location.y fromMinValue:0 fromMaxValue:windowHeight toMinValue:-1 toMaxValue:1];
        DLog(@"new filter value %f", filterValue);
        self.brightnessFilter.brightness = filterValue;
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
    [self setTestImageView:nil];
    [super viewDidUnload];
}
@end
