//
//  Distortion.h
//  Synth_Osc2
//
//  Created by Ness on 8/21/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#ifndef __Synth_Osc2__Distortion__
#define __Synth_Osc2__Distortion__

#include <stdio.h>
#include <math.h>
class Distortion{
public:
    float G;
    float max;
    Distortion(){
        G=7;
        max=1.0;
    };
    ~Distortion(){};
    
    inline float doDistortion(float x){
        float y;
        x=G*x;
        if (x>=0) {
            y=(1- exp(-x));
        }else{
            y=-(1-exp(x));
        }
        if (y>max) {
            max=y;
            y=y/max;
        }
        return y;
    }
};

#endif /* defined(__Synth_Osc2__Distortion__) */

