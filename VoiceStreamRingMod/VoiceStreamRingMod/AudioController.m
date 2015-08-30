//
//  AudioController.m
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "AudioController.h"

/////////////////////////////////////////////////
//////////////Render Callback///////////////////
/////////////////////////////////////////////////
static OSStatus InputModulatingRenderCallback (
                                               void *							inRefCon,
                                               AudioUnitRenderActionFlags *	ioActionFlags,
                                               const AudioTimeStamp *			inTimeStamp,
                                               UInt32							inBusNumber,
                                               UInt32							inNumberFrames,
                                               AudioBufferList *				ioData) {
    RobotVoiceStruct *effectState = (RobotVoiceStruct*) inRefCon;
    UInt32 bus1 = 1;
    @try {AudioUnitRender(effectState->rioUnit,
                          ioActionFlags,
                          inTimeStamp,
                          bus1,
                          inNumberFrames,
                          ioData);
    }@catch (NSException *e) {
        NSLog(@"Couldn't render from RemoteIO unit, Exception:%@",e);
    }
    
    
    
    Float32 sample = 0;
    UInt32 bytesPerChannel = effectState->asbd.mBytesPerFrame/effectState->asbd.mChannelsPerFrame;
    for (int bufCount=0; bufCount<ioData->mNumberBuffers; bufCount++) {
        AudioBuffer buf = ioData->mBuffers[bufCount];
        int currentFrame = 0;
        while ( currentFrame < inNumberFrames ) {
            // copy sample to buffer, across all channels
            for (int currentChannel=0; currentChannel<buf.mNumberChannels; currentChannel++) {
                memcpy(&sample,
                       (buf.mData + (currentFrame * effectState->asbd.mBytesPerFrame)) +
                       (currentChannel * bytesPerChannel),
                       sizeof(Float32));
                
                Float32 theta =(Float32) effectState->sinePhase * M_PI * 2;
                //printf("%f ",theta);
                sample =sin(theta) * (sample*1.5);
                
                memcpy(buf.mData + (currentFrame * effectState->asbd.mBytesPerFrame) +
                       (currentChannel * bytesPerChannel),
                       &sample,
                       sizeof(float));
                
                effectState->sinePhase += 1.0 / (effectState->asbd.mSampleRate / effectState->sineFrequency);
                if (effectState->sinePhase > 1.0) {
                    effectState->sinePhase -= 1.0;
                }
                
                
            }
            currentFrame++;
        }
        
        pthread_mutex_lock(&(effectState->mutex));
        RingBuffer_write(effectState->rb, &sample, 1);
        pthread_mutex_unlock(&(effectState->mutex));
    }
    return noErr;
}

@implementation AudioController
@synthesize robotEffect,dataLength;
-(instancetype)init{
    self=[super init];
    if (self) {
        [self initAudioUnit];
    }
    return self;
}
-(void)initAudioUnit{
    NSLog(@"initAudioUnit");
    robotEffect.rb=RingBuffer_create(512*10);
    pthread_mutex_init(&(robotEffect.mutex), NULL);
    dataLength=0;
    
    //First initialize an audio session
    AVAudioSession *session=[AVAudioSession sharedInstance];
    
    NSError *e;
    BOOL success=[session setCategory:AVAudioSessionCategoryPlayAndRecord error:&e];
    if (!success) {
        NSLog(@"There was an error setting up the audio session and category");
    }else{
        NSLog(@"AudioSession and category set sucessfully");
    }
    /*
     TO DO: For a lab experiment is ok, but It's necessary to handle interruptions from
     incomming calls or from another app's threads
     */
    
    
    //Find for input's availability
    BOOL inputAvailable=session.inputAvailable;
    if (! inputAvailable) {
        //TO DO: Need to create an alert and handle the input's unavailability
        NSLog(@"No input available");
    }
    
    
    //Get the sample rate
    double sessionSampleRate=session.sampleRate;
    NSLog(@"sample rate %f",sessionSampleRate);
    
    //Create an instance of the RIO Unit
    AudioComponentDescription audioCompDesc;
    audioCompDesc.componentType = kAudioUnitType_Output;
    audioCompDesc.componentSubType = kAudioUnitSubType_RemoteIO;
    audioCompDesc.componentManufacturer = kAudioUnitManufacturer_Apple;
    audioCompDesc.componentFlags = 0;
    audioCompDesc.componentFlagsMask = 0;
    
    // get rio unit from audio component manager
    AudioComponent rioComponent = AudioComponentFindNext(NULL, &audioCompDesc);
    @try {
        AudioComponentInstanceNew(rioComponent, &(robotEffect.rioUnit));
    }@catch (NSException *e) {
        NSLog(@"Couldn't get RIO unit instance,Exception: %@",e);
    }
    
    // set up the rio unit for playback
    UInt32 oneFlag = 1;
    AudioUnitElement bus0 = 0;
    @try {
        AudioUnitSetProperty (robotEffect.rioUnit,
                              kAudioOutputUnitProperty_EnableIO,
                              kAudioUnitScope_Output,
                              bus0,
                              &oneFlag,
                              sizeof(oneFlag));
    }@catch (NSException *e) {
        NSLog(@"Couldn't enable RIO output, Exception: %@",e);
    }
    
    
    
    // enable rio input
    AudioUnitElement bus1 = 1;
    @try {
        AudioUnitSetProperty(robotEffect.rioUnit,
                             kAudioOutputUnitProperty_EnableIO,
                             kAudioUnitScope_Input,
                             bus1,
                             &oneFlag,
                             sizeof(oneFlag));
    }@catch (NSException *e) {
        NSLog(@"Couldn't enable RIO input,Exception: %@",e);
    }
    
    
    // setup an asbd in the iphone canonical format
    
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
    @try {
        AudioUnitSetProperty (robotEffect.rioUnit,
                              kAudioUnitProperty_StreamFormat,
                              kAudioUnitScope_Input,
                              bus0,
                              &myASBD,
                              sizeof (myASBD));
    }@catch (NSException *e) {
        NSLog(@"Couldn't set ASBD for RIO on input scope / bus 0, Exception:%@",e);
    }
    
    // set asbd for mic input
    @try {
        AudioUnitSetProperty (robotEffect.rioUnit,
                              kAudioUnitProperty_StreamFormat,
                              kAudioUnitScope_Output,
                              bus1,
                              &myASBD,
                              sizeof (myASBD));
    }@catch (NSException *e) {
        NSLog(@"Couldn't set ASBD for RIO on output scope / bus 1,Exception: %@",e);
    }
    
    robotEffect.asbd = myASBD;
    robotEffect.sineFrequency = 200;
    robotEffect.sinePhase = M_PI/3.0;
    
    // set callback method
    AURenderCallbackStruct callbackStruct;
    callbackStruct.inputProc = InputModulatingRenderCallback; // callback function
    callbackStruct.inputProcRefCon = &robotEffect;
    
    @try {
        AudioUnitSetProperty(robotEffect.rioUnit,
                             kAudioUnitProperty_SetRenderCallback,
                             kAudioUnitScope_Global,
                             bus0,
                             &callbackStruct,
                             sizeof (callbackStruct));
    }@catch (NSException *e) {
        NSLog(@"Couldn't set RIO render callback on bus 0, Exception:%@",e);
    }
    
    // initialize and start remoteio unit
    @try {
        AudioUnitInitialize(robotEffect.rioUnit);
    }@catch (NSException *e) {
        NSLog(@"Couldn't initialize RIO unit, Exception: %@",e);
    }
    

}



-(void)play{
    @try {
        AudioOutputUnitStart (robotEffect.rioUnit);
    }@catch (NSException *e) {
        NSLog(@"Couldn't start RIO unit, Exception: %@",e);
    }
    printf("RIO started!\n");
    
}

-(void)stop{
    @try {
        AudioOutputUnitStop (robotEffect.rioUnit);
    }@catch (NSException *e) {
        NSLog(@"Couldn't stop RIO unit, Exception:%@",e);
    }
    printf("RIO stopped!\n");
    
}

-(float*)readBuffer{
    //NSLog(@"read buffer");
    pthread_mutex_lock(&(robotEffect.mutex));
    dataLength=getAvailableData(self.robotEffect.rb);
    //printf("%d ",dataLength);
    float *data=(float*)calloc(dataLength, sizeof(float));
    RingBuffer_read(self.robotEffect.rb, data, getAvailableData(self.robotEffect.rb));
    pthread_mutex_unlock(&(robotEffect.mutex));
    return data;
}

-(void)setFrequency:(float)freq{
    NSLog(@"setFrequency");
    robotEffect.sineFrequency=freq;
}

-(void)setPhase:(float)phase{
    
    robotEffect.sinePhase=phase;
    printf("%f ",robotEffect.sinePhase);
}



-(void)testFromAudioController{
    NSLog(@"testFromAudioController");
}
@end
