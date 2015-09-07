//
//  LFOModeButton.h
//  AudioSynth
//
//  Created by Ness on 9/7/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>

////-- Foward declaration of AudioController
@class AudioController;
@interface AudioController
-(void)setOffModeFor:(int)oscillator;
-(void)setShotModeFor:(int)oscillator;
-(void)setSyncModeFor:(int)oscillator;
@end
@interface LFOModeButton : UIControl{
    //-- Global geometry
    CGFloat W;
    CGFloat H;
    CGFloat X;
    CGFloat Y;
    
    CGFloat WLightIndicator;
    CGFloat HLightIndicator;
    CGRect lightIndicator;
    CGPoint lightIndicatorCenter;
    
    //-- Current button state
    int state;
    
    UILabel *description;
    
    //-- Components for color state1
    CGFloat redComponent;
    CGFloat greenComponent;
    CGFloat blueComponent;
    CGFloat alphaComponent;

    //-- Components for color state2
    CGFloat redComponent2;
    CGFloat greenComponent2;
    CGFloat blueComponent2;
    CGFloat alphaComponent2;
    

    
}

@property UIColor* colorState1;
@property UIColor* colorState2;
@property NSString* message;
@property NSNumber *identifier;
@property IBOutlet AudioController *AULFOModeButton;
@end
