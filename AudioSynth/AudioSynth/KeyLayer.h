//
//  KeyLayer.h
//  PianoKeyboard
//
//  Created by Ness on 8/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyLayer : CALayer{
    CGFloat W;
    CGFloat H;
    UIImage *whiteKeyImg;
}
@property BOOL isBlack;

@end
