//
//  RoundControlSlider.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>






@interface RoundControlSlider : UIView

//-- AudioController runtime instance (Communication with algorithm input variables)



//-- User Defined Runtime Attributes
@property NSNumber *identifier;
@property NSString *parameterName;

//-- Internal properties for drawing Control
@property int angle;
@property double decimalVal;


@end
