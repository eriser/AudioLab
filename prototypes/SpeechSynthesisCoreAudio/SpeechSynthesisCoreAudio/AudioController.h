//
//  AudioController.h
//  SpeechSynthesisCoreAudio
//
//  Created by Ness on 1/7/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <ApplicationServices/ApplicationServices.h>

//User data struct to contain core audio objects
typedef struct MyAUGraphPlayer{
    AUGraph graph;
    AudioUnit speechAU;
}SpeechStruct;

@interface AudioController : NSObject
@property SpeechStruct *speechGraph;
@property Boolean isRunning;
@property NSTimer *myTimer;

-(void)setMessage:(NSString *)messageFromField;
-(void)play;
-(void)play_reverb;
-(void)stop;

@end
