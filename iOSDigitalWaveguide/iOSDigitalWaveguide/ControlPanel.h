//
//  ControlPanel.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundControlSlider.h"


///-- Foward declaration of AudioController class
@class AudioController;


@interface ControlPanel : UIImageView{
    ///-- Global Geometry

    CGFloat W;
    CGFloat H;
    CGPoint startCenter;
    
    ///-- Control Panel Variables
    
    UIColor *ringColor;
    UIColor *ringColorTransparent;
    UIColor *innerRing;
    UIColor *backgroundColor;
    UIColor * backgoundColorTransparent;
    CAGradientLayer *gradLayer;
    
    
}

@property RoundControlSlider *r1;
@property RoundControlSlider *r2;
@property RoundControlSlider *r3;

///-- An AudioController instance will be present at in Runtime
@property IBOutlet AudioController *controlPanelAU;

@end
