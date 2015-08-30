//
//  lightUpButton.h
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
@class AudioController;
@interface AudioController
-(void)testFromAudioController;
@end

@interface lightUpButton : UIControl
@property IBOutlet AudioController *au;
@end
