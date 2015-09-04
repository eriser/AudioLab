//
//  AudioController.m
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "AudioController.h"

#include "DigitalWaveGuide.h"
#include "EnvelopeGenerator.h"
#include "Distortion.h"
#include "Delay.h"
#include "RingBuffer.c"
#include <pthread.h>


#pragma mark Custom User Audio Struct
////---  Required elements to perform digital waveguide in CoreAudio
typedef struct _waveGuide{
    //-- Core Audio Elements
    AudioUnit                       rioUnit;    //Default AU for input/output
    AudioStreamBasicDescription     asbd;       //Format description
    
    //-- C++ Audio Elements
    DigitalWaveGuide   synthesizer;            //implements digital waveguide algorithm
    CEnvelopeGenerator envelope;
    Distortion distortion;
    Delay delay;
    //-- Audio Effect Locks
    bool b_distortion;
    bool b_delay;
    
    //-- Audio Track Elements
    RingBuffer *rb;
    pthread_mutex_t mutex;
    bool drawing;
}WaveGuide;


#pragma mark Audio Callback Render Function
////--- Callback function for audio rendering
static OSStatus DigitalWaveGuideCallback( void *							inRefCon,
                                         AudioUnitRenderActionFlags *	ioActionFlags,
                                         const AudioTimeStamp *			inTimeStamp,
                                         UInt32							inBusNumber,
                                         UInt32							inNumberFrames,
                                         AudioBufferList *				ioData){
    WaveGuide *sData=(WaveGuide *)inRefCon;
    double dOut=0.0;
    float fdOut=0.0;
    //double dEnv=0.0;
        for (int frame = 0; frame < inNumberFrames; ++frame)
        {
            Float32 *data = (Float32*)ioData->mBuffers[0].mData;
            if (sData->synthesizer.m_bNoteOn) {
    //
                dOut=(Float32)sData->synthesizer.doOscillate();
    //
                //Distortion
                if(sData->b_distortion){
                    dOut=sData->distortion.doDistortion(dOut);
                }
    //
    //
                //Delay
                if (sData->b_delay)
                    dOut=sData->delay.doSimpleReverb(dOut);
    //
    //
    //            if(sData->filterFX)
    //                dOut=sData->m_filter.doFilter(dOut);
    //
                double dEGOut = sData->envelope.doEnvelope();
                dOut *=dEGOut;
    //
    //
    //
                //-- Write to ring buffer, AudioTrack will read it when possible
                if (sData->envelope.getState()!=4) {   //if note is not released
                    if (sData->drawing) {
                        pthread_mutex_lock(&(sData->mutex));
                        fdOut=(float)dOut;
                        RingBuffer_write(sData->rb, &fdOut, 1);
                        pthread_mutex_unlock(&(sData->mutex));
                    }
    
                }
    
                if(sData->envelope.getState() == 0){ // off
                    sData->synthesizer.stopOscillator();
                }
            }
    //        
    //        
            (data)[frame]=dOut;
    //        
    //        
        }
    
    
    return noErr;
}



#pragma mark Private Members
@interface AudioController()
@property WaveGuide waveguide;
@end

@implementation AudioController
@synthesize waveguide,dataLength;

#pragma mark Initializations
///-- Init override
-(instancetype)init{
    self=[super init];
    if (self) {
        NSLog(@"init method");
        dataLength=0;
        [self initAudioUnit];
    }
    return self;
}



///-- Initialization of C++ Elements From Custom User Audio Struct
-(void)initCustomUserAudioStruct{
    
    //-- Digital Wave Guide
    waveguide.synthesizer.amp=1.0;
    waveguide.synthesizer.pitch=150;
    waveguide.synthesizer.pick=0.2;
    waveguide.synthesizer.pickup=0.8;
    waveguide.synthesizer.duration=12.0;
    waveguide.synthesizer.m_bNoteOn=false;
    
    //-- Envelope Generator
    waveguide.envelope.m_uEGMode=CEnvelopeGenerator::analog;
    
    //-- Audio Effects
    //    waveguide.m_filter.m_uFilterType=CFilter::LPF1;
    //    waveguide.m_filter.setSampleRate(44100);
    //    waveguide.m_filter.m_dFcControl=300;
    //    waveguide.m_filter.m_dQControl=1.0;
    //    waveguide.m_filter.update();

    //    waveguide.synthesizer.update();
    //
    //-- Effects Locks
    waveguide.b_distortion=false;
    waveguide.b_delay=false;
    //    waveguide.delayFX=false;
    //    waveguide.filterFX=false;

    //    //-- Filter
    
    //-- Audio Track
    waveguide.rb=RingBuffer_create(512*10);
    pthread_mutex_init(&(waveguide.mutex), NULL);
    waveguide.drawing=false;
}


-(void)initAudioUnit{


    ////--- SETUP AUDIO SESSION
    AVAudioSession *session=[AVAudioSession sharedInstance];
    NSError *e;
    BOOL success=[session setCategory:AVAudioSessionCategoryPlayAndRecord error:&e];
    if (!success) { NSLog(@"There was an error setting up the audio session and category");}
    else{NSLog(@"AudioSession and category set sucessfully");}
    
    //-- Get sample rate
    double sessionSampleRate=session.sampleRate;
    NSLog(@"sample rate %f",sessionSampleRate);
    
    
    ////--- SETUP AUDIO UNIT
    //-- Describe audio unit
    AudioComponentDescription audioCompDesc;
    audioCompDesc.componentType = kAudioUnitType_Output;
    audioCompDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    audioCompDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioCompDesc.componentFlags = 0;
    audioCompDesc.componentFlagsMask = 0;
    
    //-- Get rio unit from audio component manager
    AudioComponent rioComponent = AudioComponentFindNext(NULL, &audioCompDesc);
    @try {AudioComponentInstanceNew(rioComponent, &waveguide.rioUnit);}
    @catch (NSException *e) {
        NSLog(@"Couldn't get RIO unit instance, Exception: %@",e);
    }
    
    //-- Configure Audio Unit: Enable output, disable input
    UInt32 oneFlag = 1;
    UInt32 zeroFlag = 0;
    AudioUnitElement bus0 = 0;
    AudioUnitElement bus1 = 1;
    
    @try {AudioUnitSetProperty(waveguide.rioUnit,
                               kAudioOutputUnitProperty_EnableIO,
                               kAudioUnitScope_Output,
                               bus0,
                               &oneFlag,
                               sizeof(oneFlag));
    }
    @catch (NSException *e) {
        NSLog(@"Couldn't enable RIO output, Exception: %@",e);
    }
    
    @try {AudioUnitSetProperty (waveguide.rioUnit,
                                kAudioOutputUnitProperty_EnableIO,
                                kAudioUnitScope_Input,
                                bus1,
                                &zeroFlag,
                                sizeof(zeroFlag));
    }
    @catch (NSException *e) {
        NSLog(@"Couldn't disable RIO output, Exception: %@",e);
    }
    //-- Construct Format: Audio Stream Basic Description
    AudioStreamBasicDescription myASBD;
    memset(&myASBD, 0, sizeof(myASBD));
    Float64 sampleRate=(Float64)sessionSampleRate;
    myASBD.mSampleRate=sampleRate;
    myASBD.mFormatID = kAudioFormatLinearPCM;
    myASBD.mFormatFlags = kAudioFormatFlagsNativeFloatPacked;
    myASBD.mBytesPerPacket = 4;
    myASBD.mFramesPerPacket = 1;
    myASBD.mBytesPerFrame = 4;
    myASBD.mChannelsPerFrame = 1;
    myASBD.mBitsPerChannel = 32;
    
    //-- Set recently created format: myASBD, as the output(bus0) format
    @try {AudioUnitSetProperty (waveguide.rioUnit,
                                kAudioUnitProperty_StreamFormat,
                                kAudioUnitScope_Input,
                                bus0,
                                &myASBD,
                                sizeof (myASBD));
    }@catch (NSException *e) {
        NSLog(@"Couldn't set ASBD for RIO on input scope / bus 0, Exception: %@",e);
    }
    
    
    //--Set render callback
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = DigitalWaveGuideCallback;
    callbackStruct.inputProcRefCon = &waveguide;
    @try {AudioUnitSetProperty(waveguide.rioUnit,
                               kAudioUnitProperty_SetRenderCallback,
                               kAudioUnitScope_Input,
                               bus0,
                               &callbackStruct,
                               sizeof (callbackStruct));
    }@catch (NSException *e) {
        NSLog(@"Couldn't set RIO render callback on bus 0, Exception: %@",e);
    }
    
    ////--- Define default values for the parameters in the audio struct
    
    waveguide.asbd=myASBD;
    [self initCustomUserAudioStruct];
    
    
    ////-- Boot Audio unit
    
    @try {AudioUnitInitialize(waveguide.rioUnit);}
    @catch (NSException *e) {NSLog(@"Couldn't initialize RIO unit, Exception: %@",e);
    }printf("RIO Initialized\n");
    
    
    ////-- Start Audio Unit
    
    
    @try {AudioOutputUnitStart(waveguide.rioUnit);
    }@catch (NSException *e) {NSLog(@"Couldn't Start RIO unit, Exception: %@",e);
    }printf("RIO Started\n");
    
    
}


#pragma mark Audio Stream Controls

-(void)play:(short)freqIndex{
    [self setFrequency:freqIndex];
    [self updateDelayLineStructure];
    waveguide.synthesizer.startOscillator();
    waveguide.envelope.startEG();
}

-(void)stop{
    waveguide.envelope.noteOff();
}

#pragma mark Digital Waveguide Input Controls
-(void)setFrequency:(int)frequencyIndex{
    waveguide.synthesizer.pitch=frequencyTable_waveguide[frequencyIndex];
    waveguide.synthesizer.update();
}
-(void)setPickupPosition:(double)position{
    waveguide.synthesizer.pickup=position;
    waveguide.synthesizer.update();
}
-(void)setPluckInputPosition:(double)position{
    waveguide.synthesizer.pick=position;
    waveguide.synthesizer.update();
}
-(void)setAmp:(double)value{
    waveguide.synthesizer.amp=value;
    waveguide.synthesizer.update();
    printf("%f ",value);
}
-(void)updateDelayLineStructure{
    waveguide.synthesizer.update();
    //    waveguide.pickupSample=(waveguide.synthesizer).initString(waveguide.amp, waveguide.pitch, waveguide.pick, waveguide.pickup);
    //printf("pick:%f  pickup:%f amp:%f \n",pick, pickup, amplitude);
}

#pragma mark Audio Effects

-(void)setDistortionON{
    waveguide.b_distortion=true;
}
-(void)setDistortionOFF{
    waveguide.b_distortion=false;
}


-(void)setDelayON{
    waveguide.b_delay=true;
}
-(void)setDelayOFF{
    waveguide.b_delay=false;
}


#pragma mark Audio Track
-(float *)readBuffer{
    pthread_mutex_lock(&(waveguide.mutex));
    dataLength=getAvailableData(self.waveguide.rb);
    //printf("%d ",dataLength);
    float *data=(float*)calloc(dataLength, sizeof(float));
    if(data!=nullptr)
        RingBuffer_read(self.waveguide.rb, data, getAvailableData(self.waveguide.rb));
    pthread_mutex_unlock(&(waveguide.mutex));
    
    return data;
}


-(void)setDrawingTo:(BOOL)isDrawing{
    waveguide.drawing=isDrawing;
    if (!isDrawing) {
        free(waveguide.rb);
        waveguide.rb=RingBuffer_create(512*10);
    }
    
}

@end
