//
//  Keyboard.h
//  PianoKeyboard
//
//  Created by Ness on 8/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AudioController.h"
@interface Keyboard : UIView

@property IBOutlet AudioController *AUKeyboard;
-(void)test;
-(void)setOneOctave;
@end
