//
//  AudioTrack.m
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "AudioTrack.h"
#define kDefaultGraphWidth 900
#define kScaleFactor        10.0
//-- The offsets create a sort of inner frame for the plot
#define kOffsetX 10
#define kOffsetY 10

//-- Define the space between plot points
#define kStepX 2
#define kStepY 50

//-- It is the top of the graph. in iOS the coordinates are upside down
//   so the 0 is the top and the maximun Height is the bottom
#define kGraphTop 0
@implementation AudioTrack
@synthesize data,au;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        timer=[[NSTimer alloc]init];
        testSelector=NSSelectorFromString(@"test");
        
        //-- Geometric info
        
        
        W=self.bounds.size.width;
        H=self.bounds.size.height;

        //        maxGraphHeight = H - kOffsetY;
        //        //lastPoint=CGPointMake(kOffsetX, H - maxGraphHeight * data[0]);
        //        lastPoint=CGPointMake(kOffsetX, H - maxGraphHeight * data);
        //        lastIndex=0;
        //        data=0;
        
        maxGraphHeight = H - kOffsetY;
        //lastPoint=CGPointMake(kOffsetX, H - maxGraphHeight * data);
        lastPoint=CGPointMake(kOffsetX, H*0.5);
        lastIndex=0;
        data=-1.0;
        
        
        
        
        
        ////Layer
        backgroundColor=[UIColor colorWithRed:250/255.0f green:197/255.0f blue:48/255.0f alpha:0.5];
        //backgoundColorTransparent=[UIColor colorWithRed:250/255.0f green:197/255.0f blue:48/255.0f alpha:0.2];
        backgoundColorTransparent=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.1];
        CGColorRef color1 =backgroundColor.CGColor;
        CGColorRef color2 =backgoundColorTransparent.CGColor;
        NSArray *colors=[[NSArray alloc]initWithObjects:(__bridge id)color1,(__bridge id)color2, nil];
        //-- Construct the array that have the positions of the gradient layer
        NSNumber *location1= [[NSNumber alloc]initWithFloat:0.1];
        NSNumber *location2= [[NSNumber alloc]initWithFloat:0.4];
        //NSNumber *location3= [[NSNumber alloc]initWithFloat:0.9];
        NSArray *locations=[[NSArray alloc]initWithObjects:location1,location2, nil];
        gradLayer=[[CAGradientLayer alloc]init];
        gradLayer.colors=colors;
        gradLayer.locations=locations;
        gradLayer.frame=self.bounds;
        gradLayer.startPoint=CGPointMake(0, 0);
        gradLayer.endPoint=CGPointMake(1,1);
        gradLayer.cornerRadius=20.0;
        [self.layer addSublayer:gradLayer];
        
        
        //-- Create an image for cleaning
        UIGraphicsBeginImageContext(self.bounds.size);
        img=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
        cleanImage=[UIImage imageWithCGImage:img];
        
        
    }
    return self;
}

- (void)drawLineGraphWithContext:(CGContextRef)ctx
{   CGContextSaveGState(ctx);
    
    if (pastImage!=NULL) {
        //-- Update plot
        [pastImage drawInRect:self.bounds blendMode:kCGBlendModeMultiply alpha:1.0];
    }
    //-- Context settings: Line width and line color
    CGContextSetLineWidth(ctx, 2.0);
    CGContextSetStrokeColorWithColor(ctx, [[UIColor colorWithRed:1.0 green:0.5 blue:0 alpha:1.0] CGColor]);
    //-- Begint path
    CGContextBeginPath(ctx);
    CGContextMoveToPoint(ctx, lastPoint.x ,lastPoint.y);
    
    //-- Prepare next point
    lastPoint.x=kOffsetX + (++lastIndex) * kStepX;
    //lastPoint.y=H - maxGraphHeight * data[(lastIndex)];
    lastPoint.y= H - maxGraphHeight * (data*kScaleFactor) - (H/2);
    
    //-- Add line to next point
    CGContextAddLineToPoint(ctx, lastPoint.x,lastPoint.y);
    CGContextDrawPath(ctx, kCGPathStroke);
    CGContextRestoreGState(ctx);
    
    //Check if the view is full
    if (lastPoint.x>=W) {
        [self resetGraph];
        pastImage=cleanImage;
    }else{
        
        //Take a picture for the next call
        img=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
        pastImage=[UIImage imageWithCGImage:img];
        CGImageRelease(img);
    }
    
    
}


-(void)drawRect:(CGRect)rect{
    //-- The first drawn includes the background image and mesh
    CGContextRef context = UIGraphicsGetCurrentContext();

        //-- Draw next line
        [self drawLineGraphWithContext:context];
    
    
}




-(void)activateLoop{
    NSLog(@"timer activation");
    timer= [NSTimer scheduledTimerWithTimeInterval:1.0/100 target:self selector:@selector(test:) userInfo:nil repeats:YES];
}

-(void)deactivateLoop{
    NSLog(@"timer de-activation");
    if (timer) {
        [timer invalidate];
        timer = nil;
    }
}
-(void)test:(NSTimer *)timer{
    
    float *f=[au readBuffer];
    
    data=*f;
    [self setNeedsDisplay];
}

-(void)resetGraph{
    lastPoint.x=kOffsetX;
    lastIndex=1.0;
    //[self setNeedsDisplay];
}
@end
