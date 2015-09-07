//
//  KeyLayer.m
//  PianoKeyboard
//
//  Created by Ness on 8/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "KeyLayer.h"

@implementation KeyLayer
@synthesize isBlack;
////--- Called at initialization
-(void)layoutSublayers{
    //NSLog(@"layoutsublayers");
    W=self.bounds.size.width;
    H=self.bounds.size.height;
    [self display];
    
}

////--- Drawing routines.
-(void)drawInContext:(CGContextRef)context{
    if(isBlack){
        [self drawBlackKey:context];
    }else{
        whiteKeyImg=[UIImage imageNamed:@"blancoMarfil.jpg"];
        [self drawWhiteKey:context];
    }
}


////////////////////////////////////////////////////////////////////////
////////////////////////    DRAWING METHODS     ////////////////////////
////////////////////////////////////////////////////////////////////////
///--- Black key
-(void) drawBlackKey:(CGContextRef)context{
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
    //CGContextRef context= UIGraphicsGetCurrentContext();
    
    ///--- Draw  First Layer
    //Draw a mask with the form of a round rectangle
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);          //Create context
    CGContextRef maskContext= UIGraphicsGetCurrentContext();
    
    CGContextFillRect(maskContext, CGRectInset(self.bounds, 5, 5));
    CGImageRef mask= CGBitmapContextCreateImage(UIGraphicsGetCurrentContext()); //Create img
    UIGraphicsEndImageContext();
    //-- Draw using the mask as clip area
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    CGImageRelease(mask);
    //-- Draw the gradient
    CGFloat locs[3]={0.15, 0.95,1.0};
    CGFloat colors[12]={
        15/255.0f, 16/255.0f, 16/255.0f, 1.0,     //Black
        150/255.0f, 150/255.0f, 150/255.0f, 1.0,  //White
        75/255.0f, 77/255.0f, 83/255.0f, 1.0      //Gray
    };
    CGColorSpaceRef sp= CGColorSpaceCreateDeviceRGB();
    CGGradientRef grad= CGGradientCreateWithColorComponents(sp, colors, locs, 2);
    CGContextDrawLinearGradient(context,
                                grad,
                                CGPointMake(W/2,0),
                                CGPointMake(W/2,H),
                                0);
    CGColorSpaceRelease(sp);
    CGGradientRelease(grad);
    CGContextRestoreGState(context);
    
    //    ////--- Draw  Second Layer
    //
    //-- Create a mask
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);          //Create context
    maskContext= UIGraphicsGetCurrentContext();
    CGContextFillRect(maskContext, CGRectInset(self.bounds, 10, 10));               //Draw mask
    mask= CGBitmapContextCreateImage(UIGraphicsGetCurrentContext()); //Create img
    UIGraphicsEndImageContext();                                                //Release context
    //--Draw using the mask as clip area
    CGContextSaveGState(context);                                               //Save before changes
    CGContextClipToMask(context, self.bounds, mask);                            //Clip to mask
    CGImageRelease(mask);                                                       //Release the mask
    //-- Draw a gradient
    sp= CGColorSpaceCreateDeviceRGB();
    grad= CGGradientCreateWithColorComponents(sp, colors, locs, 2);
    CGContextDrawLinearGradient(context,
                                grad,
                                CGPointMake(W/2, H),
                                CGPointMake(W/2,0),
                                0);
    CGColorSpaceRelease(sp);
    CGGradientRelease(grad);
    CGContextRestoreGState(context);
    //
    //    ////--- Draw Third Layer
    //
    //    ////--- Create a another mask
    UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);          //Create context
    maskContext= UIGraphicsGetCurrentContext();
    ////--- Fix the coordinate system
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    transform = CGAffineTransformTranslate(transform, 0.0f, -H);
    //CGContextConcatCTM(maskContext, transform);
    ////--- Start drawing on the maskContext
    CGContextBeginPath(maskContext);
    [[UIColor orangeColor]set];
    CGContextMoveToPoint(maskContext, 0, H*0.98);
    CGContextAddLineToPoint(maskContext, W*0.95, H*0.98);
    CGContextAddCurveToPoint(maskContext, W*0.95, H*0.85, W*0.85, H*0.79, W*0.70, H*0.8);
    CGContextAddLineToPoint(maskContext, W*0.17, H*0.8);
    CGContextAddCurveToPoint(maskContext, W*0.06, H*0.85, W*0.01, H*0.98, W*0.06, H*0.98);
    CGContextFillPath(maskContext);
    mask= CGBitmapContextCreateImage(UIGraphicsGetCurrentContext()); //Create img
    UIGraphicsEndImageContext();                                     //Release context
    ////--- Clip the mask to the context
    CGContextSaveGState(context);                                               //Save before changes
    ////--- Fix coordinate system again
    CGContextConcatCTM(context, transform);
    CGContextClipToMask(context, self.bounds, mask);                            //Clip to mask
    CGImageRelease(mask);
    ////--- Draw another gradient
    sp= CGColorSpaceCreateDeviceRGB();
    CGFloat locs2[3]={0.105,0.2,0.35};
    grad= CGGradientCreateWithColorComponents(sp, colors, locs2, 3);
    CGContextDrawLinearGradient(context,
                                grad,
                                CGPointMake(W/2, 0),
                                CGPointMake(W/2, H),
                                0);
    CGColorSpaceRelease(sp);
    CGGradientRelease(grad);
    CGContextRestoreGState(context);
    //
    //    ////--- Draw shadows
    CGContextSaveGState(context);
    ////    ////--- On layer 1
    
    CGContextSetLineWidth(context, 2);
    [[UIColor blackColor]set];
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 10, [UIColor blueColor].CGColor);
    CGContextBeginPath(context);
    CGContextMoveToPoint(context, W*0.15, H*0.02);
    CGContextAddLineToPoint(context, W*0.85, H*0.02);
    CGContextMoveToPoint(context, W*0.96, H*0.10);
    CGContextAddLineToPoint(context, W*0.96, H*0.90);
    CGContextMoveToPoint(context, W*0.85, H*0.98);
    CGContextAddLineToPoint(context, W*0.15, H*0.98);
    CGContextMoveToPoint(context, W*0.04, H*0.90);
    CGContextAddLineToPoint(context, W*0.04, H*0.10);
    CGContextStrokePath(context);
    
    //    //    ////--- On layer 2
    CGContextSetLineWidth(context, 4);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 15, [UIColor blueColor].CGColor);
    CGContextStrokeRect(context, CGRectMake(W*0.20, H*0.07, W*0.6, H*0.73));
    //
    //    ////--- On layer 3
    //CGContextConcatCTM(context, transform);
    CGContextBeginPath(context);
    [[UIColor blackColor]set];
    CGContextSetLineWidth(context, 2);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 10, [UIColor blueColor].CGColor);
    CGContextMoveToPoint(context, W*0.10, H*0.98);
    CGContextAddLineToPoint(context, W*0.90, H*0.98);
    CGContextAddCurveToPoint(context, W*0.95, H*0.85, W*0.85, H*0.79, W*0.70, H*0.8);
    CGContextAddLineToPoint(context, W*0.17, H*0.8);
    CGContextAddCurveToPoint(context, W*0.06, H*0.85, W*0.01, H*0.98, W*0.10, H*0.98);
    CGContextStrokePath(context);
    
    
    CGContextRestoreGState(context);
}
///--- White key
-(void)drawWhiteKey:(CGContextRef)context{
    //-- Get a CGimage reference from the UIImage you want as background
    CGImageRef backgroundImRef=whiteKeyImg.CGImage;
    //-- You can now draw your base image in this context
    CGContextSaveGState(context);
    CGContextDrawImage(context, CGRectInset(self.bounds, 3, 3), backgroundImRef);
    CGImageRelease(backgroundImRef);    //Let it go now
    //    ////-- Draw the shadow
    CGContextBeginPath(context);
    CGContextSetLineWidth(context, 5);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 10, [UIColor blackColor].CGColor);
    CGContextMoveToPoint(context, 0, 0);
    CGContextAddLineToPoint(context, W,0);
    CGContextAddLineToPoint(context, W, H);
    CGContextAddLineToPoint(context, 0, H);
    CGContextClosePath(context);
    CGContextStrokePath(context);
    CGContextRestoreGState(context);
}

@end
