//
//  AudioController.m
//  AudioSynth
//
//  Created by Ness on 9/4/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "AudioController.h"

#import "CQBLimitedOscillator.h"
#import "LFO.h"
#import "EnvelopeGenerator.h"
#import "VAOnePoleFilter.h"
#import "Distortion.h"
#import "Delay.h"

#pragma mark Custom User Audio Struct
/************************************************
 CUSTOM USER DATA STRUCTURE:
 This structure contains the core of the audio app
 All the methods implemented here are a mere interface
 between the GUI and the struct below
 ************************************************/
typedef struct{
    //-- Core Audio Elements
    AudioUnit rioUnit;
    AudioStreamBasicDescription asbd;
    
    //-- C++ Audio Elements
    //-- 2 pitched Oscillators with and 2 LFO
    CQBLimitedOscillator m_Osc1;
    CLFO                 m_Osc1_LFO;
    CQBLimitedOscillator m_Osc2;
    CLFO                 m_Osc2_LFO;
    
    //-- 1 Envelope
    CEnvelopeGenerator  m_EG1;
    
    //-- Filters
    CVAOnePoleFilter m_Filter1;
    CLFO             m_Filter1_LFO;

    //-- Audio Effects
    Distortion m_distortion;
    Delay m_delay;
    
    //-- Locks
    bool b_distortion;
    bool b_delay;
    
    
    bool b_Osc1LFO;
    bool b_Osc2LFO;
    bool b_Osc1LFO_pitchMod;
    bool b_Osc2LFO_pitchMod;
    bool b_Osc1LFO_phaseMod;
    bool b_Osc2LFO_phaseMod;
    
}SynthDataStruct;


#pragma mark Check Error Utility
////--- Utility function for checking errors when initializing the audio unit
static void CheckError(OSStatus error, const char *operation)
{
    if (error == noErr) return;
    
    char str[20];
    // see if it appears to be a 4-char-code
    *(UInt32 *)(str + 1) = CFSwapInt32HostToBig(error);
    if (isprint(str[1]) && isprint(str[2]) && isprint(str[3]) && isprint(str[4])) {
        str[0] = str[5] = '\'';
        str[6] = '\0';
    } else
        // no, format it as an integer
        sprintf(str, "%d", (int)error);
    
    fprintf(stderr, "Error: %s (%s)\n", operation, str);
    
    exit(1);
}
#pragma mark Audio Render Callback
static OSStatus SynthesisCallback( void *							inRefCon,
                                      AudioUnitRenderActionFlags *	ioActionFlags,
                                      const AudioTimeStamp *			inTimeStamp,
                                      UInt32							inBusNumber,
                                      UInt32							inNumberFrames,
                                      AudioBufferList *				ioData){
    
    
    /*************************************************
     THIS IS WHERE THE DSP IS DONE
     *************************************************/
    SynthDataStruct *sData = (SynthDataStruct*) inRefCon;
    double dOut=0.0;
    
    
    for (int frame = 0; frame < inNumberFrames; ++frame) {
        Float32 *data = (Float32*)ioData->mBuffers[0].mData;
        if(sData->m_Osc1.m_bNoteOn)
        {
            //-- Make all the oscillators To vibe


            double dLFO1Out=sData->m_Osc1_LFO.doOscillate();
            double dLFO2Out=sData->m_Osc2_LFO.doOscillate();
            double dLFO3Out=sData->m_Filter1_LFO.doOscillate();


            if (sData->b_Osc1LFO){
                sData->m_Osc1.setPitchBendMod(dLFO1Out);
                sData->m_Osc1.update();
            }
            if (sData->b_Osc2LFO) {
                sData->m_Osc2.setPitchBendMod(dLFO2Out);
                sData->m_Osc2.update();
            }
            
            
            
            double dOut1 = sData->m_Osc1.doOscillate();
            double dOut2 = sData->m_Osc2.doOscillate();
            dOut=0.5*(dOut1+dOut2);


            
            //-- Envelope
            double dEGOut = sData->m_EG1.doEnvelope();
            dOut *=dEGOut;
//            
//            
            //-- Filter
            sData->m_Filter1.setFcMod(dLFO3Out*FILTER_FC_MOD_RANGE);
            sData->m_Filter1.update();
            dOut = sData->m_Filter1.doFilter(dOut);
            
            
            
            if(sData->b_distortion)
                dOut= (sData->m_distortion.doDistortion(dOut))*0.5;
            

            if(sData->b_delay && sData->m_EG1.getState()!=0)// released
                if(sData->m_EG1.getDecayTime()>10)
                    dOut= (sData->m_delay.doSimpleDelay(dOut))/2.0;
            
            
            if(sData->m_EG1.getState() == 0) // off
            {
                
                sData->m_Osc1.stopOscillator();
                sData->m_Osc1_LFO.stopOscillator();
                
                
                sData->m_Osc2.stopOscillator();
                sData->m_Osc2_LFO.stopOscillator();
                sData->m_Filter1_LFO.stopOscillator();

                
                sData->m_EG1.reset();
                
                
            }
//
        }
        
        (data)[frame]= dOut;
    }
    return noErr;
}

#pragma mark Private
@interface AudioController()
@property SynthDataStruct synthState;
@end

#pragma mark Audio Controller Implementation
@implementation AudioController
@synthesize synthState;


#pragma mark Initialization Methods

-(instancetype)init{
    self=[super init];
    if(self){
        [self initAudioUnit];
    }
    return self;
}

///-- Initialization of C++ Elements From Custom User Audio Struct
-(void)initCustomUserAudioStruct{
    
    ////-- Oscillators
    synthState.m_Osc1.m_uWaveform=CQBLimitedOscillator::SINE;   //Default wave
    synthState.m_Osc2.m_uWaveform=CQBLimitedOscillator::SINE;
    synthState.m_Osc1_LFO.m_uWaveform=CLFO::sine;
    synthState.m_Osc1_LFO.m_dOscFo=0.0;
    synthState.m_Osc1_LFO.m_uLFOMode=COscillator::shot;
    synthState.m_Osc1_LFO.update();
    synthState.m_Osc2_LFO.m_uWaveform=CLFO::sine;
    synthState.m_Osc2_LFO.m_dOscFo=0.0;
    synthState.m_Osc2_LFO.m_uLFOMode=COscillator::shot;
    synthState.m_Osc2_LFO.update();
    

    ////-- Initialize the envelope in the analog mode
    synthState.m_EG1.m_uEGMode=CEnvelopeGenerator::analog;
    
    ////-- Initialize Filter
    synthState.m_Filter1.m_uFilterType=CFilter::LPF1;
    synthState.m_Filter1.setSampleRate(44100);
    synthState.m_Filter1.m_dFcControl=300;
    synthState.m_Filter1.m_dQControl=1.0;
    synthState.m_Filter1.setQControl(1.0);
    synthState.m_Filter1.update();
    
    synthState.m_Filter1_LFO.m_uWaveform=CLFO::sine;
    synthState.m_Filter1_LFO.m_dOscFo=0.0;
    synthState.m_Filter1_LFO.update();

    
    /////-- Initialize Locks
    synthState.b_distortion=false;
    synthState.b_delay=false;
    synthState.b_Osc1LFO=false;
    synthState.b_Osc2LFO=false;

}

-(void)initAudioUnit{
    NSLog(@"initAudioUnit: Initialization Routine");
    NSLog(@"Initialization of AudioUnit in process...");
    //SET UP AUDIO SESSION
    AVAudioSession *session=[AVAudioSession sharedInstance];
    
    NSError *e;
    BOOL success=[session setCategory:AVAudioSessionCategoryPlayAndRecord error:&e];
    if (!success) {
        NSLog(@"There was an error setting up the audio session and category");
    }else{
        NSLog(@"AudioSession and category set sucessfully");
    }
    
    //GET THE SAMPLE RATE
    double sessionSampleRate=session.sampleRate;
    NSLog(@"sample rate %f",sessionSampleRate);
    
    //<OPTIONAL> Set the sample rate
    //    double preferredSampleRate=44100;
    //    success=[session setPreferredSampleRate:preferredSampleRate error:&e];
    //    if (success) {
    //        NSLog (@"session.sampleRate = %f", session.sampleRate);
    //    } else {
    //        NSLog (@"error setting sample rate %@", e);
    //    }
    
    //GET THE RIO UNIT
    // describe unit
    AudioComponentDescription audioCompDesc;
    audioCompDesc.componentType = kAudioUnitType_Output;
    audioCompDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    audioCompDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioCompDesc.componentFlags = 0;
    audioCompDesc.componentFlagsMask = 0;
    
    // get rio unit from audio component manager
    AudioComponent rioComponent = AudioComponentFindNext(NULL, &audioCompDesc);
    CheckError(AudioComponentInstanceNew(rioComponent, &synthState.rioUnit),
               "Couldn't get RIO unit instance");
    
    //CONFIGURE RIO UNIT
    UInt32 oneFlag = 1;
    UInt32 zeroFlag = 0;
    AudioUnitElement bus0 = 0;
    AudioUnitElement bus1 = 1;
    
    //enable output
    CheckError(AudioUnitSetProperty(synthState.rioUnit,
                                    kAudioOutputUnitProperty_EnableIO,
                                    kAudioUnitScope_Output,
                                    bus0,
                                    &oneFlag,
                                    sizeof(oneFlag)),
               "Couldn't enable RIO output");
    
    // Disable input
    CheckError(AudioUnitSetProperty (synthState.rioUnit,
                                     kAudioOutputUnitProperty_EnableIO,
                                     kAudioUnitScope_Input,
                                     bus1,
                                     &zeroFlag,
                                     sizeof(zeroFlag)),
               "Couldn't disable RIO input");
    
    // SET UP FORMAT
    
    //create format
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
    
    
    /*
     // set format for output (bus 0) on rio's input scope
     */
    CheckError(AudioUnitSetProperty (synthState.rioUnit,
                                     kAudioUnitProperty_StreamFormat,
                                     kAudioUnitScope_Input,
                                     bus0,
                                     &myASBD,
                                     sizeof (myASBD)),
               "Couldn't set ASBD for RIO on input scope / bus 0");
    
    
    //SET RENDER CALLBACK
    //complete some parameters
    synthState.asbd=myASBD;
    
    
    
    //set callback method
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = SynthesisCallback;
    callbackStruct.inputProcRefCon = &synthState;
    
    CheckError(AudioUnitSetProperty(synthState.rioUnit,
                                    kAudioUnitProperty_SetRenderCallback,
                                    kAudioUnitScope_Input,
                                    bus0,
                                    &callbackStruct,
                                    sizeof (callbackStruct)),
               "Couldn't set RIO render callback on bus 0");
    
    //Initialize the synth struct
    [self initCustomUserAudioStruct];
    
    CheckError(AudioUnitInitialize(synthState.rioUnit),
               "Couldn't initialize RIO unit");
    
    printf("RIO Initialized\n");
    
    CheckError(AudioOutputUnitStart(synthState.rioUnit),
               "Couldn't Start RIO unit");
}

#pragma mark Audio Stream Control

-(void)play:(short)freqIndex{
    NSLog(@"playing");
    //-- Start LFOs
    synthState.m_Osc1_LFO.startOscillator();
    synthState.m_Osc2_LFO.startOscillator();
    synthState.m_Filter1_LFO.startOscillator();
    
    //-- Start pitched oscillators
    synthState.m_Osc1.m_dOscFo=frequencyTable[freqIndex];
    synthState.m_Osc1.update();
    synthState.m_Osc1.startOscillator();
    synthState.m_Osc2.m_dOscFo=frequencyTable[freqIndex];
    synthState.m_Osc2.update();
    synthState.m_Osc2.startOscillator();
    
    
    //-- Start Envelope
    synthState.m_EG1.startEG();
}
-(void)stop{
    NSLog(@"stop");
    synthState.m_EG1.noteOff();
}

#pragma mark Pitch Oscillators Wave Settings
-(void)updateWave:(short)waveIndex forOscillator:(int)number{
    //typedef enum {NOISE,SINE, TRIANGLE, SAW1,SAW2,SQUARE} Shape;
    switch (waveIndex) {
        case 0:
            if (number==1) {
                synthState.m_Osc1.m_uWaveform=CQBLimitedOscillator::NOISE;
            }
            if (number==2) {
                synthState.m_Osc2.m_uWaveform=CQBLimitedOscillator::NOISE;
            }
            break;
            
        case 1:
            if (number==1) {
                synthState.m_Osc1.m_uWaveform=CQBLimitedOscillator::SINE;
            }
            if (number==2) {
                synthState.m_Osc2.m_uWaveform=CQBLimitedOscillator::SINE;
            }
            break;
            
        case 2:
            if (number==1) {
                synthState.m_Osc1.m_uWaveform=CQBLimitedOscillator::TRI;
            }
            if (number==2) {
                synthState.m_Osc2.m_uWaveform=CQBLimitedOscillator::TRI;
            }
            break;
            
            
        case 3:
            if (number==1) {
                synthState.m_Osc1.m_uWaveform=CQBLimitedOscillator::SAW1;
            }
            if (number==2) {
                synthState.m_Osc2.m_uWaveform=CQBLimitedOscillator::SAW1;
            }
            break;
            
        case 4:
            if (number==1) {
                synthState.m_Osc1.m_uWaveform=CQBLimitedOscillator::SAW3;
            }
            if (number==2) {
                synthState.m_Osc2.m_uWaveform=CQBLimitedOscillator::SAW3;
            }
            break;
            
        case 5:
            if (number==1) {
                synthState.m_Osc1.m_uWaveform=CQBLimitedOscillator::SQUARE;
            }
            if (number==2) {
                synthState.m_Osc2.m_uWaveform=CQBLimitedOscillator::SQUARE;
            }
            
            
            break;
        default:
            break;
    }
    synthState.m_Osc1.update();
    synthState.m_Osc2.update();
}
-(void)updateSquareCycleDuty:(CGFloat)duty forOscillator:(int )number{
    if (number==1) {
        synthState.m_Osc1.m_dPulseWidthControl=(double)duty*100;
        synthState.m_Osc1.update();
    }
    if (number==2) {
        synthState.m_Osc2.m_dPulseWidthControl=(double)duty*100;
        synthState.m_Osc2.update();
    }
    
}

-(void)setDetuneAmount:(double)range forOscillator:(int)number{
    
    int semitones=floor(range*12)-6;
    if (number==1) {
        synthState.m_Osc1.m_nSemitones=semitones;
        synthState.m_Osc1.update();
        
        
    }
    if (number==2) {
        synthState.m_Osc2.m_nSemitones=semitones;
        synthState.m_Osc2.update();
        
    }

}




#pragma mark LFO Oscillators Settings
-(void)updateLFOWave:(short)waveIndex forOscillator:(int)number{
    switch (waveIndex) {
        case 0:
            if (number==1) {
                synthState.m_Osc1_LFO.m_uWaveform=CQBLimitedOscillator::rsh;
            }
            if (number==2) {
                synthState.m_Osc2_LFO.m_uWaveform=CQBLimitedOscillator::rsh;
            }
            break;
            
        case 1:
            if (number==1) {
                synthState.m_Osc1_LFO.m_uWaveform=CQBLimitedOscillator::sine;
            }
            if (number==2) {
                synthState.m_Osc2_LFO.m_uWaveform=CQBLimitedOscillator::sine;
            }
            break;
            
        case 2:
            if (number==1) {
                synthState.m_Osc1_LFO.m_uWaveform=CQBLimitedOscillator::tri;
            }
            if (number==2) {
                synthState.m_Osc2_LFO.m_uWaveform=CQBLimitedOscillator::tri;
            }
            break;
            
            
        case 3:
            if (number==1) {
                synthState.m_Osc1_LFO.m_uWaveform=CQBLimitedOscillator::dsaw;
            }
            if (number==2) {
                synthState.m_Osc2_LFO.m_uWaveform=CQBLimitedOscillator::dsaw;
            }
            break;
            
        case 4:
            if (number==1) {
                synthState.m_Osc1_LFO.m_uWaveform=CQBLimitedOscillator::dsaw;
            }
            if (number==2) {
                synthState.m_Osc2_LFO.m_uWaveform=CQBLimitedOscillator::dsaw;
            }
            break;
            
        case 5:
            
            if (number==1) {
                synthState.m_Osc1_LFO.m_uWaveform=CQBLimitedOscillator::square;

            }
            if (number==2) {
                synthState.m_Osc2_LFO.m_uWaveform=CQBLimitedOscillator::square;
            }
            
            
            break;
        default:
            break;
    }
    synthState.m_Osc1_LFO.update();
    synthState.m_Osc2_LFO.update();
}


-(void)setLFOfrequency:(double)range forOscillator:(int)number{
    /*
     The frequency goes from -3 to 10
     freq=(range*13)-3;
     */
    
    double freq=floor(range*13)-3;
    if (freq<0) {
        freq=1/(-freq);
    }
    if (number==1) {
        synthState.m_Osc1_LFO.m_dOscFo=freq;
        synthState.m_Osc1_LFO.resetModulo();
        synthState.m_Osc1_LFO.update();
    }
    if (number==2) {
        synthState.m_Osc2_LFO.m_dOscFo=freq;
        synthState.m_Osc2_LFO.resetModulo();
        synthState.m_Osc2_LFO.update();
        
    }
}

-(void)setLFOWaveShape:(double)range forOscillator:(int)number{
    NSLog(@"setLFOWaveShape");
    if (number==1) {
        if (range>=0 && range<=0.241160) {
            synthState.m_Osc1_LFO.m_uWaveform=CLFO::rsh;
            synthState.m_Osc1_LFO.update();
        }
        if (range>0.241160 && range<=0.371920) {
            synthState.m_Osc1_LFO.m_uWaveform=CLFO::sine;
            synthState.m_Osc1_LFO.update();
        }
        if (range>0.371920 && range<=0.479240) {
            synthState.m_Osc1_LFO.m_uWaveform=CLFO::tri;
            synthState.m_Osc1_LFO.update();
            
        }
        if (range>0.479240 && range<=0.597840) {
            synthState.m_Osc1_LFO.m_uWaveform=CLFO::dsaw;
            synthState.m_Osc1_LFO.update();
        }
        if (range>0.597840 && range<0.95) {
            synthState.m_Osc1_LFO.m_uLFOMode=CLFO::square;
            
            synthState.m_Osc1_LFO.update();
        }
        
        
    }
    if (number==2) {
        if (range>=0 && range<0.20) {
            synthState.m_Osc2_LFO.m_uWaveform=CLFO::sine;
            synthState.m_Osc2_LFO.m_uLFOMode=CLFO::sync;
            synthState.m_Osc2_LFO.update();
        }
        if (range>=0.20 && range<0.40) {
            synthState.m_Osc2_LFO.m_uWaveform=CLFO::tri;
            synthState.m_Osc2_LFO.m_uLFOMode=CLFO::sync;
            synthState.m_Osc2_LFO.update();
        }
        if (range>=0.40 && range<0.60) {
            synthState.m_Osc2_LFO.m_uWaveform=CLFO::qrsh;
            synthState.m_Osc2_LFO.m_uLFOMode=CLFO::sync;
            synthState.m_Osc2_LFO.update();
            
        }
        if (range>=0.60 && range<0.80) {
            synthState.m_Osc2_LFO.m_uWaveform=CLFO::square;
            synthState.m_Osc2_LFO.m_uLFOMode=CLFO::sync;
            synthState.m_Osc2_LFO.update();
        }
        if (range>=0.80 && range<1.0) {
            synthState.m_Osc2_LFO.m_uLFOMode=CLFO::shot;
            synthState.m_Osc2_LFO.update();
        }
   
    }
}

-(void)updateLFOSquareCycleDuty:(CGFloat)duty forOscillator:(int )number{
    if (number==1) {
        synthState.m_Osc1_LFO.m_dPulseWidthControl=(double)duty*100;
        synthState.m_Osc1_LFO.update();
    }
    if (number==2) {
        synthState.m_Osc2_LFO.m_dPulseWidthControl=(double)duty*100;
        synthState.m_Osc2_LFO.update();
    }
    
}

-(void)setOffModeFor:(int)oscillator{
    switch (oscillator) {
        case 1:
            synthState.b_Osc1LFO=false;
            synthState.m_Osc1.reset();
            break;
        case 2:
            synthState.b_Osc2LFO=false;
            synthState.m_Osc2.reset();
            break;
            
        default:
            break;
    }
}
-(void)setShotModeFor:(int)oscillator{
    switch (oscillator) {
        case 1:
            synthState.b_Osc1LFO=true;
            synthState.m_Osc1_LFO.m_uLFOMode=COscillator::shot;
            synthState.m_Osc1_LFO.update();
            break;
        case 2:
            synthState.b_Osc2LFO=true;
            synthState.m_Osc2_LFO.m_uLFOMode=COscillator::shot;
            synthState.m_Osc2_LFO.update();
            break;
            
        default:
            break;
    }
    
}
-(void)setSyncModeFor:(int)oscillator{
    switch (oscillator) {
        case 1:
            synthState.b_Osc1LFO=true;
            synthState.m_Osc1_LFO.m_uLFOMode=COscillator::sync;
            synthState.m_Osc1_LFO.update();
            break;
        case 2:
            synthState.b_Osc2LFO=true;
            synthState.m_Osc2_LFO.m_uLFOMode=COscillator::sync;
            synthState.m_Osc2_LFO.update();
            break;
            
        default:
            break;
    }
}

#pragma mark Envelope Set Up Functions
-(void) setAttackTime:(double)seconds{
    synthState.m_EG1.setAttackTime_mSec(seconds);
    synthState.m_EG1.update();
}

-(void) setDecayTime:(double)seconds{
    synthState.m_EG1.setDecayTime_mSec(seconds);
    synthState.m_EG1.update();
}

-(void) setReleaseTIme:(double)seconds{
    synthState.m_EG1.setReleaseTime_mSec(seconds);
    synthState.m_EG1.update();
}

-(void) setSustainLevel:(double)level{
    synthState.m_EG1.setSustainLevel(level);
    synthState.m_EG1.update();

}

#pragma mark Filter Set Up Functions

-(void)setFilterType:(NSInteger)filterType{
    switch (filterType) {
        case 0:
            synthState.m_Filter1.m_uFilterType=CVAOnePoleFilter::LPF1;
            synthState.m_Filter1.update();
            break;
        case 1:
            synthState.m_Filter1.m_uFilterType=CVAOnePoleFilter::HPF1;
            synthState.m_Filter1.update();
            break;
            
        default:
            break;
    }
}
-(void)setFilterFrequencyCut:(double)range{
    printf("setFilterFrequencyCut ");
    synthState.m_Filter1.m_dFcControl=FILTER_FC_MIN+range*300;
    synthState.m_Filter1.update();

}
-(void)setFilterLFOFrequency:(double)range{
    printf("setFilterLFOFrequency range=%f ",range);
    synthState.m_Filter1_LFO.m_dOscFo=range*5.0;
    synthState.m_Filter1_LFO.resetModulo();
    synthState.m_Filter1_LFO.update();

}

#pragma mark Sound Effect Functions
-(void)distortionEffect{
    if (!synthState.b_distortion) {
        synthState.b_distortion=true;
    }else{
        synthState.b_distortion=false;
    }
}
-(void)delayEffect{
    if (!synthState.b_delay) {
        synthState.b_delay=true;
    }else{
        synthState.b_delay=false;
    }
}

@end
