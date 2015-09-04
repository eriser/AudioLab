//
//  LightupButton.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/4/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface LightupButton : UIView{
    //-- Global geometry
    CGFloat W;
    CGFloat H;
    BOOL active;
    CAGradientLayer *gradLayer;
    UITextField *effectDescription;
       
    
    CGColorRef activeColor1;
    CGColorRef activeColor2;
    NSArray *activeColorArray;
    
    NSNumber *activeLoc1;
    NSNumber *activeLoc2;
    NSArray *activeLocs;
    
    
    ///Gradient settings for Disable state
    CGColorRef disableColor1;
    CGColorRef disableColor2;
    NSArray *disableColorArray;
    
    NSNumber *disableLoc1;
    NSNumber *disableLoc2;
    NSArray *disableLocs;
}

@property UIColor* innerColor;
@property NSString *buttonName;


@end
