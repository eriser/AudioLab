//
//  KeyView.h
//  PianoKeyboard
//
//  Created by Ness on 8/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface KeyView : UIView
@property int identifier;       //-- Identifes de key position in the keyboard
-(void)setAsBlack:(BOOL)black;  //-- Set the key layer drawing as a black/white key
@end
