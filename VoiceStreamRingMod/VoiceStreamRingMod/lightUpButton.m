//
//  lightUpButton.m
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "lightUpButton.h"

@implementation lightUpButton
@synthesize message,innerColor;
@synthesize au,auTrack;

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        
        
        ////-- Global variables and geometry
        
      
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        //-- Main view background color
        self.backgroundColor=[UIColor clearColor];
        //-- Container Layer settings
        //self.layer.borderWidth=1.0;
        //self.layer.cornerRadius=20.0;
        active=NO;

        ////-- Colors and Positions for gradient Layer
        

        //-- Active  state Locations
        activeLoc1= [[NSNumber alloc]initWithFloat:0.0];
        activeLoc2= [[NSNumber alloc]initWithFloat:0.7];
        activeLocs=[[NSArray alloc]initWithObjects:activeLoc1,activeLoc2, nil];
        //-- Disabled Color state
        disableColor1=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.5].CGColor;
        disableColor2=[UIColor colorWithRed:0/255.0f green:0/255.0f blue:0/255.0f alpha:0.9].CGColor;
        disableColorArray=[[NSArray alloc]initWithObjects:(__bridge id)(disableColor1),(__bridge id)disableColor2,nil];
        //-- Disabled  state Locations
        disableLoc1=[[NSNumber alloc]initWithFloat:0.0];
        disableLoc2=[[NSNumber alloc]initWithFloat:0.5];
        disableLocs=[[NSArray alloc]initWithObjects:disableLoc1,disableLoc2, nil];
        
        
        
        ////-- Initial some settings for gradient layer
        
        
        
        gradLayer= [[CAGradientLayer alloc]init];
        gradLayer.frame=CGRectInset(self.bounds, 15, 15);
        gradLayer.cornerRadius=20;
        gradLayer.borderWidth=2.0;
        gradLayer.startPoint=CGPointMake(0, 0);
        gradLayer.endPoint=CGPointMake(1,1);
        gradLayer.shadowOpacity=1.0;
        [self.layer addSublayer:gradLayer];
        
        
    
        ////--- Create a font for display message, and get its size
        
        
        UIFont *font=[UIFont fontWithName:@"Futura-CondensedExtraBold" size:18];
        NSString *str=@"D I S T O R T I O N";
        NSDictionary *attributes = [[NSDictionary alloc]initWithObjectsAndKeys:font,NSFontAttributeName, nil];
        CGSize fontSize= [str sizeWithAttributes:attributes];
        
        effectDescription=[[UITextField alloc]initWithFrame:CGRectMake((W/2)-fontSize.width/2,(H/2)-fontSize.height,
                                                                       fontSize.width , fontSize.height)];
        effectDescription.font=font;
        //effectDescription.textColor=[UIColor orangeColor];
        
        effectDescription.enabled=NO;
        [self addSubview:effectDescription];
        active=FALSE;
    }
    return self;
}


////-- Set the properties comming from interface builder

-(void)setValue:(id)value forKeyPath:(NSString *)keyPath{
    if ([keyPath isEqual:@"innerColor"]) {
        
        
        ////-- With the inner color introduced, set the active color of button
        
        
        innerColor=value;
        const CGFloat *components=CGColorGetComponents(innerColor.CGColor);
        CGFloat redComponent=components[0];
        CGFloat greenComponent=components[1];
        CGFloat blueComponent=components[2];
        CGFloat alphaComponent=0.5;
        activeColor1=([UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent]).CGColor;
        redComponent=components[0];
        greenComponent=components[1];
        blueComponent=components[2];
        alphaComponent=0.2;
        activeColor2=([UIColor colorWithRed:redComponent green:greenComponent blue:blueComponent alpha:alphaComponent]).CGColor;;
        activeColorArray=[[NSArray alloc]initWithObjects:(__bridge id)(activeColor1),(__bridge id)activeColor2,nil];
        
    }
    
    if ([keyPath isEqual:@"message"]) {
        
        ////-- With the message introduced, set the title of the button
        
        message=value;
        effectDescription.text=message;
        effectDescription.textAlignment=NSTextAlignmentCenter;
    }
    if ([keyPath isEqual:@"au"]) {
        NSLog(@"audioController loaded from IB");
        au=value;
    }
    
    if ([keyPath isEqual:@"auTrack"]) {
        NSLog(@"audioTrack loaded from IB");
        auTrack=value;
    }
}


- (void)drawRect:(CGRect)rect {
    //-- Initial border colors
    self.layer.borderColor=innerColor.CGColor;
    gradLayer.borderColor=innerColor.CGColor;
    effectDescription.textColor=innerColor;
   
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    [au testFromAudioController];
    
    if (!active) {
        gradLayer.shadowColor=innerColor.CGColor;
        gradLayer.shadowOpacity=4.0;
        gradLayer.colors=activeColorArray;
        gradLayer.locations=activeLocs;
        effectDescription.textColor=[UIColor blackColor];
        active=YES;
        
        [au play];
        [auTrack activateLoop];
        
    }else{
        [auTrack deactivateLoop];
        gradLayer.shadowOpacity=0.0;
        gradLayer.colors=disableColorArray;
        gradLayer.locations=disableLocs;
        effectDescription.textColor=innerColor;
        active=NO;
        [au stop];
    }

}
@end
