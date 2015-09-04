//
//  DigitalWaveGuide.h
//  DigitalWaveGuide
//
//  Created by Ness on 8/7/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#ifndef __DigitalWaveGuide__DigitalWaveGuide__
#define __DigitalWaveGuide__DigitalWaveGuide__

#include <stdio.h>
#include <stdlib.h>
#include <math.h>
#include "Oscillator.h"
#define SRATE 44100
#define DOUBLE_TO_SHORT(x) ((int) ((x)*32768.0))

typedef struct _DelayLine{
    int         length;
    short       *data;
    short       *pointer;
    short       *end;
}DelayLine;


class DigitalWaveGuide: public COscillator{
public:
    
    DigitalWaveGuide(){
        //printf("flag");
         //upper_rail=(DelayLine*)malloc(sizeof(DelayLine));
         //lower_rail=(DelayLine*)malloc(sizeof(DelayLine));
        
    }
    ~DigitalWaveGuide(){
    }
    ////--- Create and release the delay line structure
    static DelayLine* initDelayLine(int len){
        DelayLine *dl=(DelayLine *)malloc( sizeof(DelayLine));
        dl->length=len;
        if (len>0) {
            dl->data = (short *)calloc(len, len * sizeof(short));
        }else{
            dl->data=0;
        }
        dl->pointer = dl->data;
        dl->end = dl->data+len-1;
        return dl;
    }
    static void freeDelayLine(DelayLine *dl){
        if (dl && dl->data) {
            //free(dl->data);
            delete dl->data;
        }
        dl->data = 0;
        //free(dl);
        delete  dl;
    }
    
    static inline int initString(double amplitude, double pitch, double pick, double pickup){
        int i, rail_length=SRATE/pitch/2+1;
        
        /*
         Round pick position to nearest spatial sample.
         A pick position at x = 0 is not allowed
         */
        
        int pickSample = fmax(rail_length * pick, 1);
        double upslope = amplitude / pickSample;
        double downslope = amplitude / (rail_length - pickSample - 1);
        double initial_shape[rail_length];
        
        upper_rail = initDelayLine(rail_length);
        lower_rail = initDelayLine(rail_length);
        
        
        for (i = 0; i < pickSample; i++) {
            initial_shape[i]=upslope * i;
        }
        for (i = pickSample; i < rail_length; i++) {
            initial_shape[i] = downslope*(rail_length-1-i);
        }
        
        setDelayLine(lower_rail, initial_shape, 0.5);
        setDelayLine(upper_rail, initial_shape, 0.5);
        
        return pickup * rail_length;
    }
    
    
    ////--- THIS FUNCTION PERFORM THE SYNTHESIS!!!!
    static inline short nextStringSample (int pickup_loc){
        short yp0, ym0, ypM, ymM;
        short outsamp, outsamp1;
        
        /*Output at pickup location*/
        outsamp = rg_dl_access(upper_rail, pickup_loc);
        outsamp1= lg_dl_access(lower_rail, pickup_loc);
        outsamp += outsamp1;
        
        ym0= lg_dl_access(lower_rail, 0);   /*Sample traveling into "bridge"*/
        ypM= rg_dl_access(upper_rail, upper_rail->length-2);    /*sample to the "nut"*/
        
        ymM = -ypM;                     /*Inverting reflection at rigid nut*/
        yp0 = -bridgeReflection(ym0);   /*Reflection at yielding bridge*/
        
        /*String state update*/
        rg_dl_update(upper_rail, yp0);  /*Decrement pointer and the update*/
        lg_dl_update(lower_rail, ymM);  /*Update and then increment pointer*/
        
        return  outsamp;
    }

    /************************************************************************
     Virtual overrides + pickupSample
     ************************************************************************/
    double              pitch;                  //Pitch frequency
    double              pick;                   //Location of pluck input
    double              pickup;                 //String Location where the output signal is taken from
    double              duration;               //Duration of synthesized sound
    double              amp;                    //amplitude
    int                 pickupSample;           //Contains the delay line register at the pickup position in string
    
    //--- start/stop control
    void startOscillator(){
        m_bNoteOn=true;
    };
    void stopOscillator(){
        m_bNoteOn=false;
    };
    
    //--- Render
    //		    for LFO: pAuxOutput = QuadPhaseOutput
    //			Pitched: pAuxOutput = Right channel (return value is left Channel)
    double doOscillate(double* pAuxOutput = NULL){
        double dOut=nextStringSample(pickupSample)/32768.0;
        return dOut;
    };
    
    inline void update(){
        pickupSample= initString(amp, pitch, pick, pickup);
    }
    
//private:
    /*
        PRIVATE VARIABLES:
     */
    //Delay line structures
    //static DelayLine *upper_rail=(DelayLine*)malloc(sizeof(DelayLine));
    //static DelayLine *lower_rail=(DelayLine*)malloc(sizeof(DelayLine));
    static DelayLine *upper_rail, *lower_rail;
    
    /*
     PRIVATE METHODS
     */
    
    inline static void setDelayLine(DelayLine *dl, double *values, double scale){
        int i;
        for (i = 0; i < dl->length; i++) {
            dl->data[i] = DOUBLE_TO_SHORT(scale * values[i]);
        }
    }
    
    static inline void lg_dl_update(DelayLine *dl, short insamp){
        short *ptr = dl->pointer;
        *ptr = insamp;
        
        ptr++;
        if (ptr > dl->end) {
            ptr = dl->data;
            dl->pointer = ptr;
        }
    }
    
    static inline void rg_dl_update(DelayLine *dl, short insamp){
        short *ptr = dl -> pointer;
        ptr--;
        
        if (ptr < dl->data) {
            ptr =dl->end;
        }
        *ptr = insamp;
        dl->pointer = ptr;
    }
    
    static inline short dl_access(DelayLine *dl, int position){
        short *outloc = dl->pointer + position;
        while (outloc < dl->data) {
            outloc += dl->length;
        }
        while (outloc > dl->end) {
            outloc -= dl->length;
        }
        return *outloc;
    }
    
    
    
    static inline short rg_dl_access(DelayLine *dl, int position){
        return dl_access(dl, position);
    }
    
    static inline short lg_dl_access(DelayLine *dl, int position){
        return dl_access(dl, position);
    }
    
    
    
    static inline void freeString(void){
        freeDelayLine(upper_rail);
        freeDelayLine(lower_rail);
    }
    
    static inline short bridgeReflection(int insamp){
        static short state = 0; //filter memory
        /*Implement a one-pole lowpass with feedback coeficcient = 0.5*/
        /*outsamp = 0.5 *outsamp + 0.5 * insamp*/
        short outsamp = (state>>1)+ (insamp >>1);
        state = outsamp;
        
        //printf("state=%x\ninsamp=%x\noutsamp=%x\n\n",state,insamp,outsamp);
        //printf("state=%d\ninsamp=%d\noutsamp=%d\n\n",state,insamp,outsamp);
        
        return outsamp;
        
    }
 
    

};

#endif /* defined(__DigitalWaveGuide__DigitalWaveGuide__) */
