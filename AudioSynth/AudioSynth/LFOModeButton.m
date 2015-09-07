//
//  LFOModeButton.m
//  AudioSynth
//
//  Created by Ness on 9/7/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "LFOModeButton.h"

@implementation LFOModeButton
@synthesize colorState1,colorState2,message,AULFOModeButton,identifier;


-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        //-- Global geometry
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        X=self.bounds.origin.x;
        Y=self.bounds.origin.y;
        
        //-- Light Indicator Geometry
        WLightIndicator=(W*0.50);
        HLightIndicator=H;
        lightIndicator=CGRectMake(X, Y, WLightIndicator, HLightIndicator);
        lightIndicatorCenter=CGPointMake(X+WLightIndicator/2, Y+HLightIndicator/2);
        
        state=0;
        //-- Main view background color
        self.backgroundColor=[UIColor clearColor];
//        self.layer.borderWidth=2.0;
//        self.layer.borderColor=[UIColor orangeColor].CGColor;
        
        
        //-- Font for description
        ////--- Create a font for display message, and get its size
        UIFont *font=[UIFont fontWithName:@"Futura-CondensedExtraBold" size:14];
        NSString *str=@"000000";
        NSDictionary *attributes = [[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        CGSize fontSize= [str sizeWithAttributes:attributes];
        description=[[UILabel alloc]initWithFrame:CGRectMake(WLightIndicator*0.85, HLightIndicator*0.80, fontSize.width, fontSize.height)];
        description.text=@"FREE";
        description.font=font;
        description.textColor=[UIColor whiteColor];
        [self addSubview:description];
    }
    return self;
}

-(void)setValue:(id)value forKey:(NSString *)key{
    if ([key isEqual:@"colorState1"]) {
        //-- Get color from interface builder
        colorState1=value;
        //-- Obtain the color components
        const CGFloat *components=CGColorGetComponents(colorState1.CGColor);
        redComponent=components[0];
        greenComponent=components[1];
        blueComponent=components[2];
        alphaComponent=components[3];        
    }
    
    if ([key isEqual:@"colorState2"]) {
        //-- Get color from interface builder
        colorState2=value;
        //-- Obtain the color components
        const CGFloat *components=CGColorGetComponents(colorState2.CGColor);
        redComponent2=components[0];
        greenComponent2=components[1];
        blueComponent2=components[2];
        alphaComponent2=components[3];
    }
    if ([key isEqual:@"message"]) {
        message=value;
    }
    if ([key isEqual:@"identifier"]) {
        identifier=value;
    }
    if ([key isEqual:@"AULFOModeButton"]) {
        AULFOModeButton=value;
    }
    
    
}

-(void)drawRect:(CGRect)rect{
    CGContextRef context=UIGraphicsGetCurrentContext();
    switch (state) {
        case 0:
            [self drawInactivateState:context];
            break;
        case 1:
            [self drawActivateState1:context];
            break;
        case 2:
            [self drawActivateState2:context];
            break;
            
        default:
            break;
    }

    
    
    
}

-(void)drawInactivateState:(CGContextRef)context{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef maskContext=UIGraphicsGetCurrentContext();
    CGContextFillEllipseInRect(maskContext, lightIndicator);
    CGImageRef mask=CGBitmapContextCreateImage(maskContext);
    UIGraphicsEndImageContext();
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    CGImageRelease(mask);
    
    CGFloat locations[4]={0.030769,0.108808,0.173575,0.404145};
    CGFloat ColorComponents[16]={
        255/255.0,  255/255.0,   255/255.0,    1.0,
        250/255.0, 215/255.0,  215/255.0,   0.5,
        255/255.0, 215/255.0,  215/255.0,   0.3,
        250/255.0,  240/255.0,   250/255.0,    0.1        //
    };
    CGColorSpaceRef colorspace=CGColorSpaceCreateDeviceRGB();
    CGGradientRef grad = CGGradientCreateWithColorComponents(colorspace, ColorComponents, locations, 4);
    
    //CGContextFillRect(context, lightIndicator);
    CGContextDrawRadialGradient(context, grad, lightIndicatorCenter, WLightIndicator*0.01,CGPointMake(WLightIndicator/2, HLightIndicator/2), WLightIndicator*0.9, kCGGradientDrawsBeforeStartLocation);
    
    CGContextRestoreGState(context);
    
    description.textColor=[UIColor whiteColor];
    description.text=@"Off";
    
    state=1;
}
-(void)drawActivateState1:(CGContextRef)context{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef maskContext=UIGraphicsGetCurrentContext();
    CGContextFillEllipseInRect(maskContext, lightIndicator);
    CGImageRef mask=CGBitmapContextCreateImage(maskContext);
    UIGraphicsEndImageContext();
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    CGImageRelease(mask);
    
    CGFloat locations[4]={0.030769,0.108808,0.173575,0.404145};
    CGFloat ColorComponents[16]={
        255/255.0,  255/255.0,   255/255.0,    1.0,
        redComponent, greenComponent,  blueComponent,   1.0,
        redComponent+0.05, greenComponent-0.01,  blueComponent-0.05,   1.0,
        250/255.0,  240/255.0,   250/255.0,    0.1        //
    };
    CGColorSpaceRef colorspace=CGColorSpaceCreateDeviceRGB();
    CGGradientRef grad = CGGradientCreateWithColorComponents(colorspace, ColorComponents, locations, 4);

    //CGContextFillRect(context, lightIndicator);
    CGContextDrawRadialGradient(context, grad, lightIndicatorCenter, WLightIndicator*0.01,CGPointMake(WLightIndicator/2, HLightIndicator/2), WLightIndicator*0.9, kCGGradientDrawsBeforeStartLocation);
    
    CGContextRestoreGState(context);
    
    description.textColor=[UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent];
    description.text=@"Shot";
    
    state=2;
}

-(void)drawActivateState2:(CGContextRef)context{
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef maskContext=UIGraphicsGetCurrentContext();
    CGContextFillEllipseInRect(maskContext, lightIndicator);
    CGImageRef mask=CGBitmapContextCreateImage(maskContext);
    UIGraphicsEndImageContext();
    
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    CGImageRelease(mask);
    
    CGFloat locations[4]={0.030769,0.108808,0.173575,0.404145};
    CGFloat ColorComponents[16]={
        255/255.0,  255/255.0,   255/255.0,    1.0,
        redComponent2, greenComponent2,  blueComponent2,   1.0,
        redComponent2+0.05, greenComponent2-0.01,  blueComponent2-0.05,   1.0,
        250/255.0,  240/255.0,   250/255.0,    0.1        //
    };
    CGColorSpaceRef colorspace=CGColorSpaceCreateDeviceRGB();
    CGGradientRef grad = CGGradientCreateWithColorComponents(colorspace, ColorComponents, locations, 4);
    
    //CGContextFillRect(context, lightIndicator);
    CGContextDrawRadialGradient(context, grad, lightIndicatorCenter, WLightIndicator*0.01,CGPointMake(WLightIndicator/2, HLightIndicator/2), WLightIndicator*0.9, kCGGradientDrawsBeforeStartLocation);
    
    CGContextRestoreGState(context);
    
    description.textColor=[UIColor colorWithRed:redComponent2 green:greenComponent2 blue:blueComponent2 alpha:alphaComponent2];
        description.text=@"Sync";
    
    state=0;
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

}
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    switch (state) {
        case 0://OFF
            NSLog(@"OFF");
            [AULFOModeButton setOffModeFor:(int)identifier.integerValue];
            [self setNeedsDisplay];
            
            
            break;
        case 1://Shot
            NSLog(@"shot");
            [AULFOModeButton setShotModeFor:(int)identifier.integerValue];
            [self setNeedsDisplay];
            
            
            break;
        case 2://Sycn
            NSLog(@"sync");
            [AULFOModeButton setSyncModeFor:(int)identifier.integerValue];
            [self setNeedsDisplay];
            
            break;
            
        default:
            break;
    }
}
@end
