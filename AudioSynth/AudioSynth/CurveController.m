//
//  CurveController.m
//  CurveController
//
//  Created by Ness on 7/10/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "CurveController.h"

@interface CurveController(){
    //
    CurveSection section;
    //Control points of Envelope
    CGFloat H;
    CGFloat W;
    //Attack Curve points
    CGFloat A_start_x;
    CGFloat A_start_y;
    CGFloat A_cp1_x;
    CGFloat A_cp1_y;
    CGFloat A_cp2_x;
    CGFloat A_cp2_y;
    CGFloat A_end_x;
    CGFloat A_end_y;
    //Decay Curve points
    CGFloat D_start_x;
    CGFloat D_start_y;
    CGFloat D_cp1_x;
    CGFloat D_cp1_y;
    CGFloat D_cp2_x;
    CGFloat D_cp2_y;
    CGFloat D_end_x;
    CGFloat D_end_y;
    //Sustain Curve points
    CGFloat S_start_x;
    CGFloat S_start_y;
    CGFloat S_end_x;
    CGFloat S_end_y;
    //Release Curve points
    CGFloat R_start_x;
    CGFloat R_start_y;
    CGFloat R_cp1_x;
    CGFloat R_cp1_y;
    CGFloat R_cp2_x;
    CGFloat R_cp2_y;
    CGFloat R_end_x;
    CGFloat R_end_y;

    CGFloat d1;
    CGFloat d2;
}
@end

@implementation CurveController
@synthesize AUEnvelope;
-(void)drawInitialMesh:(CGContextRef)context{
    
    CGContextSaveGState(context);
    [[UIColor darkGrayColor]set];
    CGContextSetLineWidth(context, 0.8);
    //number of vertical lines
    int numOfLines=(W)/xStep;
    for(int i=0; i < numOfLines;i++){
        CGContextMoveToPoint(context, xOffset+(i*xStep), 0);
        CGContextAddLineToPoint(context, xOffset+(i*xStep), H);
    }
    
    //Number of horizontal lines
    numOfLines=(H)/yStep;
    for(int i=0; i<numOfLines;i++){
        CGContextMoveToPoint(context, xOffset,(i*yStep));
        CGContextAddLineToPoint(context, W-xOffset-5, (i*yStep));
    }
    CGContextStrokePath(context);
    
    
    CGContextRestoreGState(context);
}


-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        H=self.bounds.size.height;
        W=self.bounds.size.width;
        
        //Initial Envelope Values
        A_start_x=0;
        A_start_y=H;
        A_end_x=W/4;
        A_end_y=0;
        
        D_start_x=A_end_x;
        D_start_y=A_end_y;
        D_end_x=2*(W/4);
        D_end_y=H/3;
        
        S_start_x=D_end_x;
        S_start_y=D_end_y;
        S_end_x=3*(W/4);
        S_end_y=S_start_y;
        
        R_start_x=S_end_x;
        R_end_x=W;
        
        d1=W/8.0;
        d2=(2*W)/8.0;

        
    
        //Draw initial mesh
        UIGraphicsBeginImageContextWithOptions(self.bounds.size, NO, 0.0);
        CGContextRef context=UIGraphicsGetCurrentContext();
        ///////////////Draw a gradient
        CGFloat locs[5]={0.1,0.5,0.8,1.0};
        CGFloat colors[20]={
            0,      0,   0,      0.1,
            0.1059,0.1059,0.1059,1.0,    //Black
            0.11,0.49,0.97,0.1,          //Blue
            0,      0,   0,      0.1
        };
        
        CGColorSpaceRef sp= CGColorSpaceCreateDeviceRGB();
        CGGradientRef grad= CGGradientCreateWithColorComponents(sp, colors, locs, 4);
        CGContextDrawLinearGradient(context, grad, self.bounds.origin, CGPointMake(W, H), 0);
        CGColorSpaceRelease(sp);
        CGGradientRelease(grad);

        //////////////
        [self drawInitialMesh:context];
        UIImage *mesh = UIGraphicsGetImageFromCurrentImageContext();
        //[mesh drawInRect:self.bounds];
        UIGraphicsEndImageContext();
        //Self the  background image
        
        self.backgroundColor=[UIColor colorWithPatternImage:mesh];
        //self.layer.cornerRadius=10.0;
        self.layer.borderColor=[UIColor greenColor].CGColor;
        //self.layer.borderWidth=2.0;
    }
    return  self;
}


    
- (void)drawRect:(CGRect)rect {
    //initial settings
    CGContextRef context=UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    //Compute geometry of control points
        //**You may need to update the *_end points
    
    
    //Draw Envelope Curve
    CGContextBeginPath(context);
    
    //Draw Attack Curve
    A_cp1_x=A_end_x/3;
    A_cp2_x=2*(A_end_x/3);
    A_cp1_y=H-(H/3);
    A_cp2_y=H/3;
    CGContextMoveToPoint(context, A_start_x, A_start_y);
    CGContextAddCurveToPoint(context, A_cp1_x, A_cp1_y, A_cp2_x, A_cp2_y, D_start_x, D_start_y);
    
    //Draw Decay Curve
    D_cp1_x=A_end_x+(D_end_x-A_end_x)/3;
    D_cp2_x=A_end_x+(2*(D_end_x-A_end_x)/3);
    //D_cp1_y=30;
    D_cp1_y=A_end_y+(A_end_y*0.3);
    //D_cp2_y=H/5;
    D_cp2_y=A_end_y+(A_end_y*0.8);
    
    if(S_start_y-D_start_y<60){
        CGContextAddLineToPoint(context, S_start_x, S_start_y);
    }else{
        CGContextAddCurveToPoint(context, D_cp1_x, D_cp1_y, D_cp2_x, D_cp2_y, S_start_x, S_start_y);
    }
    
    
    
    //Draw Sustain Curve
    CGContextAddLineToPoint(context, R_start_x, S_end_y);
    
    //Draw Release Curve
//    R_cp1_x=S_end_x + (W-S_end_x)/3;
//    R_cp1_y=S_end_y+((H-S_end_y)*0.4);
//    R_cp2_x=S_end_x+2*((W-S_end_x)/3);
//    R_cp2_y=S_end_y+((H-S_end_y)*0.9);
    
    R_cp1_x= R_start_x+(W-R_start_x)*0.55;
    R_cp1_y= R_start_y+(H-R_start_y)*0.90;
    R_cp2_x= R_start_x+(W-R_start_x)*0.90;
    R_cp2_y= R_start_y+(H-R_start_y)*0.95;
    
    CGContextAddCurveToPoint(context, R_cp1_x, R_cp1_y, R_cp2_x, R_cp2_y, W, H);
    

    
    [[UIColor orangeColor]set];
    CGContextSetLineWidth(context, 2);
    CGContextStrokePath(context);
    
    //End drawing routines
    CGContextRestoreGState(context);
}

-(void)lockCurveWithLastloc:(CGPoint)lastLoc andCurrentloc: (CGPoint)currentLoc{
    if(currentLoc.x < A_end_x){
        NSLog(@"Attack");
        section=ATTACK;
    }
    if((currentLoc.x>A_end_x)&&(currentLoc.x<D_end_x)){
        NSLog(@"Decay");
        section=DECAY;
    }
    if((currentLoc.x>D_end_x)&&(currentLoc.x<S_end_x)){
        NSLog(@"Sustain");
        section=SUSTAIN;
    }
    if((currentLoc.x>S_end_x)&&(currentLoc.x<R_end_x)){
        NSLog(@"Release");
        section=RELEASE;
    }
}
-(void)updateCurveWithLastloc:(CGPoint)lastLoc andCurrentloc: (CGPoint)currentLoc{
    //Calculate new limits for x axis
    CGFloat timePercentage;
    CGFloat sustainLevel;
    switch (section) {
        case ATTACK:

            if(currentLoc.x>10 && (D_end_x-currentLoc.x>5)){
                A_end_x=currentLoc.x;
                D_start_x=A_end_x;
            }
            
            //Obtain Percentage: Take the width as the %100
            timePercentage=(A_end_x*100)/W;
            [self sendTimePercentage:timePercentage];
            [AUEnvelope setAttackTime:(double)(timePercentage*EG_TIME_GLOBAL)];
            
//            if(currentLoc.y>0&&currentLoc.y<S_start_y){
//                A_end_y=currentLoc.y;
//                D_start_y=A_end_y;
//            }

            break;
        case DECAY:

            if(currentLoc.x>A_end_x && (S_end_x-currentLoc.x>5)){
                D_end_x=currentLoc.x;
                S_start_x=D_end_x;
            }
            //Obtain Percentage: Take the width as the %100
            timePercentage=((D_end_x-A_end_x)*100)/W;
            [self sendTimePercentage:timePercentage];
            [AUEnvelope setDecayTime:(double)(timePercentage*EG_TIME_GLOBAL)];
            if(currentLoc.y>0 && currentLoc.y<H){
                D_end_y=currentLoc.y;
                S_start_y=S_end_y=D_end_y;
            }
            break;
        case SUSTAIN:
            if(currentLoc.x>D_end_x && currentLoc.x<W-20){
                S_end_x=currentLoc.x;
                R_start_x=S_end_x;
            }
            if(currentLoc.y>D_start_y && currentLoc.y<H-20){
                S_start_y=S_end_y=currentLoc.y;
                sustainLevel=(H-S_start_y)/H;
                [AUEnvelope setSustainLevel:(double)sustainLevel];
            }
            break;
        case RELEASE:
            //Obtain Percentage: Take the width as the %100
            timePercentage=((W-R_start_x)*100)/W;
            [self sendTimePercentage:timePercentage];
            [AUEnvelope setReleaseTIme:(double)(timePercentage*EG_TIME_GLOBAL)];
            
            if(currentLoc.x > D_end_x && currentLoc.x<W-20){
                R_start_x=currentLoc.x;
            }
            
            break;
            
        default:
            break;
    }
}

-(void)sendTimePercentage:(CGFloat)time{
    NSLog(@"%f",time);
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *t=(UITouch *)[touches anyObject];
    CGPoint currentLoc=[t locationInView:t.view];
    CGPoint lastLoc=[t previousLocationInView:t.view];
    [self lockCurveWithLastloc:lastLoc andCurrentloc:currentLoc];
    
}

-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    UITouch *t=(UITouch *)[touches anyObject];
    //previous location
    CGPoint lastLoc=[t previousLocationInView:t.view];
    //current location
    CGPoint currentLoc=[t locationInView:t.view];
    
    //
    [self updateCurveWithLastloc:lastLoc andCurrentloc:currentLoc];

    [self setNeedsDisplay];
    
}
@end
