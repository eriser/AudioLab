//
//  Filter.h
//  Synth_Osc
//
//  Created by Ness on 7/23/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#pragma once
#include <iostream>
//#include "pluginconstants.h"
#include "synthfunctions.h"

// 46.881879936465680 semitones = semitonesBetweenFrequencies(80, 18000.0)/2.0
#define FILTER_FC_MOD_RANGE 46.881879936465680
#define FILTER_FC_MIN 80		// 80Hz
#define FILTER_FC_MAX 18000		// 18kHz
#define FILTER_FC_DEFAULT 10000	// 10kHz
#define FILTER_Q_DEFAULT 0.707	// Butterworth


class CFilter{
public:
/////-----> CONSTRUCTOR / DESTRUCTOR
    CFilter(void);
    ~CFilter(void);

/////-----> FILTER PUBLIC VARIABLES
    /*
     This variables describes the filter state and can be updated from GUI.
     These variables are common to all the type of filters. This class
     doesn't provide an accessor function to them
     */
    
    //--- User's cutoff frequency control position  [Hz]
    double m_dFcControl;
    //--- Q factor control (Appears in filters of second order or highest)
    double m_dQControl;
    // --- for an aux filter specific like SEM BSF
    //     control or paasband gain comp (Moog)
    double m_dAuxControl;
    //--- for NLP - Non Linear Processing
    UINT m_uNLP;
    enum{OFF,ON};  // switch enum
    //--- Saturation control
    double m_dSaturation;
    
    //--- Filter type
    UINT m_uFilterType;
    //--- This enum contains all the family of filters available
    //    (These are distributed in various child classes)
    enum{LPF1,HPF1,LPF2,HPF2,BPF2,BSF2,LPF4,HPF4,BPF4};
    
protected:
/////-----> FILTER INNER VARIABLES
    /*
     Used for basic operations and modulation
     */
    //--- Sample frequency FS
    double m_dSampleRate;
    
    //--- Cutoff frequency obtained from calculations
    double m_dFc;
    
    //--- Current value of Q (internal)
    double m_dQ;
    
    //--- our cutoff frequency modulation input
    double m_dFcMod;
    
public:
/////-----> FILTER FUNCTIONS
    
    //--- SETTERS: For frequency modulation input,sample rate and Q value
    inline void setFcMod(double d){m_dFcMod = d;}
    inline virtual void setSampleRate(double d){m_dSampleRate = d;}
    //decode the Q value (this can change from filter to filter)
    virtual void setQControl(double dQControl);
    
    
    
    //--- PURE ABSTRACT: derived class MUST implement
    virtual double doFilter(double xn) = 0;
    
    
    // --- flush buffers, reset filter
    virtual void reset();
    
    
    // --- recalculate the Fc (called after modulations)
    inline virtual void update()
    {
        // --- update Q (filter-dependent)
        setQControl(m_dQControl);
        
        // --- do the modulation freq shift
        m_dFc = m_dFcControl*pitchShiftMultiplier(m_dFcMod);
        //printf("%f ",m_dFc);
        // --- bound the final frequency
        if(m_dFc > FILTER_FC_MAX)
            m_dFc = FILTER_FC_MAX;
        if(m_dFc < FILTER_FC_MIN)
            m_dFc = FILTER_FC_MIN;
    }
    
    
};