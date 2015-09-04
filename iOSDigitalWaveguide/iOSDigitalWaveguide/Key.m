//
//  Key.m
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "Key.h"
////-- Foward declaration of AudioController
@class AudioController;
@interface AudioController
-(void)play:(short)freqIndex;
-(void)stop;
@end

////-- Foward declaration of AudioTrack
@class AudioTrack;
@interface AudioTrack
-(void)activateLoop;
-(void)deactivateLoop;
@property NSTimer *timer;
-(void)resetGraph;
@end

@class Keyboard;
@interface Keyboard
@property AudioController *keyboardAU;
@property AudioTrack *keyboardAUTrack;
@end




////-- Foward declaration of Control Panel
@class ControlPanel;
@interface ControlPanel
@property AudioTrack *auTrackControlPanel;
@end

@implementation Key
@synthesize identifier,keyColor;

//@synthesize autra;
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        ////--- This keyboard will have  green Aqua colors
        self.backgroundColor=[UIColor clearColor];
        color=[UIColor colorWithRed:53/255.0f green:229/255.0f blue:213/255.0f alpha:0.9];
        transparentColor=[UIColor colorWithRed:53/255.0f green:229/255.0f blue:213/255.0f alpha:0.3];
        borderColor=[UIColor colorWithRed:45/255.0f green:195/255.0f blue:181/255.0f alpha:1.0];
        darkColor=[UIColor colorWithRed:9/255.0f green:27/255.0f blue:26/255.0f alpha:1.0];
    }
    return self;
}


-(void)setTransparentKey{
    
    self.layer.backgroundColor=transparentColor.CGColor;
    self.layer.borderColor=borderColor.CGColor;
    self.layer.borderWidth=3.0;
    self.layer.cornerRadius=10.0;
    
}
-(void)setLightKey{
    self.layer.backgroundColor=color.CGColor;
    self.layer.borderColor=borderColor.CGColor;
    self.layer.borderWidth=3.0;
    self.layer.cornerRadius=10.0;
}
-(void)setDarkKey{
    self.layer.backgroundColor=darkColor.CGColor;
    self.layer.borderColor=borderColor.CGColor;
    self.layer.borderWidth=3.0;
    self.layer.cornerRadius=10.0;
    
    //shadow
    self.layer.shadowColor=[UIColor blackColor].CGColor;
    self.layer.shadowRadius=3.0;
    self.layer.shadowOpacity=1.0;
    
}

#pragma mark Note ON/OFF events
////--- Handling Touch Events
-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    
        int keyId= identifier;
        printf("%i ",keyId );
    
    Keyboard* kb=(Keyboard*) [self superview];
    AudioController *au=[kb keyboardAU];
    [au play:identifier-1];
    
    AudioTrack *auTrack=[kb keyboardAUTrack];
    [auTrack activateLoop];
}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    AudioController *au=  [(Keyboard*) [self superview] keyboardAU];
    [au stop];
    
    AudioTrack *auTrack=[(Keyboard*) [self superview] keyboardAUTrack];
    [auTrack deactivateLoop];
    [auTrack resetGraph];
}


@end
