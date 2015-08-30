//
//  AudioTrack.h
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>


@class AudioController;
@interface AudioController
-(float*)readBuffer;
@end

@interface AudioTrack : UIView{
    NSTimer *timer;
    SEL testSelector;
    
    //-- backup images for update drawing
    CGImageRef img;
    UIImage *pastImage;
    UIImage *cleanImage;
    
    
    
    //-- Geometric info for plot
    CGPoint lastPoint;
    int lastIndex;
    CGFloat W;          //width of the view
    CGFloat H;          //height of the view
    int maxGraphHeight;  //Maximun Height of graph (counting the offset in Y axis)
    
    
    
    //-- For layers
    //-- A gradient
    CAGradientLayer *gradLayer;
    UIColor *backgroundColor;
    UIColor *backgoundColorTransparent;
    
    
}

@property IBOutlet AudioController *au;
@property float data;
-(void)activateLoop;
@end
