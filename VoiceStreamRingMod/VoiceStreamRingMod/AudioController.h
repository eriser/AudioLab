//
//  AudioController.h
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>
#include "RingBuffer.h"
#include <pthread.h>

typedef struct {
    AudioUnit rioUnit;               //In iOS input/output device is embedded in one
    AudioStreamBasicDescription asbd;
    float sineFrequency;
    float sinePhase;
    pthread_mutex_t mutex;
    RingBuffer *rb;
    int dataAvailable;
    
} RobotVoiceStruct;


@interface AudioController : NSObject

//-- Interface communication with core Audio
@property RobotVoiceStruct robotEffect;//THIS DOESNTWORK WHEN IT IS A POINTER....
-(void)initAudioUnit;
-(void)play;
-(void)stop;
-(void)setFrequency:(float)freq;

//-- Tools for live plot the audio track
-(float*)readBuffer;
@property int dataLength;
//Test method
-(void)testFromAudioController;

@end
