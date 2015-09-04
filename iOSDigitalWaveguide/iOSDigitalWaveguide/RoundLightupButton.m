//
//  RoundLightupButton.m
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/4/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "RoundLightupButton.h"

@implementation RoundLightupButton
@synthesize color,buttonName,identifier;
@synthesize AU_effects;
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        self.backgroundColor=[UIColor clearColor];
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        startCenter=CGPointMake(W/2, H/2);
        active=NO;
        
        
        ////--- Add the description textField 
        
        //-- Create a font for display message
        UIFont *font=[UIFont fontWithName:@"Futura-CondensedExtraBold" size:12];
        NSString *str=@"D I S T O R T I O N";
        NSDictionary *attributes = [[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        //-- Get its size
        CGSize fontSize= [str sizeWithAttributes:attributes];
        //-- Use the size for the position in the superview
        effectDescription=[[UITextField alloc]initWithFrame:CGRectMake((W/2)-fontSize.width/2,(H/2)-fontSize.height,
                                                                       fontSize.width , fontSize.height)];
        effectDescription.font=font;
        effectDescription.enabled=NO;
        effectDescription.textAlignment=NSTextAlignmentCenter;
        //-- Add the text field
        [self addSubview:effectDescription];
        
    }
    return self;
}


-(void)setValue:(id)value forKeyPath:(NSString *)keyPath{
    if ([keyPath isEqualToString:@"color"]) {
        color=value;
        const CGFloat *components=CGColorGetComponents(color.CGColor);
        redComponent=components[0];
        greenComponent=components[1];
        blueComponent=components[2];
        alphaComponent=0.9;
    }
    
    if ([keyPath isEqualToString:@"buttonName"]) {
        buttonName=value;
        effectDescription.text=buttonName;
        
    }
    
    if ([keyPath isEqualToString:@"identifier"]) {
        identifier=value;
    }
    
    if ([keyPath isEqualToString:@"AU_effects"]) {
        AU_effects=value;
    }
    
}





- (void)drawRect:(CGRect)rect {
    CGContextRef context= UIGraphicsGetCurrentContext();
    if (active) {
        //-- Create a circular mask
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef maskContext= UIGraphicsGetCurrentContext();
        CGContextFillEllipseInRect(maskContext, CGRectInset(self.bounds, W*0.10, H*0.10));
        //CGContextSetLineWidth(maskContext, 20);
        //CGContextStrokeEllipseInRect(maskContext, CGRectInset(self.bounds, W*0.10, H*0.10));
        CGContextStrokePath(maskContext);
        CGImageRef mask=CGBitmapContextCreateImage(maskContext);
        //-- Clip mask to context
        CGContextClipToMask(context, self.bounds, mask);
        CGImageRelease(mask);
        UIGraphicsEndImageContext();
        //-- Before draw the gradient save the current context
        
        CGContextSaveGState(context);
        
        //-- Create arrays for locations and colors
        CGFloat locations[4]={1.0,0.0,0.401554,0.538860};
        
        
        CGFloat colors[16]={
            255/255.0,          255/255.0,          255/255.0,              0.3,
            redComponent,       greenComponent,     blueComponent,          0.3,            //
            redComponent-0.01,  greenComponent-0.01,blueComponent-0.01,     0.6,          //
            250/255.0,          240/255.0,          250/255.0,              0.0        //
            
        };
        
        //-- Create and draw gradient
        CGColorSpaceRef colorspace=CGColorSpaceCreateDeviceRGB();
        CGGradientRef grad = CGGradientCreateWithColorComponents(colorspace, colors, locations, 4);
        //CGContextDrawLinearGradient(context, grad, CGPointMake(0, H/2), CGPointMake(W, H/2), 0);
        CGContextDrawRadialGradient(context, grad, startCenter, W*0.01, CGPointMake(W/2, H/2), W*0.90, kCGGradientDrawsBeforeStartLocation);
        CGColorSpaceRelease(colorspace);
        CGGradientRelease(grad);
        
        CGContextRestoreGState(context);
        effectDescription.textColor=[UIColor blackColor];
        self.layer.shadowColor=color.CGColor;
        self.layer.shadowOpacity=1.0;
        self.layer.shadowRadius=4.0;
    }else {
        //-- Create a circular mask
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef maskContext= UIGraphicsGetCurrentContext();
        CGContextFillEllipseInRect(maskContext, CGRectInset(self.bounds, W*0.10, H*0.10));
        //CGContextSetLineWidth(maskContext, 20);
        //CGContextStrokeEllipseInRect(maskContext, CGRectInset(self.bounds, W*0.10, H*0.10));
        CGContextStrokePath(maskContext);
        CGImageRef mask=CGBitmapContextCreateImage(maskContext);
        //-- Clip mask to context
        CGContextClipToMask(context, self.bounds, mask);
        CGImageRelease(mask);
        UIGraphicsEndImageContext();
        //-- Before draw the gradient save the current context
        
        CGContextSaveGState(context);
        
        //-- Create arrays for locations and colors
        CGFloat locations[4]={1.0,0.0,0.401554,0.538860};
        
        
        CGFloat colors[16]={
            255/255.0,          255/255.0,          255/255.0,              0.3,
            redComponent,       greenComponent,     blueComponent,          0.1,
            0.0,            0.0,                0.0,                    0.8,
            250/255.0,          240/255.0,          250/255.0,              0.1
            
        };
        
        //-- Create and draw gradient
        CGColorSpaceRef colorspace=CGColorSpaceCreateDeviceRGB();
        CGGradientRef grad = CGGradientCreateWithColorComponents(colorspace, colors, locations, 4);
        //CGContextDrawLinearGradient(context, grad, CGPointMake(0, H/2), CGPointMake(W, H/2), 0);
        CGContextDrawRadialGradient(context, grad, startCenter, W*0.01, CGPointMake(W/2, H/2), W*0.90, kCGGradientDrawsBeforeStartLocation);
        CGColorSpaceRelease(colorspace);
        CGGradientRelease(grad);
        
        CGContextRestoreGState(context);
        CGContextSetLineWidth(context, 2);
        [[UIColor blackColor]set];
        CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, W*0.09, H*0.09));
        
        effectDescription.textColor=[UIColor whiteColor];
    }
    
}



-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    if (!active) {
        active=YES;
        switch (identifier.integerValue) {
            case 1://Distortion
                [AU_effects setDistortionON];
                break;
            case 2://Delay
                [AU_effects setDelayON];
                break;
            case 3://Envelope
                
                break;
            case 4://Filter Highpass
                [AU_effects setFilterON];
                break;
                
            default:
                break;
        }
    }else{
        
        switch (identifier.integerValue) {
            case 1://Distortion
                [AU_effects setDistortionOFF];
                break;
            case 2://Delay
                [AU_effects setDelayOFF];
                break;
            case 3://Envelope
                
                
                break;
            case 4://Filter Highpass
                [AU_effects setFilterOFF];
                break;
                
            default:
                break;
        }
        active=NO;
    }
    [self setNeedsDisplay];
}
@end
