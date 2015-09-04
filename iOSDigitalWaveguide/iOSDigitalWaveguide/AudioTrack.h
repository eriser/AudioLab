//
//  AudioTrack.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>


@interface AudioTrack : UIView{
    
    //-- Global Geometry
    CGFloat W;
    CGFloat H;
    CGPoint lastPoint;
    
    //-- Plot helper variables
    int lastIndex;
    int maxGraphHeight;  //Maximun Height of graph (counting the offset in Y axis)
    BOOL playing;
    
    //-- backup images for update drawing
    CGImageRef img;
    UIImage *pastImage;
    UIImage *cleanImage;
    
    //-- Gradient Effect
    CAGradientLayer *gradLayer;
    UIColor *backgroundColor;
    UIColor *backgoundColorTransparent;
}






////-- Audio Level Data container
@property float data;

////-- Drawing Loop Elements
@property NSTimer *timer;
-(void)activateLoop;
-(void)deactivateLoop;
-(void)resetGraph;



@end
