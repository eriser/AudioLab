//
//  OscillatorController.h
//  OscillatorController
//
//  Created by Ness on 8/18/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "RoundSlider.h"
#import "WaveShape.h"
#import "AudioController.h"
@interface OscillatorController : UIView{
    
    //-- Global Geometry
    
    CGFloat W;
    CGFloat H;
    
    
    //-- Geometry for Central Curves
    
    CGFloat W1;
    CGFloat H1;
    CGPoint center;

    //-- Angles for Central Curves
    
    int startAng1;
    int ang1;
    int startAng2;
    int ang2;
    int startAng3;
    int ang3;
    int startAng4;
    int ang4;
    
    //-- Radius for Central Curves
    
    CGFloat r1;
    CGFloat r2;
    CGFloat r3;
    CGFloat r4;
    
    //-- Curves for Touch Control

    UIBezierPath *curve1;
    UIBezierPath *curve2;
    UIBezierPath *curve3;
    UIBezierPath *curve4;
    
    //-- Controller Curve Currently Activated

    int updateCurve;

    //-- Geometry for secundary round sliders
    
    CGFloat W2;
    CGFloat H2;
    
    //-- Round sliders
    
    RoundSlider *sliderLFO;
    RoundSlider *sliderDetune;
    RoundSlider *sliderPhase;

    
    //-- Curve controller's UILabels
    
    UITextField *LFOTextField;
    UITextField *DetuneTextField;
    UITextField *PhaseTextField;
    UITextField *noiseLabel;
    UITextField *sineLabel;
    UITextField *sawLabel;
    UITextField *triLabel;
    UITextField *squareLabel;
    
}

@property IBOutlet AudioController *AUCurveController;

//-- Wave Shape instance: subclasses UIView for Visual Feedback

@property WaveShape *LFOWaveIndicator;      //Current wave shape of LFO Oscillator
@property WaveShape *centralWave;           //Current wave shape of Pitched Oscillator

//-- Oscillator Number Defined by user
@property NSNumber *OscNumber;




@property int identifier;                   //Used for identify outter round sliders

-(void)testFromOscController;
-(void)updateCurve:(int)curveNumber withRange:(float)range;


-(void)updateOscillatorWave:(double)range forWaveShape:(WaveShape*)wave;




@end
