//
//  AudioController.h
//  AudioSynth
//
//  Created by Ness on 9/4/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface AudioController : NSObject

///-- Audio Unit Set Up and Audio Stream Controls
-(void)initAudioUnit;
-(void)play:(short)freqIndex;
-(void)stop;


////--- Pitch Oscillators Wave Settings

-(void)updateWave:(short)waveIndex forOscillator:(int)number;
-(void)updateSquareCycleDuty:(CGFloat)duty forOscillator:(int )number;
-(void)setDetuneAmount:(double)range forOscillator:(int)number;

////--- LFO Oscillators Settings

-(void)setLFOfrequency:(double)range forOscillator:(int)number;
-(void)updateLFOWave:(short)waveIndex forOscillator:(int)number;
-(void)updateLFOSquareCycleDuty:(CGFloat)duty forOscillator:(int )number;

-(void)setOffModeFor:(int)oscillator;
-(void)setShotModeFor:(int)oscillator;
-(void)setSyncModeFor:(int)oscillator;


////--- Envelope Setup Times
-(void) setAttackTime:(double)seconds;
-(void) setDecayTime:(double)seconds;
-(void) setReleaseTIme:(double)seconds;
-(void) setSustainLevel:(double)level;

////--- Filter Type Setup
-(void)setFilterType:(NSInteger)filterType;
-(void)setFilterFrequencyCut:(double)range;
-(void)setFilterLFOFrequency:(double)range;


////--- Sound Effect Functions
-(void)distortionEffect;
-(void)delayEffect;
@end
