//
//  FXButton.h
//  EffectButton
//
//  Created by Ness on 8/22/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef enum : NSUInteger{
    RED,
    BLUE,
    YELLOW,
    GREEN
    
}buttonColor;

@class AudioController;
@interface AudioController
-(void)distortionEffect;
-(void)delayEffect;
@end
@interface FXButton : UIControl{
    //-- Global geometry
    CGFloat W;
    CGFloat H;
    BOOL active;
    CAGradientLayer *gradLayer;
    UITextField *effectDescription;
    
    
    NSString *buttonName;

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


@property IBOutlet AudioController *AUFx;

@end
