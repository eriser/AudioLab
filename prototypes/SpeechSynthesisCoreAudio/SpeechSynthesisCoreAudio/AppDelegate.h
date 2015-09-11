//
//  AppDelegate.h
//  SpeechSynthesisCoreAudio
//
//  Created by Ness on 1/7/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#import "AudioController.h"

@interface AppDelegate : NSObject <NSApplicationDelegate>

@property (weak) IBOutlet NSButton *reverbOption;
@property (weak) IBOutlet NSTextField *textField;
@property (weak) IBOutlet NSButton *playStopButton;
@property BOOL playing;
@property AudioController *au;


- (IBAction)playStopProcess:(id)sender;


@end

