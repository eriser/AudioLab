//
//  AudioTrack.m
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "AudioTrack.h"
#define kDefaultGraphWidth 900

//-- The offsets create a sort of inner frame for the plot
#define kOffsetX 10
#define kOffsetY 10

//-- Define the space between plot points
#define kStepX 2


//-- It is the top of the graph. in iOS the coordinates are upside down
//   so the 0 is the top and the maximun Height is the bottom
#define kGraphTop 0



@class AudioController;
@interface AudioController
-(float *)readBuffer;
-(void)setDrawingTo:(BOOL)isDrawing;
@property int dataLength;
@end

@class ControlPanel;
@interface ControlPanel
@property AudioController *controlPanelAU;
@end


@implementation AudioTrack
@synthesize timer,data;


#pragma mark Initialization
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        ///-- Global geometry
        self.backgroundColor=[UIColor clearColor];
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        
        ///-- Prepare the auxiliar variables for drawing
        maxGraphHeight = H - kOffsetY;
        lastPoint=CGPointMake(kOffsetX, H - maxGraphHeight * data);
        lastIndex=0;
        data=-1.0;
        
        //-- Create an image for cleaning
        UIGraphicsBeginImageContext(self.bounds.size);
        img=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
        cleanImage=[UIImage imageWithCGImage:img];
        
        playing=NO;
    }
    return self;
}

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        ///-- Global geometry
        self.backgroundColor=[UIColor clearColor];
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        
        ///-- Prepare the auxiliar variables for drawing
        maxGraphHeight = H - kOffsetY;
        lastPoint=CGPointMake(kOffsetX, H - maxGraphHeight * data);
        lastIndex=0;
        data=-1.0;
        
        //-- Create an image for cleaning
        UIGraphicsBeginImageContext(self.bounds.size);
        img=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
        cleanImage=[UIImage imageWithCGImage:img];
        
        playing=NO;
    }
    return self;
}
#pragma mark Drawing Methods
- (void)drawLineGraphWithContext:(CGContextRef)ctx
{
    
    if (pastImage!=NULL) {
        [pastImage drawInRect:self.bounds blendMode:kCGBlendModeNormal alpha:0.95];
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
    lastPoint.y=H - maxGraphHeight * data- (H*0.20);
    
    //-- Add line to next point
    CGContextAddLineToPoint(ctx, lastPoint.x,lastPoint.y);
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    //Take a picture for the next call
    img=CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    pastImage=[UIImage imageWithCGImage:img];
    CGImageRelease(img);
    
}

-(void)drawRect:(CGRect)rect{
    CGContextRef context=UIGraphicsGetCurrentContext();
    if (playing) {
        CGContextSaveGState(context);
        [self drawLineGraphWithContext:context];
        CGContextRestoreGState(context);
    }else{
        //[cleanImage drawInRect:self.bounds];
        pastImage=cleanImage;
    }
    
}

#pragma mark Drawing Loop Control
-(void)activateLoop{
    if (timer==nil) {
        timer=[NSTimer scheduledTimerWithTimeInterval:1.0/150.0 target:self selector:@selector(plotAudioData:) userInfo:nil repeats:YES];
        ControlPanel* cp=(ControlPanel*) [self superview];
        AudioController *au=[cp controlPanelAU];

        [au setDrawingTo:YES];
    }
    
}

-(void)deactivateLoop{
    NSLog(@"timer de-activation");
    //Stop Writeing and clean the ring buffer
    ControlPanel* cp=(ControlPanel*) [self superview];
    AudioController *au=[cp controlPanelAU];
    [au setDrawingTo:NO];
    
    if (timer) {
        [timer invalidate];
        timer=nil;
    }
    
}

-(void)plotAudioData:(NSTimer *)timer{
    //NSLog(@"plotAudio");
    ControlPanel* cp=(ControlPanel*) [self superview];
    AudioController *au=[cp controlPanelAU];
    float *f=[au readBuffer];
    data=*f;
    playing=YES;
    [self setNeedsDisplay];
}

-(void)resetGraph{
    //NSLog(@"timer de-activation");
    
    lastPoint.x=kOffsetX;
    lastIndex=1.0;
    playing=NO;
    [self setNeedsDisplay];
    
}



@end
