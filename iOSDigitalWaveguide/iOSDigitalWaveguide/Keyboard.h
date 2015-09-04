//
//  Keyboard.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>

////-- Foward declaration of AudioController
@class AudioController;

////-- Foward declaration of AudioTrack
@class AudioTrack;





@interface Keyboard : UIView{
    CAGradientLayer *gradLayer;
    UIColor *backgroundColorLight;
    UIColor * backgoundColorDark;
    
    CGFloat W;
    CGFloat H;
    CGFloat whiteKey_Width;
    CGFloat whiteKey_Height;
    CGFloat blackKey_Width;
    CGFloat blackKey_Height;
}

//-- AudioController runtime instance
@property IBOutlet  AudioController *keyboardAU;
@property IBOutlet AudioTrack *keyboardAUTrack;
@end
