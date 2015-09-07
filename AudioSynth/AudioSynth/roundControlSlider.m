//
//  roundControlSlider.m
//  RoundSlider
//
//  Created by Ness on 8/8/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "roundControlSlider.h"
/** Helper Functions **/
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

#define SAFEAREA_PADDING 30
#define LINE_WIDTH 5
#pragma mark - Private -
@interface roundControlSlider(){
    CGFloat radius;
    CGFloat W;
    CGFloat H;
    UITextField *textField;
    UITextField *parameterName;
    UIColor *controlColor;
    CGAffineTransform transform;
}
@end

@class FilterSelector;
@interface FilterSelector{
    FilterSelector *filterSelector;
}
-(void)updateFilterCutFrequency:(double)range;
-(void)updateFilterLFOFrequency:(double)range;
@end

@implementation roundControlSlider
@synthesize identity;
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        //-- Basic Settings and metric values
        self.opaque = NO;
        self.backgroundColor=[UIColor clearColor];
        W=self.frame.size.width;
        H=self.frame.size.height;
        
        transform= CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
        transform = CGAffineTransformTranslate(transform, 0.0f, -H);
        
        //Define ring radius
        radius= (W/2)*0.80;
        //Initialize angle
        self.angle=225;
        
        //Control color
        controlColor=[UIColor colorWithRed:246/255.0f green:70/255.0f blue:17/255.0f alpha:1.0];
        
        //-- Labels
        UIFont *font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:10];
        //Space needed for 3 digits
        NSString *str=@"000";
        NSDictionary *att=[[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        CGSize fontSize=[str sizeWithAttributes:att];
        
        //Construct a text field
        textField=[[UITextField alloc]initWithFrame:CGRectMake((W-fontSize.width)/2, (H-fontSize.height)/2, fontSize.width, fontSize.height)];
        textField.backgroundColor=[UIColor clearColor];
        textField.textColor=[UIColor colorWithRed:155/255.0f green:118/255.0f blue:46/255.0f alpha:1.0];
        textField.textAlignment=NSTextAlignmentCenter;
        textField.font=font;
        textField.text=[NSString stringWithFormat:@"%d",self.angle];
        textField.enabled=NO;
        [self addSubview:textField];
        
        //Set the paramenter name
        NSString *str2=@"DEFAULT";
        CGSize paramNameSize= [str2 sizeWithAttributes:att];
        parameterName=[[UITextField alloc]initWithFrame:CGRectMake(W*0.215, H*0.80, paramNameSize.width, paramNameSize.height)];
        parameterName.enabled=NO;
        parameterName.text=@"DEFAULT";
        parameterName.font=font;
        parameterName.backgroundColor=[UIColor clearColor];
        parameterName.textColor=[UIColor colorWithRed:155/255.0f green:118/255.0f blue:46/255.0f alpha:1.0];
        parameterName.textAlignment=NSTextAlignmentCenter;
        [self addSubview:parameterName];
    }
    return self;
}
-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        
        //-- Basic Settings and metric values
        self.opaque = NO;
        self.backgroundColor=[UIColor clearColor];
        W=self.frame.size.width;
        H=self.frame.size.height;
        
        transform= CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, 1.0f, -1.0f);
        transform = CGAffineTransformTranslate(transform, 0.0f, -H);
        
        //Define ring radius
        radius= (W/2)*0.80;
        //Initialize angle
        self.angle=225;
        
        //Control color
        controlColor=[UIColor colorWithRed:246/255.0f green:70/255.0f blue:17/255.0f alpha:1.0];
        
        //-- Labels
        UIFont *font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:24];
        //Space needed for 3 digits
        NSString *str=@"000";
        NSDictionary *att=[[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        CGSize fontSize=[str sizeWithAttributes:att];
        
        //Construct a text field
        textField=[[UITextField alloc]initWithFrame:CGRectMake((W-fontSize.width)/2, (H-fontSize.height)/2, fontSize.width, fontSize.height)];
        textField.backgroundColor=[UIColor clearColor];
        textField.textColor=[UIColor colorWithRed:155/255.0f green:118/255.0f blue:46/255.0f alpha:1.0];
        textField.textAlignment=NSTextAlignmentCenter;
        textField.font=font;
        textField.text=[NSString stringWithFormat:@"%d",self.angle];
        textField.enabled=NO;
        [self addSubview:textField];
        
        //Set the paramenter name
        NSString *str2=@"DEFAULT";
        CGSize paramNameSize= [str2 sizeWithAttributes:att];
        parameterName=[[UITextField alloc]initWithFrame:CGRectMake(W*0.215, H*0.80, paramNameSize.width, paramNameSize.height)];
        parameterName.text=@"DEFAULT";
        parameterName.font=font;
        parameterName.backgroundColor=[UIColor clearColor];
        parameterName.textColor=[UIColor colorWithRed:155/255.0f green:118/255.0f blue:46/255.0f alpha:1.0];
        parameterName.textAlignment=NSTextAlignmentCenter;
        [self addSubview:parameterName];
        
        
    }
    return self;
}

-(void)setParameterName:(NSString *)name{
    parameterName.text=name;
    [self setNeedsDisplay];
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
    
    return YES;
}

/** Track is finished **/
-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event{
    [super endTrackingWithTouch:touch withEvent:event];
    
}

#pragma mark - Drawing Functions -

- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    NSLog(@"%f ",radius);
    CGContextRef context=UIGraphicsGetCurrentContext();
    
    CGContextSaveGState(context);
    //Draw and arc representing the slider control
    CGContextConcatCTM(context, transform);
    CGContextAddArc(context, self.frame.size.width/2, self.frame.size.height/2, radius, ToRad(315), ToRad(self.angle), 0);
    [controlColor setStroke];
    CGContextSetShadowWithColor(context, CGSizeMake(0, 0), 10, controlColor.CGColor);

    CGContextSetLineWidth(context, LINE_WIDTH);
    CGContextDrawPath(context, kCGPathStroke);
    CGContextRestoreGState(context);

    [self drawTheHandle:context];
}

/** Move the Handle **/
-(void)movehandle:(CGPoint)lastPoint{
    double range;
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    
    //Store the new angle
    self.angle = 360 - angleInt;
    
    //Check if angle is under limits
    if ((self.angle>315 && self.angle<360)||(self.angle>=0 &&self.angle<225)) {
        if ((self.angle>=315 && self.angle<360)) {
            range=0.83 +((360-self.angle)/265.0);
            textField.text =  [NSString stringWithFormat:@"%.1f", range];
            if (identity==1) {
                [(FilterSelector*)[self superview] updateFilterLFOFrequency:range];

            }else{
                [(FilterSelector*)[self superview] updateFilterCutFrequency:range];
            }
            
        }
        if ((self.angle>=0 &&self.angle<221)) {
            range=(1-(self.angle/221.0))*0.83;
            printf("range=%f ",range);
            textField.text =  [NSString stringWithFormat:@"%.1f", range];
            if (identity==1) {
                [(FilterSelector*)[self superview] updateFilterLFOFrequency:range];
            }else{
                [(FilterSelector*)[self superview] updateFilterCutFrequency:range];
            }

        }
        
        //Update the textfield
        //textField.text =  [NSString stringWithFormat:@"%d", self.angle];
        //Redraw
        [self setNeedsDisplay];
    }

    
}


/** Draw a white knob over the circle **/
-(void) drawTheHandle:(CGContextRef)ctx{
    
    CGContextSaveGState(ctx);
    

    //CGContextSetShadowWithColor(ctx, CGSizeMake(0, 0), 3, [UIColor blackColor].CGColor);
    
    //Get the handle position
    CGPoint handleCenter =  [self pointFromAngle: self.angle];
    
    
    [controlColor set];
    

    CGContextFillEllipseInRect(ctx, CGRectMake(handleCenter.x, handleCenter.y, LINE_WIDTH, LINE_WIDTH));
    
    CGContextRestoreGState(ctx);
}
/** Given the angle, get the point position on circumference **/
-(CGPoint)pointFromAngle:(int)angleInt{
    
    //Circle center
    CGPoint centerPoint = CGPointMake(W/2 - LINE_WIDTH/2, H/2 - LINE_WIDTH/2);
    
    //The point position on the circumference
    CGPoint result;
    result.y = round(centerPoint.y + (radius*0.7) * sin(ToRad(-angleInt))) ;
    result.x = round(centerPoint.x + (radius*0.7) * cos(ToRad(-angleInt)));
    
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

@end
