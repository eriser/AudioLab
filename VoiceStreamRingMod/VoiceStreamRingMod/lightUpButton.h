//
//  lightUpButton.h
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"
@class AudioTrack;
@interface AudioTrack
-(void)activateLoop;
@end

//@class AudioController;
//@interface AudioController
//-(void)testFromAudioController;
//-(void)play;
//-(void)stop;
//@end

@interface lightUpButton : UIControl{
    //-- Global geometry
    CGFloat W;
    CGFloat H;
    BOOL active;
    
    //-- Layers and text
    CAGradientLayer *gradLayer;
    UITextField *effectDescription;
    
    
    NSString *buttonName;
    
    //-- Colors for active/inactive state and
    CGColorRef activeColor1;
    CGColorRef activeColor2;
    NSArray *activeColorArray;
    
    NSNumber *activeLoc1;
    NSNumber *activeLoc2;
    NSArray *activeLocs;
    
    CGColorRef disableColor1;
    CGColorRef disableColor2;
    NSArray *disableColorArray;
    
    NSNumber *disableLoc1;
    NSNumber *disableLoc2;
    NSArray *disableLocs;
}

@property IBOutlet AudioController *au;
@property IBOutlet AudioTrack *auTrack;
//-- Properties to be set at interface builder
@property UIColor* innerColor;
@property NSString* message;
@end
