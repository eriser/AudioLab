//
//  Filter.cpp
//  Synth_Osc
//
//  Created by Ness on 7/23/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#include "Filter.h"

CFilter::CFilter(void){
    m_dSampleRate = 44100;
    m_dQControl = 1.0; // Q is 1 to 10 on GUI
    m_dFc = FILTER_FC_DEFAULT;
    m_dQ = FILTER_Q_DEFAULT;
    m_dFcControl = FILTER_FC_DEFAULT;
    
    // --- clear
    m_dFcMod = 0.0;
    m_dAuxControl = 0.0;
    m_uNLP = OFF;
    m_dSaturation = 1.0;

}

CFilter::~CFilter(void)
{
}


void CFilter::reset()
{
    // Resets different according to each filter
}

// --- optional depending on filter type
void CFilter::setQControl(double dQControl)
{
}