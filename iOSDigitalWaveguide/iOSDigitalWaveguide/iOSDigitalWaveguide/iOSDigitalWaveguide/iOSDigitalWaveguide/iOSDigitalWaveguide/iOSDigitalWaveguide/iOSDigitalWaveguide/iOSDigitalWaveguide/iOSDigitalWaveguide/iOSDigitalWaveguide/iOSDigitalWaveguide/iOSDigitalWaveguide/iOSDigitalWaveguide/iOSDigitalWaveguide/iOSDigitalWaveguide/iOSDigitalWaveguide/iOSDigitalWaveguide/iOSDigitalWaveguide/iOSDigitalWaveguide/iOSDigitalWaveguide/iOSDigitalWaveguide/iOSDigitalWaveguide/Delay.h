//
//  simpleReverb.h
//  Synth_Osc2
//
//  Created by Ness on 8/24/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#ifndef __Synth_Osc2__simpleReverb__
#define __Synth_Osc2__simpleReverb__

#include <stdio.h>
#include "FIFO.h"

class Delay{
public:
    FIFO *delayLine;
    float coef;
    int M;
    
    Delay(){
        delayLine= new FIFO();
        coef=0.5;
        M=24000;
    }
    ~Delay(){};
    
    inline bool isFull(FIFO *Q){
        return Q->size==M;
    }
    
    inline float doSimpleReverb(float x){
        float y=0,xz=0;
        if (isFull(delayLine)) {
            xz=delayLine->dequeue();
            xz*=coef;
            delayLine->enqueue(x);
        }else{
            xz=0;
            delayLine->enqueue(x);
        }
        y= x + xz;

        return y;
    }
    
};
#endif /* defined(__Synth_Osc2__simpleReverb__) */
