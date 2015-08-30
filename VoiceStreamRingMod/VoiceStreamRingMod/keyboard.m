//
//  keyboard.m
//  VoiceStreamRingMod
//
//  Created by Ness on 8/30/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "keyboard.h"
#import "singleKey.h"
@interface keyboard(){
    CGFloat W;
    CGFloat H;
    CGFloat whiteKey_Width;
    CGFloat whiteKey_Height;
    CGFloat blackKey_Width;
    CGFloat blackKey_Height;
}

@end
@implementation keyboard

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if (self) {
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        self.backgroundColor=[UIColor clearColor];
        [self setTwoOctaves];
        
        //        UIView *testView =[[UIView alloc]initWithFrame:CGRectMake(0, -20, W, 25)];
        //        testView.backgroundColor=[UIColor redColor];
        //        [self addSubview:testView];
    }
    return self;
}
-(void)setOneOctave{
    whiteKey_Width=W/7;
    whiteKey_Height=H;
    blackKey_Width=whiteKey_Width*0.85;
    blackKey_Height=whiteKey_Height*0.55;
    int dx=whiteKey_Width;
    int idk=1;
    for(int i=0,j=1;i<7;i++){
        singleKey *k=[[singleKey alloc]initWithFrame:CGRectMake(i*dx,0,whiteKey_Width, whiteKey_Height )];
        j%2==0?[k setLightKey]:[k setTransparentKey];
        j++;
        
        idk= i==3 ? 6:idk;
        [k setIdentifier:idk];
        idk+=2;
        
        [self addSubview:k];
    }
    
    dx=whiteKey_Width*0.5;
    idk=2;
    for(int i=1;i<11;i++){
        if (((i%2!=0)&&(i<5)) || ((i%2==0)&&(i>5))) {
            CGFloat position=(i<5)?i*dx:(i+1.2)*dx;
            //            printf("i %i\n",i);
            singleKey *k=[[singleKey alloc]initWithFrame:CGRectMake(position,0,blackKey_Width, blackKey_Height )];
            [k setDarkKey];
            [k setIdentifier:i+1];
            [self addSubview:k];
        }
    }
    
}


-(void)setTwoOctaves{
    
    
    whiteKey_Width=W/14;
    whiteKey_Height=H;
    blackKey_Width=whiteKey_Width*0.85;
    blackKey_Height=whiteKey_Height*0.55;
    
    //-- Set white keys
    
    int dx=whiteKey_Width;
    int idk=1;
    for(int i=0,j=1;i<7;i++){
        singleKey *k=[[singleKey alloc]initWithFrame:CGRectMake(i*dx,0,whiteKey_Width, whiteKey_Height )];
        j%2==0?[k setLightKey]:[k setTransparentKey];
        j++;
        
        idk= i==3 ? 6:idk;
        [k setIdentifier:idk];
        idk+=2;
        
        [self addSubview:k];
    }
    idk=13;
    for(int i=7,j=1;i<14;i++){
        singleKey *k=[[singleKey alloc]initWithFrame:CGRectMake(i*dx,0,whiteKey_Width, whiteKey_Height )];
        j%2==0?[k setLightKey]:[k setTransparentKey];
        j++;
        
        idk= i==10 ? 18:idk;
        [k setIdentifier:idk];
        idk+=2;
        
        [self addSubview:k];
    }
    
    //-- Black keys
    
    dx=whiteKey_Width*0.5;
    idk=2;
    for(int i=1;i<11;i++){
        if (((i%2!=0)&&(i<5)) || ((i%2==0)&&(i>5))) {
            CGFloat position=(i<5)?i*dx:(i+1.2)*dx;
            //            printf("i %i\n",i);
            singleKey *k=[[singleKey alloc]initWithFrame:CGRectMake(position,0,blackKey_Width, blackKey_Height )];
            [k setDarkKey];
            [k setIdentifier:i+1];
            [self addSubview:k];
        }
    }
    
    
    for(int i=13;i<23;i++){
        if (((i%2!=0)&&(i<17)) || ((i%2==0)&&(i>17))) {
            CGFloat position=(i<17)?(i+2.5)*dx:(i+3.5)*dx;
            //            printf("i %i\n",i);
            singleKey *k=[[singleKey alloc]initWithFrame:CGRectMake(position,0,blackKey_Width, blackKey_Height )];
            [k setDarkKey];
            [k setIdentifier:i+1];
            [self addSubview:k];
        }
    }
    
}

@end
