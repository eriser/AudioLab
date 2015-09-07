//
//  WaveShape.m
//  WaveSelector
//
//  Created by Ness on 7/13/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "WaveShape.h"
#import <stdlib.h>

@interface WaveShape(){
    CGFloat height;
    CGFloat width;
}

@end

@implementation WaveShape
@synthesize shape;
@synthesize squareDuty;
-(void)drawNoiseWaveinContext:(CGContextRef)context andRect:(CGRect)rect{
    
    
    //Create a mask
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef con=UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(con);
    CGContextMoveToPoint(con, 0, height/2);
    CGContextAddLineToPoint(con, 10, height/2);
    int r;
    for(int i=11;i<(int)(width-5);i++){
        r=arc4random_uniform((int)height);
        //printf("%i ",r);
        CGContextAddLineToPoint(con, i, r);
    }
    CGContextMoveToPoint(con, width-5, height/2);
    CGContextAddLineToPoint(con, width, height/2);
    
    //    CGContextAddLineToPoint(context, 2*(width/4), height-3);
    //    CGContextAddLineToPoint(context, 3*(width/4), 3);
    //    CGContextAddLineToPoint(context, width, height-3);
    
    CGContextSetLineWidth(con, 2);
    CGContextSetLineCap(con, kCGLineCapRound);
    CGContextDrawPath(con, kCGPathStroke);
    
    CGImageRef mask=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    //context=UIGraphicsGetCurrentContext();
    
    //Clip the mask to the current context (You need to update the context)
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    
    
    //Now you can draw the gradient
    //Define the colour steps
    CGFloat components[8] = {
        44/255.0,194/255.0, 254/255.0, 1.0,     // Blue
        243/255.0,254/255.0, 241/255.0, 1.0 };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    //Define the gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Choose a colour space
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Create and Draw the gradient
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}

-(void)drawTriangleWaveinContext:(CGContextRef)context andRect:(CGRect)rect{
    
    //Create a mask
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef con=UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(con);
    CGContextMoveToPoint(con, 3, height-3);
    CGContextAddLineToPoint(con, width/4, 3);
    CGContextAddLineToPoint(con, 2*(width/4), height-3);
    CGContextAddLineToPoint(con, 3*(width/4), 3);
    CGContextAddLineToPoint(con, width, height-3);
    
    CGContextSetLineWidth(con, 3);
    CGContextSetLineCap(con, kCGLineCapRound);
    CGContextDrawPath(con, kCGPathStroke);
    
    CGImageRef mask=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    //context=UIGraphicsGetCurrentContext();
    
    //Clip the mask to the current context (You need to update the context)
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    
    
    //Now you can draw the gradient
    //Define the colour steps
    CGFloat components[8] = {
        44/255.0,194/255.0, 254/255.0, 1.0,     // Blue
        243/255.0,254/255.0, 241/255.0, 1.0 };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    //Define the gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Choose a colour space
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Create and Draw the gradient
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}

-(void)drawSaw1WaveinContext:(CGContextRef)context andRect:(CGRect)rect{
    //Create a mask
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef con=UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(con);
    CGContextMoveToPoint(con, 3, height-3);
    CGContextAddLineToPoint(con, 3, 3);
    CGContextAddLineToPoint(con, width/2,height-3);
    CGContextAddLineToPoint(con, width/2,3);
    CGContextAddLineToPoint(con, width-3,height-3);
    CGContextSetShadowWithColor(con, CGSizeMake(0, 0), 25.0f, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(con, 3);
    CGContextSetLineCap(con, kCGLineCapRound);
    CGContextDrawPath(con, kCGPathStroke);
    
    CGImageRef mask=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    //context=UIGraphicsGetCurrentContext();
    
    //Clip the mask to the current context (You need to update the context)
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    
    
    //Now you can draw the gradient
    //Define the colour steps
    CGFloat components[8] = {
        44/255.0,194/255.0, 254/255.0, 1.0,     // Blue
        243/255.0,254/255.0, 241/255.0, 1.0 };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    //Define the gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Choose a colour space
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Create and Draw the gradient
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}

-(void)drawSaw2WaveinContext:(CGContextRef)context andRect:(CGRect)rect{
    //Create a mask
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef con=UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(con);
    CGContextMoveToPoint(con, 3, height-3);
    CGContextAddLineToPoint(con, 3, 3);
    CGContextAddCurveToPoint(con, (width*0.25),(height*0.10),(width*0.45),(height*0.80),(width*0.50),height-3);
    CGContextAddLineToPoint(con, width*0.5,3);
    CGContextAddCurveToPoint(con, (width*0.75),(height*0.10),(width*0.95),(height*0.80), width,height-3);
    CGContextSetShadowWithColor(con, CGSizeMake(0, 0), 25.0f, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(con, 3);
    CGContextSetLineCap(con, kCGLineCapRound);
    CGContextDrawPath(con, kCGPathStroke);
    
    CGImageRef mask=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    //context=UIGraphicsGetCurrentContext();
    
    //Clip the mask to the current context (You need to update the context)
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    
    
    //Now you can draw the gradient
    //Define the colour steps
    CGFloat components[8] = {
        44/255.0,194/255.0, 254/255.0, 1.0,     // Blue
        243/255.0,254/255.0, 241/255.0, 1.0 };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    //Define the gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Choose a colour space
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Create and Draw the gradient
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}


-(void)drawSineWaveinContext:(CGContextRef)context andRect:(CGRect)rect{
    //Create a mask
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef con=UIGraphicsGetCurrentContext();
    
    CGContextBeginPath(con);
    CGContextMoveToPoint(con, 3, height/2);
    CGContextAddCurveToPoint(con, width/6, 0, 2*(width/6), 0, 3*(width/6), height/2);
    CGContextAddCurveToPoint(con, 4*(width/6), height, 5*(width/6), height, width-3, height/2);
    
    CGContextSetShadowWithColor(con, CGSizeMake(0, 0), 25.0f, [UIColor blackColor].CGColor);
    CGContextSetLineWidth(con, 3);
    CGContextSetLineCap(con, kCGLineCapRound);
    CGContextDrawPath(con, kCGPathStroke);
    
    CGImageRef mask=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    //context=UIGraphicsGetCurrentContext();
    //Clip the mask to the current context (You need to update the context)
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    
    
    //Now you can draw the gradient
    //Define the colour steps
    CGFloat components[8] = {
        44/255.0,194/255.0, 254/255.0, 1.0,     // Blue
        243/255.0,254/255.0, 241/255.0, 1.0 };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    //Define the gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Choose a colour space
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Create and Draw the gradient
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    
    CGContextRestoreGState(context);
}

-(void)drawSquareWaveInContext:(CGContextRef)context andRect:(CGRect)rect{
    self.transform=CGAffineTransformMakeScale(1, -1);
    self.backgroundColor=[UIColor clearColor];
    width=self.bounds.size.width;
    height=self.bounds.size.height;
    
    //Create a mask
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef con=UIGraphicsGetCurrentContext();
    CGFloat offset=0.05;
    
    //squareDuty>=80?squareDuty=80:squareDuty;
    //squareDuty<=20?squareDuty=20:squareDuty;
    CGFloat duty=squareDuty;
    CGContextBeginPath(con);
    CGContextMoveToPoint   (con,    width*offset,   height-(height*offset));

    CGContextAddLineToPoint(con,    width*offset,            height*offset);
    CGContextAddLineToPoint(con,    width*(duty+offset),     height*offset );          /*20%*/
    CGContextAddLineToPoint(con,    width*(duty+offset),     height-(height*offset));
    CGContextAddLineToPoint(con,    width-(width*offset),    height-(height*offset));
    CGContextAddLineToPoint(con,    width-(width*offset),    height*offset);

    
    
    
    
    CGContextSetLineWidth(con, 2);
    CGContextSetLineCap(con, kCGLineCapRound);
    CGContextDrawPath(con, kCGPathStroke);
    
    CGImageRef mask=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    //context=UIGraphicsGetCurrentContext();
    
    //Clip the mask to the current context (You need to update the context)
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    
    
    //Now you can draw the gradient
    //Define the colour steps
    CGFloat components[8] = {
        44/255.0,194/255.0, 254/255.0, 1.0,     // Blue
        243/255.0,254/255.0, 241/255.0, 1.0 };
    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    //Define the gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Choose a colour space
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Create and Draw the gradient
    CGContextDrawLinearGradient(context, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    CGContextRestoreGState(context);
}

- (void)drawRect:(CGRect)rect {
    CGContextRef context=UIGraphicsGetCurrentContext();
    self.transform=CGAffineTransformMakeScale(1, -1);
    self.backgroundColor=[UIColor blackColor];
    width=self.bounds.size.width;
    height=self.bounds.size.height;
    
    //squareDuty=0.20;        //--Default square duty
    
    switch (shape) {
        case NOISE:
            [self drawNoiseWaveinContext:context andRect:rect];
            break;
            
        case SINE:
            [self drawSineWaveinContext:context andRect:rect];
            
            break;
            
        case TRIANGLE:
            [self drawTriangleWaveinContext:context andRect:rect];
            
            break;
            
        case SAW1:
            [self drawSaw1WaveinContext:context andRect:rect];
            
            break;
            
        case SAW2:
            [self drawSaw2WaveinContext:context andRect:rect];
            break;
            
        case SQUARE:
            [self drawSquareWaveInContext:context andRect:rect];
            break;
            
        default:
            break;
    }
}

 

@end
