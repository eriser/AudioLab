//
//  CQBLimitedOscillator.cpp
//  Synth_Osc
//
//  Created by Ness on 7/18/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#include "CQBLimitedOscillator.h"
CQBLimitedOscillator::CQBLimitedOscillator(void)
{
}

CQBLimitedOscillator::~CQBLimitedOscillator(void)
{
}


void CQBLimitedOscillator::reset()
{
    COscillator::reset();
    
//    if(m_uWaveform==TRI){
//        //Triangle needs a special reboot
//        //m_dModulo = 0.0;
//    }
//    //--- saw/tri starts at 0.5
//    if(m_uWaveform == SAW1 || m_uWaveform == SAW2 ||
//       m_uWaveform == SAW3 || m_uWaveform == TRI)
//    {
//        //m_dModulo = 0.5;
//    }
}

void CQBLimitedOscillator::startOscillator()
{   /*****CAUTION!!!!******/
    reset();
    m_bNoteOn = true;
}

void CQBLimitedOscillator::stopOscillator()
{
    m_bNoteOn = false;
}
