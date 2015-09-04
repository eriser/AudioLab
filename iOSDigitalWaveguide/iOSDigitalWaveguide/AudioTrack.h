//
//  AudioTrack.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AudioTrack : UIView{
    
    //-- Global Variables
    CGFloat W;
    CGFloat H;
    CGPoint lastPoint;
    int lastIndex;
    int maxGraphHeight;  //Maximun Height of graph (counting the offset in Y axis)
    
    //-- backup images for update drawing
    CGImageRef img;
    UIImage *pastImage;
    UIImage *cleanImage;
    
    BOOL playing;
    
    //-- A gradient
    CAGradientLayer *gradLayer;
    UIColor *backgroundColor;
    UIColor *backgoundColorTransparent;
}


@end
