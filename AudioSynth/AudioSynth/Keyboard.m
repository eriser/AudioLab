//
//  Keyboard.m
//  PianoKeyboard
//
//  Created by Ness on 8/3/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#import "Keyboard.h"
#import "KeyView.h"

@interface Keyboard(){
    CGFloat W;
    CGFloat H;
    CGFloat whiteKey_Width;
    CGFloat whiteKey_Height;
    CGFloat blackKey_Width;
    CGFloat blackKey_Height;
}

@end



@implementation Keyboard

-(id)initWithCoder:(NSCoder *)aDecoder{
    self=[super initWithCoder:aDecoder];
    if(self){
        W=self.bounds.size.width;
        H=self.bounds.size.height;
        
        NSLog(@"flag");
        self.backgroundColor=[UIColor clearColor];
        [self setTwoOctaves];
    }
    return self;
}


-(void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event{
    NSLog(@"touches began from keyboard");
}

//Comming from key class
-(void)test{
    NSLog(@"Test method");
}

-(void)setOneOctave{
    whiteKey_Width=W/7;
    whiteKey_Height=H;
    blackKey_Width=whiteKey_Width*0.85;
    blackKey_Height=whiteKey_Height*0.55;
    int dx=whiteKey_Width;
    int idk=1;
    for(int i=0;i<7;i++){
        KeyView *k=[[KeyView alloc]initWithFrame:CGRectMake(i*dx,0,whiteKey_Width, whiteKey_Height )];
        [k setAsBlack:NO];
        idk= i==3 ? 6:idk;
        [k setIdentifier:idk];
        idk+=2;
        
        [self addSubview:k];
    }
    dx=whiteKey_Width*0.5;
    idk=2;
    for(int i=1;i<11;i++){
        if (((i%2!=0)&&(i<5)) || ((i%2==0)&&(i>5))) {
            CGFloat position=(i<5)?i*dx:(i+1.3)*dx;
            printf("i %i\n",i);
            KeyView *k=[[KeyView alloc]initWithFrame:CGRectMake(position,0,blackKey_Width, blackKey_Height )];
            [k setAsBlack:YES];
            [k setIdentifier:i+1];
            [self addSubview:k];
        }
    }
    NSLog(@"%f ",whiteKey_Width);
}

-(void)setTwoOctaves{
    whiteKey_Width=W/14;
    whiteKey_Height=H;
    blackKey_Width=whiteKey_Width*0.85;
    blackKey_Height=whiteKey_Height*0.55;
    
    //Set White Keys
    int dx=whiteKey_Width;
    int idk=1;
    for(int i=0;i<7;i++){
        KeyView *k=[[KeyView alloc]initWithFrame:CGRectMake(i*dx,0,whiteKey_Width, whiteKey_Height )];
        [k setAsBlack:NO];
        idk= i==3 ? 6:idk;
        [k setIdentifier:idk];
        idk+=2;
        
        [self addSubview:k];
    }
    idk=13;
    for(int i=7;i<14;i++){
        KeyView *k=[[KeyView alloc]initWithFrame:CGRectMake(i*dx,0,whiteKey_Width, whiteKey_Height )];
        [k setAsBlack:NO];
        idk= i==10 ? 18:idk;
        [k setIdentifier:idk];
        idk+=2;
        
        [self addSubview:k];
    }
    
    //Set Black Keys
    dx=whiteKey_Width*0.5;
    idk=2;
    for(int i=1;i<11;i++){
        if (((i%2!=0)&&(i<5)) || ((i%2==0)&&(i>5))) {
            CGFloat position=(i<5)?i*dx:(i+1.3)*dx;
            printf("i %i\n",i);
            KeyView *k=[[KeyView alloc]initWithFrame:CGRectMake(position,0,blackKey_Width, blackKey_Height )];
            [k setAsBlack:YES];
            [k setIdentifier:i+1];
            [self addSubview:k];
        }
    }
    
    for(int i=13;i<23;i++){
        if (((i%2!=0)&&(i<17)) || ((i%2==0)&&(i>17))) {
            CGFloat position= (i<17) ? ((i+2.3)*dx):(i+3.3)*dx;
            printf("i %i\n",i);
            KeyView *k=[[KeyView alloc]initWithFrame:CGRectMake(position,0,blackKey_Width, blackKey_Height )];
            [k setAsBlack:YES];
            [k setIdentifier:i+1];
            [self addSubview:k];
        }
    }


    
    

}


@end
