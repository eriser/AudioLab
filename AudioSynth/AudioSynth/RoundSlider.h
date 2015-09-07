//
//  RoundSlider.h
//  OscillatorController
//
//  Created by Ness on 8/18/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
/** Parameters **/
//#define TB_SLIDER_SIZE 320                //The width and the heigth of the slider
#define TB_BACKGROUND_WIDTH 6             //The width of the dark background
#define TB_LINE_WIDTH 10                 //The width of the active area (the gradient) and the width of the handle
#define TB_FONTSIZE 14                    //The size of the textfield font
#define TB_FONTFAMILY @"Futura-CondensedExtraBold"  //The font family of the textfield font

typedef enum : NSUInteger {
    YELLOW,
    RED,
    GREEN,
    FIRE
} Color;

@interface RoundSlider : UIControl{
    CGFloat components[8];
}
@property (nonatomic,assign) int angle;
@property (nonatomic,assign) float range;
@property (nonatomic,assign) int identifier;
@property Color sliderColor;
-(void)updateRoundSlider:(float)range;
@end
