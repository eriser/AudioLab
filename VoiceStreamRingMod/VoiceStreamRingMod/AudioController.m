//
//  AudioController.m
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "AudioController.h"

@implementation AudioController
-(instancetype)init{
    self=[super init];
    if (self) {
        [self initAudioUnit];
    }
    return self;
}
-(void)initAudioUnit{
    NSLog(@"initAudioUnit");
}
-(void)testFromAudioController{
    NSLog(@"testFromAudioController");
}
@end
