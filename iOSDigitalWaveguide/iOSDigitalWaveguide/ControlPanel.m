//
//  ControlPanel.m
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "ControlPanel.h"

@implementation ControlPanel
@synthesize r1,r2,r3;
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {

        ///-- Global geometry
        
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        startCenter=CGPointMake(W/2, H/2);
        
        ///-- General container settings: colors, shadows, backgrounds....
        
        self.opaque=NO;
        self.backgroundColor=[UIColor clearColor];
        
        
        ///-- Main Image Drawing
        
        
        //-- Draw the central Circle with a gradient fill
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef context = UIGraphicsGetCurrentContext();
        //-- Create a mask for clipping and gradient drawing
        UIGraphicsBeginImageContext(self.bounds.size);
        CGContextRef maskContext = UIGraphicsGetCurrentContext();
        CGContextFillEllipseInRect(maskContext, CGRectInset(self.bounds, W*0.17, H*0.17));
        CGImageRef mask= CGBitmapContextCreateImage(maskContext);
        //-- Save Context before clipping and filling drawing
        CGContextSaveGState(context);
                CGContextClipToMask(context, self.bounds, mask);
                CGImageRelease(mask);
                UIGraphicsEndImageContext();
                //CGContextRelease(maskContext);
                //-- Prepare colors of the inner gradient
                CGFloat loc[4]={0.446154,0.637306,0.854922,1.0};
                CGFloat darkAquaColors[16]={                    //Aqua Green colors
                    49/255.0f, 214/255.0f, 202/255.0f,0.8,
                    30/255.0f, 200/255.0f, 150/255.0f,0.4,
                    7/255.0f, 32/255.0f, 30/255.0f,0.1,
                    5/255.0f, 26/255.0f, 25/255.0f,0.1
                };
                CGColorSpaceRef colorspace=CGColorSpaceCreateDeviceRGB();
                CGGradientRef grad=CGGradientCreateWithColorComponents(colorspace, darkAquaColors, loc, 4);
                CGContextDrawLinearGradient(context, grad, CGPointMake(W/2, 0), CGPointMake(W/2,H), 0);
                CGColorSpaceRelease(colorspace);
                CGGradientRelease(grad);
        CGContextRestoreGState(context);
        //-- Draw Yellow Axis lines
        CGContextSaveGState(context);
                CGContextSetLineWidth(context, 2);
                CGContextBeginPath(context);
                [[UIColor yellowColor]set];
                CGContextMoveToPoint(context, W/2, H*0.173);
                CGContextAddLineToPoint(context, W/2, H*0.84);
                CGContextMoveToPoint(context, W*0.15, H/2);
                CGContextAddLineToPoint(context, W*0.85, H*0.50);
                CGContextStrokePath(context);
        CGContextRestoreGState(context);
        //Draw Concentric Circles outside the center circle
        CGContextSaveGState(context);
                ringColor=[UIColor colorWithRed:48/255.0f green:245/255.0f blue:245/255.0f alpha:1.0];
                ringColorTransparent=[UIColor colorWithRed:48/255.0f green:220/255.0f blue:220/255.0f alpha:0.8];
                CGContextSetLineWidth(context, 4);
                [ringColorTransparent set];
                CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, W*0.03, H*0.03));
                CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, W*0.12, H*0.12));
                [ringColor set];
                CGContextSetLineWidth(context, 6);
                CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, W*0.15, H*0.15));
        CGContextRestoreGState(context);
        //Draw Concentric Circles Inside the center circle
        CGContextSaveGState(context);
                innerRing=[UIColor colorWithRed:49/255.0f  green: 214/255.0f blue:202/255.0f alpha:0.5];
                [innerRing set];
                CGContextSetLineWidth(context, 2);
                CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, W*0.20, H*0.20));
                CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, W*0.30, H*0.30));
                CGContextStrokeEllipseInRect(context, CGRectInset(self.bounds, W*0.40, H*0.40));
        CGContextRestoreGState(context);
        
        
        ///-- Save previous work in a UIImage an set it as the default image
        
        
        UIImage *centralCircle=UIGraphicsGetImageFromCurrentImageContext();
        [centralCircle drawInRect:self.bounds];
        self.image=centralCircle;
        UIGraphicsEndImageContext();
        
        
        ////-- Prepare the CAGradientLayer to cover the control panel
        
        
        backgroundColor=[UIColor colorWithRed:5/255.0f green:24/255.0f blue:26/255.0f alpha:1.0];
        backgoundColorTransparent=[UIColor colorWithRed:5/255.0f green:24/255.0f blue:26/255.0f alpha:0.2];
        gradLayer=[[CAGradientLayer alloc]init];
        gradLayer.frame=self.bounds;
        gradLayer.startPoint=CGPointMake(0, 0);
        gradLayer.endPoint=CGPointMake(1,1);
        gradLayer.shadowOpacity=1.0;
        gradLayer.shadowColor=ringColor.CGColor;
        //-- Construct the array that have the colors of the gradient layer
        CGColorRef color1 =backgroundColor.CGColor;
        CGColorRef color2 =backgoundColorTransparent.CGColor;
        NSArray *colors=[[NSArray alloc]initWithObjects:(__bridge id)color1,(__bridge id)color2,(__bridge id)color1, nil];
        //-- Construct the array that have the positions of the gradient layer
        NSNumber *location1= [[NSNumber alloc]initWithFloat:0.1];
        NSNumber *location2= [[NSNumber alloc]initWithFloat:0.4];
        NSNumber *location3= [[NSNumber alloc]initWithFloat:0.9];
        
        NSArray *locations=[[NSArray alloc]initWithObjects:location1,location2,location3, nil];
        gradLayer.colors=colors;
        gradLayer.locations=locations;
        [self.layer addSublayer:gradLayer];
        
        
        ///-- Set the Round Control Sliders
        
        
        r1=[RoundControlSlider alloc];
        [r1 setIdentifier:[NSNumber numberWithInt:1]];
        [r1 setParameterName:@"PickUp"];
        r1=[r1 initWithFrame:CGRectMake(60, 90, 100, 100)];
        [self addSubview:r1];
        
        r2=[RoundControlSlider alloc];
        [r2 setIdentifier:[NSNumber numberWithInt:2]];
        [r2 setParameterName:@"Pluck"];
        r2=[r2 initWithFrame:CGRectMake(200, 90, 100, 100)];
        [self addSubview:r2];

        r3=[RoundControlSlider alloc];
        [r3 setIdentifier:[NSNumber numberWithInt:3]];
        [r3 setParameterName:@"AMP"];
        r3=[r3 initWithFrame:CGRectMake(135, 220, 100, 100)];
        [self addSubview:r3];

        
        
        
    }
    return self;
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
