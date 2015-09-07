//
//  VAOnePoleFilter.cpp
//  Synth_Osc
//
//  Created by Ness on 7/23/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#include "VAOnePoleFilter.h"
#include <iostream>
CVAOnePoleFilter::CVAOnePoleFilter(void)
{
    // --- init defaults to simple
    //	   LPF/HPF structure
    m_dAlpha = 1.0;
    m_dBeta = 0.0;
    m_dZ1 = 0.0;
    m_dGamma = 1.0;
    m_dDelta = 0.0;
    m_dEpsilon = 0.0;
    m_da0 = 1.0;
    m_dFeedback = 0.0;
    
    // --- always set the default!
    m_uFilterType = LPF1;
    
    // --- flush storage
    reset();
}

CVAOnePoleFilter::~CVAOnePoleFilter(void)
{
}


void CVAOnePoleFilter::update()
{
    // base class does modulation (Calculate the changes on m_fFc)
    CFilter::update();
    // Wrapping frequecies to obtain Feed Foward gain (G)
    // (this value is recalculated often due the frequency modulation)
    double wd = 2*pi*m_dFc;         
    double T  = 1/m_dSampleRate;
    double wa = (2/T)*tan(wd*T/2);
    double g  = wa*T/2;
    
    m_dAlpha = g/(1.0 + g);     //G
}



/*
 x[n]---->(∑)--->(G)-|--->(∑)-------|--->Ylowpass
           ^(-)      |     ^        |
           |         |     |        |
           |_________|_____* S(n)   |
                     |     |        |
                     |     |        |
                     |--->[Z]<------|
 */

double CVAOnePoleFilter::doFilter(double xn){
    // return xn if filter not supported
    if(m_uFilterType != LPF1 && m_uFilterType != HPF1)
        return xn;
    
    // for diode filter support
    //xn = xn*m_dGamma + m_dFeedback + m_dEpsilon*getFeedbackOutput();

    //     v(n)=    G     * (  X      -   S  )
    double vn  = m_dAlpha * (m_da0*xn - m_dZ1);     //Calculate input V
   
    //     Ylp = V  +   S
    double lpf = vn + m_dZ1;                        //Calculate first output (register Z is empty the first time)
    
    //      S   = Ylp +  V
          m_dZ1 = lpf +  vn;                        //Update register Z

    // do the HPF
    //     Yhp =  X - Ylp
    double hpf = xn - lpf;
    
    //return what the user states in GUI
    if(m_uFilterType == LPF1){
        return lpf;
    }else if(m_uFilterType == HPF1){
        //printf("flag ");
        return hpf;
    }
    
    //printf("flag ");
    return xn;      //will never reach this point
}