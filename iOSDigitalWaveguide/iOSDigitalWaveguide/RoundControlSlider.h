//
//  RoundControlSlider.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>


///-- Foward declaration of AudioController and related methods

//@class AudioController;
//@interface AudioController
//-(void)setPickupPosition:(double)position;
//-(void)setPluckInputPosition:(double)position;
//-(void)setAmp:(double)value;
//-(void)updateDelayLineStructure;
//@end

@interface RoundControlSlider : UIControl

//-- AudioController runtime instance (Communication with algorithm input variables)
//@property IBOutlet AudioController *au;


//-- User Defined Runtime Attributes
@property NSNumber *identifier;
@property NSString *parameterName;

//-- Internal properties for drawing Control
@property int angle;
@property double decimalVal;


@end
