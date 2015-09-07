//
//  KeyView.m
//  PianoKeyboard
//
//  Created by Ness on 8/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "KeyView.h"
#import "KeyLayer.h"

/*  Foward declaration of the receiver class:
 This class will handle the touch events comming from the keys.
 In this case, the keyboard will handle this events.
 Keyboard is also designed to contain other modulation input controls:
 Pitch and distortion benders
 */
@class AudioController;
@interface AudioController
-(void)testFromAudioController:(int)MIDIKey;
-(void)play:(short)freqIndex;
-(void)stop;
@end

@class keyboard;
@interface keyboard
-(void)test;
@property AudioController *AUKeyboard;
@end



@implementation KeyView
@synthesize identifier;


+(Class)layerClass{
    return [KeyLayer class];
}

#pragma mark Touch Methods Override

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{

    int keyId= identifier;
    printf("%i ",keyId );
    
    keyboard* kb=(keyboard*) [self superview];
    AudioController *AUKeyboard=[kb AUKeyboard];
    [AUKeyboard play:identifier-1];

}

-(void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event{
    AudioController *AUKeyboard=  [(keyboard*) [self superview] AUKeyboard];
    [AUKeyboard stop];
}

#pragma mark Utility Methods

-(void)setAsBlack:(BOOL)black{
    if (black) {
        ((KeyLayer*)self.layer).isBlack=YES;
    }else{
        ((KeyLayer*)self.layer).isBlack=NO;
    }
}

@end
