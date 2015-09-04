//
//  RoundLightupButton.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/4/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
@class  AudioController;
@interface AudioController

//-- Some basic audio effects for testing conexions
-(void)setDistortionON;
-(void)setDistortionOFF;
-(void)setDelayON;
-(void)setDelayOFF;
-(void)setFilterON;
-(void)setFilterOFF;
@end

@interface RoundLightupButton : UIView{
    ///-- Global Geometry
    CGFloat W;
    CGFloat H;
    CGPoint startCenter;
    
    ///-- FLoat containers for button Color
    CGFloat redComponent;
    CGFloat greenComponent;
    CGFloat blueComponent;
    CGFloat alphaComponent;
    
    ///-- Textfield for button description
    UITextField *effectDescription;
    
    ///-- Logic state of button
    BOOL active;
}

///-- Properties from Interface Builder
@property UIColor *color;
@property NSString *buttonName;
@property NSNumber *identifier;

@property IBOutlet AudioController *AU_effects;

@end
