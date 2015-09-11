//
//  AudioController.m
//  SpeechSynthesisCoreAudio
//
//  Created by Ness on 1/7/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "AudioController.h"

/*////////////////////////////////////////////////
        Create Audio Graph: Speech->Output
 */////////////////////////////////////////////////

void CreateAUGraph(SpeechStruct *speechGraph){
    
    // Create a new AUGraph
    @try {
        NewAUGraph(&speechGraph->graph);
    }@catch (NSException *e) {
        NSLog(@"NewAUGraph failed, Exception: %@",e);
    }
    // Generates a description that matches our output
    // device (speakers)
    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Adds a node with above description to the graph
    AUNode outputNode;
    @try {
        AUGraphAddNode(speechGraph->graph,
                       &outputcd,
                       &outputNode);
    }
    @catch (NSException *e) {
        NSLog(@"AUGraphAddNode[kAudioUnitSubType_DefaultOutput] failed, Exception: %@",e);
    }
    
    // Generates a description that will match a generator AU
    // of type: speech synthesizer
    AudioComponentDescription speechcd = {0};
    speechcd.componentType = kAudioUnitType_Generator;
    speechcd.componentSubType = kAudioUnitSubType_SpeechSynthesis;
    speechcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Adds a node with above description to the graph
    AUNode speechNode;
    @try {
        AUGraphAddNode(speechGraph->graph,
                       &speechcd,
                       &speechNode);
    }@catch (NSException *e) {
        NSLog(@"AUGraphAddNode[kAudioUnitSubType_SpeechSynthesis] failed, Exception: %@",e);
    }
    
    // Opening the graph opens all contained audio units, but
    // does not allocate any resources yet
    @try {
        AUGraphOpen(speechGraph->graph);
    }
    @catch (NSException *e) {
        NSLog(@"AUGraphOpen failed, Exception: %@",e);
    }
    // Gets the reference to the AudioUnit object for the
    // speech synthesis graph node
    @try {
        AUGraphNodeInfo(speechGraph->graph,
                        speechNode,
                        NULL,
                        &speechGraph->speechAU);
    }
    @catch (NSException *e) {
        NSLog(@"AUGraphNodeInfo failed, Exception: %@",e);
    }

    // Connect the output source of the speech synthesis AU
    // to the input source of the output node
    @try {
        AUGraphConnectNodeInput(speechGraph->graph,
                                speechNode,
                                0,
                                outputNode,
                                0);
    }@catch (NSException *e) {
        NSLog(@"AUGraphConnectNodeInput failed, Exception: %@",e);
    }

    // Now initialize the graph (causes resources to be allocated)
    @try {
        AUGraphInitialize(speechGraph->graph);
    }@catch (NSException *e) {
        NSLog(@"AUGraphInitialize failed, Exception: %@",e);
    }

}

/*////////////////////////////////////////////////
 Create Audio Graph: Speech->Output
 */////////////////////////////////////////////////


void CreateAUGraph_reverb(SpeechStruct *speechGraph){
    //Create a new graph instance
    @try {
        NewAUGraph(&speechGraph->graph);
    }@catch (NSException *e) {
        NSLog(@"NewAUGraph failed, Exception:%@",e);
    }
    
    // Generates a description that matches our output
    // device (speakers)
    AudioComponentDescription outputcd = {0};
    outputcd.componentType = kAudioUnitType_Output;
    outputcd.componentSubType = kAudioUnitSubType_DefaultOutput;
    outputcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Adds a node with above description to the graph
    AUNode outputNode;
    @try {
        AUGraphAddNode(speechGraph->graph,
                       &outputcd,
                       &outputNode);
    }@catch (NSException *e) {
        NSLog(@"Couldn't create an audioNode, Exception: %@",e);
    }
    
    // Generates a description that will match a generator AU
    // of type: speech synthesizer
    AudioComponentDescription speechcd = {0};
    speechcd.componentType = kAudioUnitType_Generator;
    speechcd.componentSubType = kAudioUnitSubType_SpeechSynthesis;
    speechcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Adds a node with above description to the graph
    AUNode speechNode;
    @try {
        AUGraphAddNode(speechGraph->graph,
                       &speechcd,
                       &speechNode);
    }@catch (NSException *e) {
        NSLog(@"AUGraphAddNode[kAudioUnitSubType_SpeechSynthesis] failed, Exception: %@",e);
    }
    
    // Opening the graph opens all contained audio units, but
    // does not allocate any resources yet
    @try {
        AUGraphOpen(speechGraph->graph);
    }@catch (NSException *e) {
        NSLog(@"AUGraphOpen failed, Exception: %@",e);
    }
    
    // Gets the reference to the AudioUnit object for the
    // speech synthesis graph node
    @try {
        AUGraphNodeInfo(speechGraph->graph,
                        speechNode,
                        NULL,
                        &speechGraph->speechAU);
    }@catch (NSException *e) {
        NSLog(@"AUGraphNodeInfo failed, Exception: %@",e);
    }


    // Generate a description that matches the reverb effect
    AudioComponentDescription reverbcd = {0};
    reverbcd.componentType = kAudioUnitType_Effect;
    reverbcd.componentSubType = kAudioUnitSubType_MatrixReverb;
    reverbcd.componentManufacturer = kAudioUnitManufacturer_Apple;
    
    // Adds a node with the above description to the graph
    AUNode reverbNode;
    @try {
        AUGraphAddNode(speechGraph->graph,
                       &reverbcd,
                       &reverbNode);
    }
    @catch (NSException *e) {
        NSLog(@"AUGraphAddNode[kAudioUnitSubType_MatrixReverb] failed,Exception: %@",e);
    }
    // Connect the output source of the speech synthesizer AU to
    // the input source of the reverb node
    @try {
        AUGraphConnectNodeInput(speechGraph->graph,
                                speechNode,
                                0,
                                reverbNode,
                                0);
    }@catch (NSException *e) {
        NSLog(@"AUGraphConnectNodeInput (speech to reverb) failed, Exception: %@",e);
    }
    // Connect the output source of the reverb AU to the input
    // source of the output node
    @try {
        AUGraphConnectNodeInput(speechGraph->graph,
                                reverbNode,
                                0,
                                outputNode,
                                0);
    }@catch (NSException *e) {
        NSLog(@"AUGraphConnectNodeInput (reverb to output) failed, Exception: %@",e);
    }
    
    // Get the reference to the AudioUnit object for the reverb
    // graph node
    AudioUnit reverbUnit;
    @try {
        AUGraphNodeInfo(speechGraph->graph,
                        reverbNode,
                        NULL,
                        &reverbUnit);
    }@catch (NSException *e) {
        NSLog(@"AUGraphNodeInfo failed, Exception: %@",e);
    }
    // Now initialize the graph (this causes the resources to be
    // allocated)
    @try {
        AUGraphInitialize(speechGraph->graph);
    }
    @catch (NSException *e) {
        NSLog(@"AUGraphInitialize failed, Exception: %@",e);
    }
    
    // Set the reverb preset for room size
    UInt32 roomType=kReverbRoomType_LargeHall;
    @try {
        AudioUnitSetProperty(reverbUnit,
                             kAudioUnitProperty_ReverbRoomType,
                             kAudioUnitScope_Global,
                             0,
                             &roomType,
                             sizeof(UInt32));
    }@catch (NSException *e) {
        NSLog(@"AudioUnitSetProperty[kAudioUnitProperty_ReverbRoomType] failed, Exception:%@",e);
    }
}

/*////////////////////////////////////////////////
 Set the speech unit with the message to synthesize
 */////////////////////////////////////////////////

void setSpeechAU(SpeechStruct *speechGraph, CFStringRef message) {
    NSLog(@"PrepareSpeechAU flag");
    SpeechChannel channel;
    UInt32 propsize=sizeof(SpeechChannel);
    @try {
        AudioUnitGetProperty(speechGraph->speechAU,
                             kAudioUnitProperty_SpeechChannel,
                             kAudioUnitScope_Global,
                             0,
                             &channel,
                             &propsize);
    }@catch (NSException *e) {
        NSLog(@"AudioUnitGetProperty[kAudioUnitProperty_SpeechChannel] failed, Exception:%@",e);
    }
    SpeakCFString(channel, message, NULL);
}

@interface AudioController(){
    CFStringRef message;
}

@end

@implementation AudioController
@synthesize  speechGraph,isRunning, myTimer;
-(void)setMessage:(NSString *)messageFromField{
    message=(__bridge CFStringRef)messageFromField;
}
-(void)play{
    //Create a struct
    speechGraph=malloc(sizeof(SpeechStruct));
    
    //Create a simple audio graph
    CreateAUGraph(speechGraph);
    setSpeechAU(speechGraph,message);
    
    //Start playing
    @try {
        AUGraphStart(speechGraph->graph);
    }@catch (NSException *e) {
        NSLog(@"AUGraphStart failed, Exception: %@",e);
    }

    //LOOP->lock thread
    if (!isRunning) {
        if(nil==self.myTimer){
            self.myTimer=[NSTimer timerWithTimeInterval:1.0/15 target:self selector:@selector(test:) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.myTimer forMode:NSRunLoopCommonModes];
        }
    }
}


//////////////////////////////
/////CONTROL FUNCTIONS////////
//////////////////////////////

-(void)play_reverb{
    //Create a struct
    speechGraph=malloc(sizeof(SpeechStruct));
    
    //Create a simple audio graph
    CreateAUGraph_reverb(speechGraph);
    setSpeechAU(speechGraph,message);
    
    //Start playing
    @try {
        AUGraphStart(speechGraph->graph);
    }
    @catch (NSException *e) {
        NSLog(@"AUGraphStart failed, Exception: %@",e);
    }
    
    //LOOP-->lock thread
    if (!isRunning) {
        if(nil==self.myTimer){
            self.myTimer=[NSTimer timerWithTimeInterval:1.0/15 target:self selector:@selector(self) userInfo:nil repeats:YES];
            [[NSRunLoop mainRunLoop] addTimer:self.myTimer forMode:NSRunLoopCommonModes];
        }
    }

}

-(void)stop{
    AUGraphStop (speechGraph->graph);
    [self.myTimer invalidate];
    AUGraphUninitialize (speechGraph->graph);
    AUGraphClose(speechGraph->graph);
}


-(void)test:(NSTimer*)theTimer{
    
    AUGraphIsRunning(speechGraph->graph, &isRunning);
    if (isRunning) {
        printf("loop ");
    }else {
        printf("stoped ");
    }
}

@end



