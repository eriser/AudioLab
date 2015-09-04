//
//  AudioController.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>
#import <AVFoundation/AVFoundation.h>


@interface AudioController : NSObject

///-- Audio Unit setUp and Audio Stream Controls
-(void)initAudioUnit;
-(void)play:(short)freqIndex;
-(void)stop;

//-- Algorithm Input Variables
-(void)setFrequency:(int)frequencyIndex;
-(void)setPickupPosition:(double)position;
-(void)setPluckInputPosition:(double)position;
-(void)setAmp:(double)value;
-(void)updateDelayLineStructure;

//-- Audio Effects
-(void)setDistortionON;
-(void)setDistortionOFF;
-(void)setDelayON;
-(void)setDelayOFF;
-(void)setFilterON;
-(void)setFilterOFF;

//-- For live graph
-(float*)readBuffer;
-(void)setDrawingTo:(BOOL)isDrawing;
@property int dataLength;
@end
