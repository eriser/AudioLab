//
//  FXButton.m
//  EffectButton
//
//  Created by Ness on 8/22/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "FXButton.h"

@interface FXButton()
@property UIColor* innerColor;
@property NSString* message;
@end

@implementation FXButton
@synthesize innerColor, message,AUFx;


-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {

        
        //-- Global geometry
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        
        //-- Main view background color
        self.backgroundColor=[UIColor clearColor];
        
        //-- Container Layer settings
        self.layer.cornerRadius=20;
        self.layer.borderWidth=5.0;
        

        
        
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
        
        

        //-- Initial settings of gradient layer
        gradLayer= [[CAGradientLayer alloc]init];
        gradLayer.frame=CGRectInset(self.bounds, 1, 1);
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


-(void)setValue:(id)value forKeyPath:(NSString *)keyPath{
    if ([keyPath isEqual:@"innerColor"]) {
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
        NSLog(@"flag");
        message=value;
        effectDescription.text=message;
        effectDescription.textAlignment=NSTextAlignmentCenter;
    }
    
    if ([keyPath isEqual:@"AUFx"]) {
        AUFx=value;
    }
}
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
    if (!active) {
        gradLayer.shadowColor=innerColor.CGColor;
        gradLayer.shadowOpacity=4.0;
        gradLayer.colors=activeColorArray;
        gradLayer.locations=activeLocs;
        effectDescription.textColor=[UIColor blackColor];
        active=YES;
        
        if ([message isEqual:@"DISTORTION"]) {
            [AUFx distortionEffect];
        }
        if ([message isEqual:@"DELAY"]) {
            [AUFx delayEffect];
        }
        
    }else{
        gradLayer.shadowOpacity=0.0;
        gradLayer.colors=disableColorArray;
        gradLayer.locations=disableLocs;
        effectDescription.textColor=innerColor;
        active=NO;
        if ([message isEqual:@"DISTORTION"]) {
            [AUFx distortionEffect];
        }
        if ([message isEqual:@"DELAY"]) {
            [AUFx delayEffect];
        }
    }
    
}
-(void)drawRect:(CGRect)rect{
    
    //-- Initial border colors
    self.layer.borderColor=innerColor.CGColor;
    gradLayer.borderColor=innerColor.CGColor;
    effectDescription.textColor=innerColor;
}
@end
