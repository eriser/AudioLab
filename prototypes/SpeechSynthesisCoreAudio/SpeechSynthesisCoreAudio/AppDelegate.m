//
//  AppDelegate.m
//  SpeechSynthesisCoreAudio
//
//  Created by Ness on 1/7/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "AppDelegate.h"

@interface AppDelegate ()

@property (weak) IBOutlet NSWindow *window;
@end

@implementation AppDelegate
@synthesize au,playing,reverbOption,textField,playStopButton;
- (void)applicationDidFinishLaunching:(NSNotification *)aNotification {
    
    //Audio Init
    au=[[AudioController alloc]init];
    playing=false;
    
    
}

- (void)applicationWillTerminate:(NSNotification *)aNotification {
    // Insert code here to tear down your application
}


- (IBAction)playStopProcess:(id)sender {
    
    if(!playing){                       //Start playing
        playing=true;
        [playStopButton setTitle:@"stop"];
        reverbOption.hidden=YES;
        NSString *message= [[NSString alloc] initWithFormat:@"%@",[textField stringValue] ];
        [au setMessage:message];
        
        long int r=[reverbOption state];
        
        if (!r) {
            printf("reverStatus Off\n");
            [au play];
        }else{
            printf("reverStatus On\n");
            [au play_reverb];
        }
        
    }else {
        playing=false;
        reverbOption.hidden=NO;
        [playStopButton setTitle:@"play"];
    }

}


@end
