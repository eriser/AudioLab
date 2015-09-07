//
//  RoundSlider.m
//  OscillatorController
//
//  Created by Ness on 8/18/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "RoundSlider.h"
/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

/** Parameters **/
#define TB_SAFEAREA_PADDING 10




@class OscillatorController;
@interface OscillatorController{
    OscillatorController *osc;
}
-(void)testFromOscController;
-(void)updateOscillatorWave:(double)range;
-(void)updateCurve:(int)curveNumber withRange:(float)range;


@end


#pragma mark - Private -
@interface RoundSlider(){
    UITextField *_textField;
    int radius;
    CGFloat W;
    CGFloat H;
}
@end


@implementation RoundSlider
@synthesize identifier,sliderColor;
#pragma mark - Implementation -
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        self.opaque = NO;
        //NSLog(@"flag");
        self.backgroundColor=[UIColor blackColor];
        //Define the circle radius taking into account the safe area
        radius = self.frame.size.width/2 - TB_SAFEAREA_PADDING;
        W=self.frame.size.width;
        H=self.frame.size.height;
        //Initialize the Angle at 0
        self.angle = 360;
        self.range=0.0;
        sliderColor=0;
        //Define the Font
        UIFont *font = [UIFont fontWithName:TB_FONTFAMILY size:TB_FONTSIZE];
        //Calculate font size needed to display 3 numbers
        NSString *str = @"0000";
        NSDictionary *attributes=[[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        CGSize fontSize=[str sizeWithAttributes:attributes];
        //Using a TextField area we can easily modify the control to get user input from this field
        _textField = [[UITextField alloc]initWithFrame:CGRectMake((W  - fontSize.width) /2,
                                                                  (H - fontSize.height) /2,
                                                                  fontSize.width,
                                                                  fontSize.height)];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = font;
        _textField.text = [NSString stringWithFormat:@"%d",self.angle];
        _textField.enabled = NO;
        
        [self addSubview:_textField];
        
        
        //////
        
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    
    self = [super initWithCoder:aDecoder];
    if(self){
        
        self.opaque = NO;
        //NSLog(@"flag");
        self.backgroundColor=[UIColor blackColor];
        //Define the circle radius taking into account the safe area
        radius = self.frame.size.width/2 - TB_SAFEAREA_PADDING;
        W=self.frame.size.width;
        H=self.frame.size.height;
        //Initialize the Angle at 0
        self.angle = 360;
        
        
        //Define the Font
        UIFont *font = [UIFont fontWithName:TB_FONTFAMILY size:TB_FONTSIZE];
        //Calculate font size needed to display 3 numbers
        NSString *str = @"000";
        NSDictionary *attributes=[[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        CGSize fontSize=[str sizeWithAttributes:attributes];
        //Using a TextField area we can easily modify the control to get user input from this field
        _textField = [[UITextField alloc]initWithFrame:CGRectMake((W  - fontSize.width) /2,
                                                                  (H - fontSize.height) /2,
                                                                  fontSize.width,
                                                                  fontSize.height)];
        _textField.backgroundColor = [UIColor clearColor];
        _textField.textColor = [UIColor colorWithWhite:1 alpha:0.8];
        _textField.textAlignment = NSTextAlignmentCenter;
        _textField.font = font;
        _textField.text = [NSString stringWithFormat:@"%d",self.angle];
        _textField.enabled = NO;
        
        [self addSubview:_textField];
    }
    
    return self;
}


#pragma mark - UIControl Override -

/** Tracking is started **/
-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super beginTrackingWithTouch:touch withEvent:event];
    
    //We need to track continuously
    return YES;
}

/** Track continuos touch event (like drag) **/
-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super continueTrackingWithTouch:touch withEvent:event];
    
    //Get touch location
    CGPoint lastPoint = [touch locationInView:self];
    
    //Use the location to design the Handle
    [self movehandle:lastPoint];
    
    //Control value has changed, let's notify that
    [self sendActionsForControlEvents:UIControlEventValueChanged];
    

    //-- Connection methods with superview
    self.range=(float)(self.angle/360.0);
    //printf("range=%f\n",self.range);
    [(OscillatorController*)[self superview] updateCurve:identifier withRange:self.range];
    return YES;
}

/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
}


#pragma mark - Drawing Functions -

//Use the draw rect to draw the Background, the Circle and the Handle
-(void)drawRect:(CGRect)rect{
    
    [super drawRect:rect];
    
    CGContextRef ctx = UIGraphicsGetCurrentContext();
    
    /** Draw the Background **/
    
    //Create the path
    CGContextAddArc(ctx, self.frame.size.width/2, self.frame.size.height/2, radius, 0, M_PI *2, 0);
    
    //Set the stroke color to black
    [[UIColor blackColor]setStroke];
    
    //Define line width and cap
    CGContextSetLineWidth(ctx, TB_BACKGROUND_WIDTH);
    CGContextSetLineCap(ctx, kCGLineCapButt);
    
    //draw it!
    CGContextDrawPath(ctx, kCGPathStroke);
    
    
    //** Draw the circle (using a clipped gradient) **/
    
    
    /** Create THE MASK Image **/
    UIGraphicsBeginImageContext(CGSizeMake(W, H));
    CGContextRef imageCtx = UIGraphicsGetCurrentContext();
    
    CGContextAddArc(imageCtx, self.frame.size.width/2  , self.frame.size.height/2, radius, 0, ToRad(self.angle), 0);
    [[UIColor redColor]set];
    
    //Use shadow to create the Blur effect
    CGContextSetShadowWithColor(imageCtx, CGSizeMake(0, 1), (self.angle/40), [UIColor blackColor].CGColor);
    
    //define the path
    CGContextSetLineWidth(imageCtx, TB_LINE_WIDTH);
    CGContextDrawPath(imageCtx, kCGPathStroke);
    
    //save the context content into the image mask
    CGImageRef mask = CGBitmapContextCreateImage(UIGraphicsGetCurrentContext());
    UIGraphicsEndImageContext();
    
    
    
    /** Clip Context to the mask **/
    CGContextSaveGState(ctx);
    
    CGContextClipToMask(ctx, self.bounds, mask);
    CGImageRelease(mask);
    
    
    
    /** THE GRADIENT **/
    switch (sliderColor) {
        case YELLOW:
        //Yellow
            components[0]=250/255.0;
            components[1]=272/255.0;
            components[2]=10/255.0;
            components[3]=1.0;
            
            components[4]=1.0;
            components[5]=1.0;
            components[6]=136/255.0;
            components[7]=1.0;
            break;
            
        case GREEN:
            components[0]=24/255.0;
            components[1]=69/255.0;
            components[2]=2/255.0;
            components[3]=1.0;
            
            components[4]=61/255.0;
            components[5]=1.0;
            components[6]=5/255.0;
            components[7]=1.0;
            break;
            
        case RED:
            components[0]=100/255.0;
            components[1]=0/255.0;
            components[2]=3/255.0;
            components[3]=1.0;
            
            components[4]=228/255.0;
            components[5]=25/255.0;
            components[6]=40/255.0;
            components[7]=1.0;
        break;
            
        case FIRE:
            //        197/255.0, 0.0, 3/255.0, 1.0,     // Start color - Blue
            //        252/255.0, 205/255.0, 3/255.0, 1.0 };   // End color - Violet
            components[0]=197/255.0;
            components[1]=0.0/255.0;
            components[2]=3/255.0;
            components[3]=1.0;
            
            components[4]=252/255.0;
            components[5]=205/255.0;
            components[6]=3/255.0;
            components[7]=1.0;
            break;
            
        default:
            break;
    }


    




    
    CGColorSpaceRef baseSpace = CGColorSpaceCreateDeviceRGB();
    CGGradientRef gradient = CGGradientCreateWithColorComponents(baseSpace, components, NULL, 2);
    CGColorSpaceRelease(baseSpace), baseSpace = NULL;
    
    //Gradient direction
    CGPoint startPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMinY(rect));
    CGPoint endPoint = CGPointMake(CGRectGetMidX(rect), CGRectGetMaxY(rect));
    
    //Draw the gradient
    CGContextDrawLinearGradient(ctx, gradient, startPoint, endPoint, 0);
    CGGradientRelease(gradient), gradient = NULL;
    
    CGContextRestoreGState(ctx);
    
    
    /** Add some light reflection effects on the background circle**/
    
    CGContextSetLineWidth(ctx, 1);
    CGContextSetLineCap(ctx, kCGLineCapRound);
    
    //Draw the outside light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius+TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
    //draw the inner light
    CGContextBeginPath(ctx);
    CGContextAddArc(ctx, self.frame.size.width/2  , self.frame.size.height/2, radius-TB_BACKGROUND_WIDTH/2, 0, ToRad(-self.angle), 1);
    [[UIColor colorWithWhite:1.0 alpha:0.05]set];
    CGContextDrawPath(ctx, kCGPathStroke);
    
 
    
}

#pragma mark - Math -

/** Move the Handle **/
-(void)movehandle:(CGPoint)lastPoint{
    
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    
    //Store the new angle
    self.angle = 360 - angleInt;
    //Update the textfield
    //enum parameter {PHASE=1,LFO,DETUNE,WAVE};
    switch (identifier) {
        case 1:     //PHASE
            _textField.text =  [NSString stringWithFormat:@"%d", (int)floorf((self.angle/360.0)*100)];
            
            break;
        case 2:     //LFO
            _textField.text =  [NSString stringWithFormat:@"%d", (int)floorf((self.angle/360.0)*13)-3];
            //[(OscillatorController*)[self superview] updateOscillatorWave:self.range];

            break;
        case 3:     //DETUNE
            _textField.text =  [NSString stringWithFormat:@"%d", 10-(int)floorf((self.angle/360.0)*20)];
            break;
        default:
            break;
    }
    
    
    //Redraw
    [self setNeedsDisplay];
}

/** Given the angle, get the point position on circumference **/
-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Circle center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2 - TB_LINE_WIDTH/2, self.frame.size.height/2 - TB_LINE_WIDTH/2);
    
    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + radius * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x + radius * cos(ToRad(-angleInt)));
    
    return result;
}

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

-(void)updateRoundSlider:(float)range{
    self.angle=range*360;
    //Update the textfield
    //_textField.text =  [NSString stringWithFormat:@"%d", self.angle];
    float freq;
    if (range>=0 && range<=1) {
        switch (identifier) {
            case 1:     //PHASE

//                [(OscillatorController*)[self superview] updateOscillatorWave:range forWaveShape:[(OscillatorController*)[self superview]LFOWaveIndicator]];

                _textField.text =  [NSString stringWithFormat:@"%d", (int)floorf((self.angle/360.0)*100)];
                break;
            case 2:     //LFO
                freq=floorf((range*13))-3;
                _textField.text =  [NSString stringWithFormat:@"%.2f", freq];
                
                break;
            case 3:     //DETUNE
                _textField.text =  [NSString stringWithFormat:@"%d", 10-(int)floorf((self.angle/360.0)*20)];
                break;
            default:
                break;
        }

    }
    [self setNeedsDisplay];
}

@end
