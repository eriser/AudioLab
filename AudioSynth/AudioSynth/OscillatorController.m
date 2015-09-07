//
//  OscillatorController.m
//  OscillatorController
//
//  Created by Ness on 8/18/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "OscillatorController.h"

///-- Some Utilities
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)          ( (x) * (x) )

enum parameter {PHASE=1,LFO,DETUNE,WAVE};


@implementation OscillatorController
@synthesize identifier,AUCurveController,OscNumber;
@synthesize centralWave,LFOWaveIndicator;




#pragma mark Initializations

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath{
    if ([keyPath isEqual:@"OscNumber"]) {
        OscNumber=value;
    }
    if ([keyPath isEqual:@"AUCurveController"]) {
        AUCurveController=value;
    }
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {

        ////-- Global geometry settings
        
        
        self.backgroundColor=[UIColor clearColor];
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        //-- Central Curves
        W1=6*(W/8);
        H1=6*(H/8);
        center=CGPointMake(W1/2, H1/2);
        //-- Round slider geometry
        W2=2*(W/8);
        H2=2*(H/8);
        // Initialize Curves Starting Angles
        curve1=[UIBezierPath bezierPath];
        r1=(W1/2)*0.3;
        startAng1=80;
        ang1=190;
        curve2=[UIBezierPath bezierPath];
        r2=(W1/2)*0.5;
        startAng2=350;
        ang2=80;
        curve3=[UIBezierPath bezierPath];
        r3=(W1/2)*0.7;
        startAng3=45;
        ang3=225;
        curve4=[UIBezierPath bezierPath];
        r4=(W1/2)*0.9;
        startAng4=80;
        ang4=280;
        //-- Curve being updated
        updateCurve=0;
        
        
        //-- Create UIFont to be used in each label indicator
        
        
        UIFont *font=[UIFont fontWithName:@"Futura-CondensedExtraBold" size:14];
        NSString *str=@"000000000";
        NSDictionary *attributes = [[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        CGSize fontSize= [str sizeWithAttributes:attributes];
        
        
        
        //-- Add UILabels indicating the range of Wave Shapes for the ocillators
        
      
        //NOISE
        noiseLabel=[[UITextField alloc]initWithFrame:CGRectMake(W1*0.25, H1*0.775, fontSize.width, fontSize.height)];
        noiseLabel.backgroundColor=[UIColor clearColor];
        noiseLabel.font=[font fontWithSize:10.0];
        noiseLabel.textAlignment=NSTextAlignmentCenter;
        noiseLabel.textColor=[UIColor whiteColor];
        noiseLabel.text=@"NOISE";
        noiseLabel.enabled=NO;
        [noiseLabel setTransform:CGAffineTransformMakeRotation(ToRad(280))];
        [self addSubview:noiseLabel];
        //SINE
        sineLabel=[[UITextField alloc]initWithFrame:CGRectMake(W1*0.13, H1*0.70, fontSize.width, fontSize.height)];
        sineLabel.backgroundColor=[UIColor clearColor];
        sineLabel.font=[font fontWithSize:10.0];
        sineLabel.textAlignment=NSTextAlignmentCenter;
        sineLabel.textColor=[UIColor whiteColor];
        sineLabel.text=@"SINE";
        sineLabel.enabled=NO;
        [sineLabel setTransform:CGAffineTransformMakeRotation(ToRad(320))];
        [self addSubview:sineLabel];
        //TRIANGLE
        triLabel=[[UITextField alloc]initWithFrame:CGRectMake(W1*0.07, H1*0.58, fontSize.width, fontSize.height)];
        triLabel.backgroundColor=[UIColor clearColor];
        triLabel.font=[font fontWithSize:10.0];
        triLabel.textAlignment=NSTextAlignmentCenter;
        triLabel.textColor=[UIColor whiteColor];
        triLabel.text=@"TRI";
        triLabel.enabled=NO;
        [triLabel setTransform:CGAffineTransformMakeRotation(ToRad(350))];
        [self addSubview:triLabel];
        //SAWTOOTH
        sawLabel=[[UITextField alloc]initWithFrame:CGRectMake(W1*0.05, H1*0.45, fontSize.width, fontSize.height)];
        sawLabel.backgroundColor=[UIColor clearColor];
        sawLabel.font=[font fontWithSize:10.0];
        sawLabel.textAlignment=NSTextAlignmentCenter;
        sawLabel.textColor=[UIColor whiteColor];
        sawLabel.text=@"SAW";
        sawLabel.enabled=NO;
        [sawLabel setTransform:CGAffineTransformMakeRotation(ToRad(2))];
        [self addSubview:sawLabel];
        //SQUARE
        squareLabel=[[UITextField alloc]initWithFrame:CGRectMake(W1*0.07, H1*0.30,fontSize.width, fontSize.height)];
        squareLabel.backgroundColor=[UIColor clearColor];
        squareLabel.font=[font fontWithSize:10.0];
        squareLabel.textAlignment=NSTextAlignmentCenter;
        squareLabel.textColor=[UIColor whiteColor];
        squareLabel.text=@"SQR";
        squareLabel.enabled=NO;
        [squareLabel setTransform:CGAffineTransformMakeRotation(ToRad(15))];
        [self addSubview:squareLabel];
        
        
        
        //-- Secundary Round Sliders
        /******************************************************************
         ROUND SLIDERS  These sliders control:
         LFO-->  frequency of the low frequency oscillator
         DETUNE->The amount of detunning for each oscillator
         Phase-> LFO Wave Shape
         ******************************************************************/
        
        
        
        //-- Create the PHASE control
        sliderPhase=[[RoundSlider alloc]initWithFrame:CGRectMake(W1*0.35, H1, W2, H2)];
        [sliderPhase setSliderColor:YELLOW];
        [sliderPhase setIdentifier:PHASE];
        [self addSubview:sliderPhase];
        //-- Add description
        PhaseTextField=[[UITextField alloc]initWithFrame:CGRectMake(W1*0.25+(fontSize.width/2), H1+H2,
                                                                    fontSize.width, fontSize.height)];
        PhaseTextField.backgroundColor=[UIColor clearColor];
        PhaseTextField.font=font;
        PhaseTextField.textAlignment=NSTextAlignmentCenter;
        PhaseTextField.textColor=[UIColor whiteColor];
        PhaseTextField.text=@"LFO Wave";
        PhaseTextField.enabled=NO;
        [self addSubview:PhaseTextField];
        
        //-- Create the DETUNE control
        sliderDetune=[[RoundSlider alloc]initWithFrame:CGRectMake(W1, H1, W2, H2)];
        [sliderDetune setSliderColor:GREEN];
        [sliderDetune setIdentifier:DETUNE];
        [self addSubview:sliderDetune];
        //-- Add description
        DetuneTextField= [[UITextField alloc]initWithFrame:CGRectMake(W1+(fontSize.width/2), H1+H2,
                                                                     fontSize.width, fontSize.height)];
        DetuneTextField.backgroundColor=[UIColor clearColor];
        DetuneTextField.font=font;
        DetuneTextField.textAlignment=NSTextAlignmentCenter;
        DetuneTextField.textColor=[UIColor whiteColor];
        DetuneTextField.text=@"DETUNE";
        DetuneTextField.enabled=NO;
        [self addSubview:DetuneTextField];
        
        //-- Create LFO control
        sliderLFO=[[RoundSlider alloc]initWithFrame:CGRectMake(W1, H1*0.20, W2*1.02, H2*1.02)];
        [sliderLFO setSliderColor:RED];
        [sliderLFO setIdentifier:LFO];
        [self addSubview:sliderLFO];
        //-- Add description
        LFOTextField=[[UITextField alloc]initWithFrame:CGRectMake(W1+(fontSize.width/4), (H1*0.20)+H2,
                                                          fontSize.width, fontSize.height)];
        LFOTextField.backgroundColor=[UIColor clearColor];
        LFOTextField.font=font;
        LFOTextField.textAlignment=NSTextAlignmentCenter;
        LFOTextField.textColor=[UIColor whiteColor];
        LFOTextField.text=@"LFO";
        LFOTextField.enabled=NO;
        [self addSubview:LFOTextField];


        
        //-- Add Visual Feedback: what kind of wave is being used by pitch Osc and LFOs
        
        
        // CENTRAL WAVE
        centralWave=[WaveShape alloc];
        [centralWave setShape:SINE];
        centralWave=[centralWave initWithFrame:CGRectMake((W1/2.3), (H1/2.4), W1*0.15, H1*0.15)];
        [self addSubview:centralWave];
        //LFO WAVE
        LFOWaveIndicator=[WaveShape alloc];
        [LFOWaveIndicator setShape:SINE];
        CGRect targetRect= CGRectMake(W1*0.70, H1, W2, H2);
        LFOWaveIndicator = [LFOWaveIndicator initWithFrame:CGRectInset(targetRect, 10, 10)];
        [self addSubview:LFOWaveIndicator];

        

    }
    return self;
}



#pragma mark Drawing Methods



-(void)drawRect:(CGRect)rect{
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    //-- TO DO: Create an Image to be drawed only once
    [self drawBackground:context];
    
    //-- Updates the Control Curves
    [self updateStateOfControlCurvesWithGradient:context];
    [self drawControlCurves:context];

    
    
}

-(void)drawBackground:(CGContextRef)context{
    //-- Draw Inital Skeleton
    CGContextSaveGState(context);
    CGFloat dash[]={3,7};
    CGContextSetLineDash(context, 0, dash, 2);
    CGContextSetLineWidth(context, 5);
    CGContextSetStrokeColorWithColor(context, [[UIColor blackColor] CGColor]);
    CGContextSetShadowWithColor(context, CGSizeMake(0, 1), 3.0, [[UIColor blueColor]CGColor]);
    CGContextAddArc(context, center.x, center.y, r1,ToRad(0), ToRad(360), 1);
    CGContextStrokePath(context);
    CGContextAddArc(context, center.x, center.y, r2,ToRad(0), ToRad(360), 1);
    CGContextStrokePath(context);
    CGContextAddArc(context, center.x, center.y, r3,ToRad(0), ToRad(360), 1);
    CGContextStrokePath(context);
    CGContextSetLineWidth(context, 15);
    CGContextAddArc(context, center.x, center.y, r4,ToRad(0), ToRad(360), 1);
    CGContextStrokePath(context);
    
    //-- End connection lines
    CGContextSetLineWidth(context, 4);
    [[UIColor blueColor]set];
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 0.0, [[UIColor blueColor]CGColor]);
    dash[0]=3;
    dash[1]=2;
    CGContextSetLineDash(context, 0, dash, 2);
    
    //lines to LFO control
    CGContextMoveToPoint(context, center.x+(r2*cos(ToRad(startAng2))), center.y+(r2*sin(ToRad(startAng2))));
    CGContextAddLineToPoint(context, center.x+(2.2*r2*cos(ToRad(startAng2))), center.y+(2.2*r2*sin(ToRad(startAng2))));
    CGContextStrokePath(context);
    CGContextAddArc(context, W1+W2/2, (H1*0.20)+H2/2, (W2/2)*0.75, 0, 2*M_PI, 0);
    CGContextStrokePath(context);
    
    //lines to DETUNE control
    CGContextMoveToPoint(context, center.x+(r3*cos(ToRad(startAng3))), center.y+(r3*sin(ToRad(startAng3))));
    CGContextAddLineToPoint(context, center.x+(2.4*r3*cos(ToRad(startAng3))), center.y+(2.4*r3*sin(ToRad(startAng3))));
    CGContextStrokePath(context);
    CGContextAddArc(context, W1+(W2/2), H1+(H2/2), (W2/2)*0.75, 0, 2*M_PI, 0);
    CGContextStrokePath(context);
    //lines to PHASE control
    CGContextMoveToPoint(context, center.x+(r1*cos(ToRad(80))), center.y+(r1*sin(ToRad(80))));
    CGContextAddLineToPoint(context, center.x+(3.7*r1*cos(ToRad(80))), center.y+(3.7*r1*sin(ToRad(80))));
    CGContextStrokePath(context);
    CGContextAddArc(context, (W1*0.35)+(W2/2), H1+(H2/2), (W2/2)*0.75, 0, 2*M_PI, 0);
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}

-(void)updateStateOfControlCurvesWithGradient:(CGContextRef)context{
    /*********************************************
        PREPARE THE COLORS AND GRADIENT
     *********************************************/
    CGFloat locations[4]={1.0,0.177966,0.135593,0.292373};
    CGFloat electriBlue[16]={
        10/255.0f, 0/255.0f, 90/255.0f, 1.0,
        18/255.0f, 86/255.0f, 253/255.0f, 1.0,
        42/255.0f, 183/255.0f, 254/255.0f, 1.0,
        254/255.0f, 252/255.0f, 252/255.0f, 1.0
    };
    CGColorSpaceRef colorspace=CGColorSpaceCreateDeviceRGB();
    CGGradientRef grad = CGGradientCreateWithColorComponents(colorspace, electriBlue, locations, 4);
    
    /*********************************************
                    DRAW THE CURVES
     *********************************************/

    ////--- Curve 1
    
    //-- Create a circular mask
    UIGraphicsBeginImageContext(self.bounds.size);
    CGContextRef maskContext= UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(maskContext, 10);
    CGAffineTransform transform = CGAffineTransformIdentity;
    transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
    transform = CGAffineTransformTranslate(transform, 0.0f, -H);
    CGContextConcatCTM(maskContext, transform);
    CGContextAddArc(maskContext, W1/2, H1/2, r1,ToRad(startAng1), ToRad(ang1), 1);
    CGContextStrokePath(maskContext);
    CGImageRef mask=CGBitmapContextCreateImage(maskContext);
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    CGImageRelease(mask);
    UIGraphicsEndImageContext();
    //-- Save context and draw gradient
    CGContextDrawRadialGradient(context, grad, center, W1*0.001, CGPointMake(W1/2, H1/2), W1*0.90, kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(context);

    
    ////--- Curve 2
    
    
    //-- Create a circular mask
    UIGraphicsBeginImageContext(self.bounds.size);
    maskContext= UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(maskContext, 10);
    CGContextConcatCTM(maskContext, transform);
    CGContextBeginPath(context);
    CGContextAddArc(maskContext, W1/2, H1/2, r2,ToRad(startAng2), ToRad(ang2), 1);
    CGContextStrokePath(maskContext);
    mask=CGBitmapContextCreateImage(maskContext);
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    CGImageRelease(mask);
    UIGraphicsEndImageContext();
    //-- Update locations and draw gradient
    
    locations[0]=0.864407;
    locations[1]=1.0;
    locations[2]=0.902542;
    locations[3]=1.0;
    grad = CGGradientCreateWithColorComponents(colorspace, electriBlue, locations, 4);
    CGContextDrawRadialGradient(context, grad, center, W1*0.001, center, r2, kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(context);


    //-- Curve 3
    
    
    UIGraphicsBeginImageContext(self.bounds.size);
    maskContext= UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(maskContext, 5);
    CGContextConcatCTM(maskContext, transform);
    CGContextBeginPath(context);
    CGContextAddArc(maskContext, W1/2, H1/2, r3,ToRad(startAng3), ToRad(ang3), 1);
    CGContextStrokePath(maskContext);
    CGContextSetLineWidth(maskContext, 2);
//    CGContextAddArc(maskContext,
//                    center.x+(r3*cos(ToRad(ang3))),center.y+(r3*sin(ToRad(ang3))),
//                    10, 0, ToRad(360), 1);
//    CGContextStrokePath(maskContext);
    mask=CGBitmapContextCreateImage(maskContext);
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    CGImageRelease(mask);
    UIGraphicsEndImageContext();
    //-- Update locations and draw gradient
    
    locations[0]=1.0;
    locations[1]=0.970339;
    locations[2]=0.991525;
    locations[3]=0.809322;
    grad = CGGradientCreateWithColorComponents(colorspace, electriBlue, locations, 4);
    CGContextDrawRadialGradient(context, grad, center, W1*0.001, center, r3, kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(context);


    //-- Curve 4
    
    
    UIGraphicsBeginImageContext(self.bounds.size);
    maskContext= UIGraphicsGetCurrentContext();
    CGContextSetLineWidth(maskContext, 15);
    CGContextConcatCTM(maskContext, transform);
    CGContextAddArc(maskContext, center.x,center.y, r4,ToRad(startAng4), ToRad(ang4), 0);
    CGContextStrokePath(maskContext);
    mask=CGBitmapContextCreateImage(maskContext);
    CGContextSaveGState(context);
    CGContextClipToMask(context, self.bounds, mask);
    CGImageRelease(mask);
    UIGraphicsEndImageContext();
    //-- Update locations and draw gradient
    
    locations[0]=0.50;
    locations[1]=0.461864;
    locations[2]=0.415254;
    locations[3]=0.398305;
    grad = CGGradientCreateWithColorComponents(colorspace, electriBlue, locations, 4);
    CGContextDrawRadialGradient(context, grad, center, W1*0.001, center, W1, kCGGradientDrawsBeforeStartLocation);
    CGContextRestoreGState(context);
    
    
    
    //Realese the gradient and color space
    CGColorSpaceRelease(colorspace);
    CGGradientRelease(grad);

}

-(void)drawControlCurves:(CGContextRef)context{
    //-- Touch sensitive curves:
    [curve1 addArcWithCenter:center radius:r1 startAngle:0 endAngle:ToRad(360) clockwise:1];
    CGContextAddPath(context, curve1.CGPath);
    [curve2 addArcWithCenter:center radius:r2 startAngle:0 endAngle:ToRad(360) clockwise:1];
    CGContextAddPath(context, curve2.CGPath);
    [curve3 addArcWithCenter:center radius:r3 startAngle:0 endAngle:ToRad(360) clockwise:1];
    CGContextAddPath(context, curve3.CGPath);
    [curve4 addArcWithCenter:center radius:r4 startAngle:0 endAngle:ToRad(360) clockwise:1];
    CGContextAddPath(context, curve4.CGPath);
}



#pragma mark TouchTracking - Identify Curve being updated

/*  
    First Identify which curve is being touched
    Given the proximity of curves 1,2 and 3, we
    will use the following criteria.
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    UITouch *t=[touches anyObject];
    CGPoint location=[t locationInView:self];
    
    if ([curve1 containsPoint:location] ) {
        NSLog(@"Touching curve 1");
        updateCurve=PHASE;
    }
    
    if ([curve2 containsPoint:location]&& (![curve1 containsPoint:location])) {
        NSLog(@"Touching curve 2");
        updateCurve=LFO;
    }
    
    if ([curve3 containsPoint:location]&&(![curve2 containsPoint:location])
        &&(![curve1 containsPoint:location])&&([curve4 containsPoint:location])) {
        NSLog(@"Touching curve 3");
        updateCurve=DETUNE;
    }
    
//    if ([curve4 containsPoint:location]&&(![curve1 containsPoint:location])
//        &&(![curve2 containsPoint:location])&&(![curve3 containsPoint:location])) {
//        NSLog(@"Touching curve 4");
//        updateCurve=WAVE;
//    }
    
    
    
}

#pragma mark TouchTracking - Update Curves with user input from Central Controller
/*
    Update the curves as the user updates with finger.
    The variable 'range' is used for the central curves, it calculates a value
    between 0.0 and 1.0 representing the percentage of the curve that is being 
    filled. It is just an indicator that communicates the range of this custom
    slider.

*/


-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    //-- Get touches location
    UITouch *t=[touches anyObject];
    CGPoint location=[t locationInView:self];
    //-- Get the angle
    float angle=AngleFromNorth(center, location, NO);
    //-- 'range' will calculate the percentage within the range of the central curve slider
    double range;
    
    
    //-- React according which curve is being updated:
    
    
    switch (updateCurve) {
        case PHASE:
            // This formula describes the shape of the slider curve:
            range= (angle>=0 && angle<=80)?(80-angle)/250:((360-angle)+80)/250.0f;
            
            // Dismiss values that are negative or >1.0.
            if (range>=0.0 && range<=1.0) {
                ang1=angle;
                [self setNeedsDisplay];
            }
            
            // Update the associated round slider
            [sliderPhase updateRoundSlider:range];
            
            // Update the visual feedback comming from the LFOWaveIndicator and Audio Controller
            [self updateOscillatorWave:range forWaveShape:LFOWaveIndicator];

            
            break;
            
        case LFO:
            //-- Calculate the range in the central controller
            range=1-( (angle-80)/270);
            
            //-- Dismiss values that are negative or >1.0.
            if (range>=0.0 && range<=1.0) {
                ang2=angle;
                [self setNeedsDisplay];
            }
            
            //-- Update the associated round slider
            [sliderLFO updateRoundSlider:range];
            
            //-- Update LFO Frequency for the given oscillator
            [AUCurveController setLFOfrequency:range forOscillator:(int)OscNumber.integerValue];
            break;
            
        case 3:
            //-- Calculate the range in the central controller
            range= (angle>=0 && angle<=startAng3)?(startAng3-angle)/180.0f:((360-angle)+startAng3)/180.0f;

            // Dismiss values that are negative or >1.0.
            if (range>=0.0 && range<=1.0) {
                ang3=angle;
                [self setNeedsDisplay];
            }
            
            //-- Update the associated round slider
            [sliderDetune updateRoundSlider:range];
            
            //-- Update Detune for the given oscillator
            [AUCurveController setDetuneAmount:range forOscillator:(int)OscNumber.integerValue];
            
            break;
            
        default:
            break;
    }
    
    //-- You don't need the 'updateCurve' lock variable for the curve 4.
    //-- So you need to check it before leave
    
    if ([curve4 containsPoint:location]&&(![curve1 containsPoint:location])
        &&(![curve2 containsPoint:location])&&(![curve3 containsPoint:location])) {
        
        //-- Obtain range
        range=(angle-85)/(280-85);
        
            if(range>=0 && range<=1.0){
                ang4=angle;
                [self setNeedsDisplay];
                [self updateOscillatorWave:range forWaveShape:centralWave];
            }
    }
}

#pragma mark TouchTracking - Update Curves with user input from secundary round sliders
/*
    Update the curves as the user updates with finger.
    The variable range contains a value between 0.0 and 1.0 that is used to describe the
    sections of the 360 degree curve that the controller is using. For this reason we find
    cases where the angle receives a different formula.
 
 */
-(void)updateCurve:(int)curveNumber withRange:(float)range{
    switch (curveNumber) {
        case PHASE:
            
            //-- Calculate the angle that the received range is describing
            if ((range>=0.0)&&(range<0.32))
                ang1=80-range*250;

            if ((range>=0.32)&&(range<=1.0))
                ang1=440-250*range;
            
            [self setNeedsDisplay];
            
            
            //-- Update the visual feedback comming from the LFOWaveIndicator
            [self updateOscillatorWave:range forWaveShape:LFOWaveIndicator];
            break;
            
        case LFO:
            
            //-- Calculate the angle that the received range is describing
            ang2=((1-range)*270)+80;
            [self setNeedsDisplay];
            
            //-- Update LFO frequency for the given oscillator
            if (OscNumber.integerValue==1) {
                [AUCurveController setLFOfrequency:range forOscillator:1];
                
            }
            if (OscNumber.integerValue==2) {
                [AUCurveController setLFOfrequency:range forOscillator:2];
            }
            
            break;
            
        case DETUNE:
            //-- Calculate the angle that the received range is describing
            if ((range>=0)&&(range<=0.250)) {
                ang3=45-(180*range);
            }
            if ((range>0.250)&&(range<=1.0)) {
                ang3=405-(180*range);
            }
            [self setNeedsDisplay];
            
            
            //-- Set detune amount in semitones for the given oscillator
            if (OscNumber.integerValue==1) {
                [AUCurveController setDetuneAmount:range forOscillator:1];
                
            }
            if (OscNumber.integerValue==2) {
                [AUCurveController setDetuneAmount:range forOscillator:2];
            }
            
            break;

        default:
            break;
    }
}

#pragma mark Deactivate the Update Mode
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    updateCurve=0;
}





#pragma mark Oscillators Wave Shape Setter
    /*
     This methods update the state of the oscillator controller
     */


//-- Updates the Visual Feedback and the Audio Controller
-(void)updateOscillatorWave:(double)range forWaveShape:(WaveShape*)wave{
    //typedef enum {NOISE,SINE, TRIANGLE, SAW1,SAW2,SQUARE} Shape;

    if ((range>=0)&&(range<=0.241160)) {
        //-- Update  Visual Feedback

        [wave setShape:NOISE];
        [wave setNeedsDisplay];
        
        //-- Update Audio Unit
        
        if (wave==centralWave) {
            [AUCurveController updateWave:NOISE forOscillator:(int)OscNumber.integerValue];
        }
        if (wave==LFOWaveIndicator) {
            [AUCurveController updateLFOWave:NOISE forOscillator:(int)OscNumber.integerValue];
        }
    }
    
    if ((range>0.241160)&&(range<=0.371929)) {

        //-- Update  Visual Feedback
        
        [wave setShape:SINE];
        [wave setNeedsDisplay];
        
        //-- Update Audio Unit
        
        if (wave==centralWave) {
            [AUCurveController updateWave:SINE forOscillator:(int)OscNumber.integerValue];
        }
        if (wave==LFOWaveIndicator) {
            [AUCurveController updateLFOWave:SINE forOscillator:(int)OscNumber.integerValue];
        }
    }
    
    if ((range>0.371929)&&(range<=0.479240)) {
        
        //-- Update  Visual Feedback
        
        [wave setShape:TRIANGLE];
        [wave setNeedsDisplay];
        
        //-- Update Audio Unit
        
        if (wave==centralWave) {
            [AUCurveController updateWave:TRIANGLE forOscillator:(int)OscNumber.integerValue];
        }
        if (wave==LFOWaveIndicator) {
            [AUCurveController updateLFOWave:TRIANGLE forOscillator:(int)OscNumber.integerValue];
        }
    }
    
    if ((range>0.479240)&&(range<=0.597840)) {
        
        //-- Update  Visual Feedback
        
        [wave setShape:SAW2];
        [wave setNeedsDisplay];
        
        //-- Update Audio Unit
        
        if (wave==centralWave) {
            [AUCurveController updateWave:SAW2 forOscillator:(int)OscNumber.integerValue];
        }
        if (wave==LFOWaveIndicator) {
            [AUCurveController updateLFOWave:SAW2 forOscillator:(int)OscNumber.integerValue];
        }

    }
    
    if ((range>0.597840)&&(range<0.95)) {

        //-- Update  Visual Feedback
        
        [wave setShape:SQUARE];
        [wave setSquareDuty:(CGFloat)(range-0.5)*2];
        [wave setNeedsDisplay];
        
        //-- Update Audio Unit
        if (wave==centralWave) {
            [AUCurveController updateWave:SQUARE forOscillator:(int)OscNumber.integerValue];
            [AUCurveController updateSquareCycleDuty:(CGFloat)(range-0.5)*2 forOscillator:(int)OscNumber.integerValue];
        }
        if (wave==LFOWaveIndicator) {

            [AUCurveController updateLFOWave:SQUARE forOscillator:(int)OscNumber.integerValue];
            [AUCurveController updateLFOSquareCycleDuty:(CGFloat)(range-0.5)*2 forOscillator:(int)OscNumber.integerValue];
        }

    }
}

#pragma mark Utilities
//Sourcecode from Apple example clockControl
//Calculate the direction in degrees from a center point to an arbitrary position.
static inline float AngleFromNorth(CGPoint p1, CGPoint p2, BOOL flipped) {
    CGPoint v = CGPointMake(p2.x-p1.x,p2.y-p1.y);
    float vmag = sqrt(SQR(v.x) + SQR(v.y)), result = 0;
    v.x /= vmag;
    v.y /= vmag;
    double radians = atan2(v.y,v.x);
    result = ToDeg(radians);
    return (result >=0  ? result : result + 360.0);
}

-(void)testFromOscController{
    NSLog(@"Test from oscillator controller");
}


@end









