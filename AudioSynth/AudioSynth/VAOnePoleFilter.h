//
//  VAOnePoleFilter.h
//  Synth_Osc
//
//  Created by Ness on 7/23/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#pragma once
#include "Filter.h"


class CVAOnePoleFilter : public CFilter{
public:
////----> CONSTRUCTOR/DESTRUCTOR
    CVAOnePoleFilter(void);
    ~CVAOnePoleFilter(void);
    
////----> VIRTUAL ANALOG VARIABLES
////----> Trapezoidal Integrator Components
    double m_dAlpha;			// Feed Forward coeff (G)
    
    // -- ADDED for Korg35 and Moog Ladder Filter ---- //
    double m_dBeta;
    
    // -- ADDED for Diode Ladder Filter  ---- //
    double m_dGamma;		// Pre-Gain
    double m_dDelta;		// FB_IN Coeff
    double m_dEpsilon;		// FB_OUT scalar
    double m_da0;			// input gain
    // note: this is NOT being used as a z-1 storage register!
    double m_dFeedback;		// our own feedback coeff from S
    
////----> VIRTUAL ANALOG FILTER METHODS
    // provide access to set feedback input
    void setFeedback(double fb){m_dFeedback = fb;}

    
    /////-----> CFilter Overrides
    
    virtual void reset(){               // Clean register and reset feedback
        m_dZ1 = 0; m_dFeedback = 0;}

    virtual void update();              // recalc the coeff
    virtual double doFilter(double xn); // do the filter
    
protected:
    //The delay register obtained after re-arange the delay-less loop
    double m_dZ1;
};