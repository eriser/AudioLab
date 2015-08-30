//
//  singleKey.h
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AudioController;
@interface AudioController
-(void)setFrequency:(float)freq;
@end



@interface singleKey : UIView{
    
        UIColor *color;
        UIColor *transparentColor;
        UIColor *borderColor;
        UIColor *darkColor;

}

@property BOOL isTransparent;
@property int identifier;
@property AudioController *au;
-(void)setTransparentKey;
-(void)setLightKey;
-(void)setDarkKey;
@end
