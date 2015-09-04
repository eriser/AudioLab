//
//  Key.h
//  iOSDigitalWaveguide
//
//  Created by Ness on 9/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>






@interface Key : UIView{
    ///-- Colors
    UIColor *color;
    UIColor *transparentColor;
    UIColor *borderColor;
    UIColor *darkColor;
    
}

////-- AudioController runtime instance 
//@property AudioController *au;

//-- Colors
@property UIColor *keyColor;
@property int identifier;
-(void)setTransparentKey;
-(void)setLightKey;
-(void)setDarkKey;


@end
