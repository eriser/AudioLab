//
//  WaveShape.h
//  WaveSelector
//
//  Created by Ness on 7/13/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {NOISE,SINE, TRIANGLE, SAW1,SAW2,SQUARE} Shape;

@interface WaveShape : UIView
@property Shape shape;
@property CGFloat squareDuty;
@end
