//
//  lightUpButton.m
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "lightUpButton.h"

@implementation lightUpButton
@synthesize au;
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    [au testFromAudioController];
}
@end
