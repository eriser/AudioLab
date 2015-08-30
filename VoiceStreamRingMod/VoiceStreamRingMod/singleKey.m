//
//  singleKey.m
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "singleKey.h"
@class blueKeyboard;
@interface blueKeyboard
@property AudioController *au;
@end


const float frequencyTable[26]={
    261.6255798339843700,   //Start of a octave
    277.1826171875000000,
    293.6647644042968700,
    311.1269836425781200,
    329.6275634765625000,
    349.2282409667968700,
    369.9944152832031200,
    391.9954223632812500,
    415.3046875000000000,
    440.0000000000000000,
    466.1637573242187500,
    493.8833007812500000,
    523.2511596679687500,    //End of Octave
    554.3652343750000000,    //Start of octave
    587.3295288085937500,
    622.2539672851562500,
    659.2551269531250000,
    698.4564819335937500,
    739.9888305664062500,
    783.9908447265625000,
    830.6093750000000000,
    880.0000000000000000,
    932.3275146484375000,
    987.7666015625000000,     //End of Octave
    1046.5023193359375000,
    1108.7304687500000000
};
@implementation singleKey
@synthesize isTransparent,identifier,au;
-(instancetype)initWithFrame:(CGRect)frame{
    self=[super initWithFrame:frame];
    if (self) {
        //isTransparent=YES;
        self.backgroundColor=[UIColor clearColor];
        color=[UIColor colorWithRed:246/255.0f green:80/255.0f blue:10/255.0f alpha:0.8];
        transparentColor=[UIColor colorWithRed:246/255.0f green:80/255.0f blue:10/255.0f alpha:0.2];
        borderColor=[UIColor colorWithRed:45/255.0f green:195/255.0f blue:181/255.0f alpha:0.1];
        darkColor=[UIColor colorWithRed:198/255.0f green:56/255.0f blue:0/255.0f alpha:0.8];
    }
    return self;
}


-(void)setTransparentKey{
    
    self.layer.backgroundColor=transparentColor.CGColor;
    self.layer.borderColor=borderColor.CGColor;
    self.layer.borderWidth=3.0;
    self.layer.cornerRadius=10.0;
    
}
-(void)setLightKey{
    self.layer.backgroundColor=color.CGColor;
    self.layer.borderColor=borderColor.CGColor;
    self.layer.borderWidth=3.0;
    self.layer.cornerRadius=10.0;
}
-(void)setDarkKey{
    self.layer.backgroundColor=darkColor.CGColor;
    self.layer.borderColor=borderColor.CGColor;
    self.layer.borderWidth=3.0;
    self.layer.cornerRadius=10.0;
    
    //shadow
    self.layer.shadowColor=[UIColor blackColor].CGColor;
    self.layer.shadowRadius=3.0;
    self.layer.shadowOpacity=1.0;
    
    
}

-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"%i", identifier);
    float f=frequencyTable[identifier];
    [[(blueKeyboard*)self.superview au] setFrequency:f];
    //    [au setFrequency:frequencyTable[identifier]];
}

@end
