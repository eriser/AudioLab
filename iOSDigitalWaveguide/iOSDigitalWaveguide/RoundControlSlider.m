//
//  RoundControlSlider.m
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "RoundControlSlider.h"

#pragma mark Utilities
#define ToRad(deg) 		( (M_PI * (deg)) / 180.0 )
#define ToDeg(rad)		( (180.0 * (rad)) / M_PI )
#define SQR(x)			( (x) * (x) )

#define SAFEAREA_PADDING 30
#define LINE_WIDTH 5

#pragma mark Private Variables



///-- Foward declaration of AudioController
@class AudioController;
@interface AudioController
-(void)setPickupPosition:(double)position;
-(void)setPluckInputPosition:(double)position;
-(void)setAmp:(double)value;
-(void)updateDelayLineStructure;
@end



@class ControlPanel;
@interface ControlPanel
@property AudioController *controlPanelAU;
@end

@interface RoundControlSlider(){
    CGFloat radius;
    CGFloat W;
    CGFloat H;
    
    //Textfields inputs
    UITextField *textField;
    UITextField *parameterNameTextField;
    NSString *paramNameValue;
    UIColor *controlColor;
    CGAffineTransform transform;
    UIFont *font;
    NSDictionary *att;
    CGSize fontSize;
}
@end

@implementation RoundControlSlider
@synthesize identifier,parameterName;


-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        
        //-- Basic Settings and metric values
        //self.opaque = YES;
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
        font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:14];
        //Space needed for 3 digits
        NSString *str=@"0000";
        att=[[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        fontSize=[str sizeWithAttributes:att];
        
        //Construct a text field
        textField=[[UITextField alloc]initWithFrame:CGRectMake((W-fontSize.width)/2, (H-fontSize.height)/2, fontSize.width, fontSize.height)];
        textField.backgroundColor=[UIColor clearColor];
        textField.textColor=[UIColor colorWithRed:155/255.0f green:118/255.0f blue:46/255.0f alpha:1.0];
        textField.textAlignment=NSTextAlignmentCenter;
        textField.font=font;
        textField.text=[NSString stringWithFormat:@"%d",100];
        textField.enabled=NO;
        [self addSubview:textField];
        
        
    }
    return self;
}

-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        //-- Basic Settings and metric values
        //self.opaque = YES;
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
        font = [UIFont fontWithName:@"Futura-CondensedExtraBold" size:14];
        //Space needed for 3 digits
        NSString *str=@"0000";
        att=[[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        fontSize=[str sizeWithAttributes:att];
        
        //Construct a text field
        textField=[[UITextField alloc]initWithFrame:CGRectMake((W-fontSize.width)/2, (H-fontSize.height)/2, fontSize.width, fontSize.height)];
        textField.backgroundColor=[UIColor clearColor];
        textField.textColor=[UIColor colorWithRed:155/255.0f green:118/255.0f blue:46/255.0f alpha:1.0];
        textField.textAlignment=NSTextAlignmentCenter;
        textField.font=font;
        textField.text=[NSString stringWithFormat:@"%d",100];
        textField.enabled=NO;
        [self addSubview:textField];
        
        //Now prepare the textfield
        NSLog(@"%@",parameterName);
        CGSize paramNameSize= [parameterName sizeWithAttributes:att];
        parameterNameTextField=[[UITextField alloc]initWithFrame:CGRectMake(W*0.215, H*0.80, paramNameSize.width, paramNameSize.height)];
        parameterNameTextField.font=font;
        parameterNameTextField.backgroundColor=[UIColor clearColor];
        parameterNameTextField.textColor=[UIColor colorWithRed:155/255.0f green:218/255.0f blue:146/255.0f alpha:1.0];
        parameterNameTextField.textAlignment=NSTextAlignmentCenter;
        parameterNameTextField.text=parameterName;
        [self addSubview:parameterNameTextField];

    }
    return self;
}

#pragma  mark Properties from InterfaceBuilder
-(void)setValue:(id)value forKeyPath:(NSString *)keyPath{

    if ([keyPath isEqual:@"identifier"]) {
        identifier=value;
    }
    if ([keyPath isEqual:@"parameterName"]) {
            NSLog(@"flag");
        //Set the paramenter name
        parameterName=value;
        
        //Now prepare the textfield
        CGSize paramNameSize= [parameterName sizeWithAttributes:att];
        parameterNameTextField=[[UITextField alloc]initWithFrame:CGRectMake(W*0.215, H*0.80, paramNameSize.width, paramNameSize.height)];
        parameterNameTextField.font=font;
        parameterNameTextField.backgroundColor=[UIColor clearColor];
        parameterNameTextField.textColor=[UIColor colorWithRed:155/255.0f green:218/255.0f blue:146/255.0f alpha:1.0];
        parameterNameTextField.textAlignment=NSTextAlignmentCenter;
        parameterNameTextField.text=parameterName;
        [self addSubview:parameterNameTextField];
        [self setNeedsDisplay];

    }
}


#pragma mark - UIControl Override -

/** Tracking is started **/
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesBegan:touches withEvent:event];
    
}


/** Track continuos touch event (like drag) **/
-(void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesMoved:touches withEvent:event];
    //Get touch location
    UITouch *touch=(UITouch*)[touches anyObject];
    
    CGPoint lastPoint = [touch locationInView:self];
    
    //Use the location to design the Handle
    [self movehandle:lastPoint];
  
}


/** Track is finished **/
-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    [super touchesEnded:touches withEvent:event];
}



#pragma mark Drawing Functions
- (void)drawRect:(CGRect)rect {
    [super drawRect:rect];
    
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
    
    //Get the center
    CGPoint centerPoint = CGPointMake(self.frame.size.width/2, self.frame.size.height/2);
    
    //Calculate the direction from a center point and a arbitrary position.
    float currentAngle = AngleFromNorth(centerPoint, lastPoint, NO);
    int angleInt = floor(currentAngle);
    
    //Store the new angle
    self.angle = 360 - angleInt;
    
    //Check if angle is under limits
    if ((self.angle>=315 && self.angle<360)||(self.angle>0 &&self.angle<225)) {
        //Update the textfield
        int value;
        value=(self.angle>=315 && self.angle<360)?-(315-self.angle)*100/269:(self.angle+45)*100/269;
        self.decimalVal=(double)value/100.0;
        
    // Update the algorithm input variables
        switch (identifier.integerValue) {
            case 1:
                //printf("%f ", self.decimalVal);
                [[(ControlPanel*)[self superview] controlPanelAU] setPickupPosition:self.decimalVal];
                [[(ControlPanel*)[self superview] controlPanelAU] updateDelayLineStructure];
                break;
            case 2:
                [[(ControlPanel*)[self superview] controlPanelAU] setPluckInputPosition:self.decimalVal];
                [[(ControlPanel*)[self superview] controlPanelAU] updateDelayLineStructure];
                break;
            case 3:
                [[(ControlPanel*)[self superview] controlPanelAU] setAmp:self.decimalVal];
                [[(ControlPanel*)[self superview] controlPanelAU] updateDelayLineStructure];
                break;
            default:
                break;
        }
        
        textField.text =  [NSString stringWithFormat:@"%d", value];
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
