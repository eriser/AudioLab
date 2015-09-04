//
//  Oscillator.cpp
//  Synth_Osc
//
//  Created by Ness on 7/18/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#include "Oscillator.h"

///--- CONSTRUCTOR
COscillator::COscillator(void){
    ///--- Initialize variables
    m_dSampleRate = 44100;                  // Default Fs
    m_bNoteOn = false;                      // Any note being played
    m_dModulo = 0.0;                        // modulo of the basic saw trivial Oscillator
    m_dDPWSquareModulator = -1.0;           // Square Oscillator for triangle wave (DPW)
    m_dInc = 0.0;                           // Set increment
    m_dOscFo = OSC_FO_DEFAULT;              // A5---440 HZ
    m_dAmplitude = 1.0;                     // default ON
    m_dPulseWidth = OSC_PULSEWIDTH_DEFAULT;         //%50
    m_dPulseWidthControl = OSC_PULSEWIDTH_DEFAULT; // %50 (from GUI)
    m_dFo = OSC_FO_DEFAULT;                 // A5---440 HZ

    srand(time(NULL));                      // Seed random number generation
    
    m_uPNRegister = rand();                 // For noise
    m_nRSHCounter = -1;                     // Flag for reset condition
    m_dRSHValue = 0.0;
    m_dAmpMod = 1.0;                        // note default to 1 to avoid silent osc
    
    // No frequency modulation
    m_dFoModLin = 0.0;
    m_dFoMod = 0.0;
    m_dPitchBendMod = 0.0;
    m_dPWMod = 0.0;
    m_nOctave = 0.0;
    m_nSemitones = 0.0;
    m_nCents = 0.0;
    m_dFoRatio = 1.0;

    m_uLFOMode = 0;                         //Default for low frequency oscillator
    m_uWaveform = SINE;                     // Default for pitched oscillator
    m_dPhaseMod = 0.0;
    //m_uMIDINoteNumber = 0;
}

// --- Destructor
COscillator::~COscillator(void)
{
}


//--- VIRTUAL FUNCTION: RESET()
        /* 
         CAUTION: This function should be implemented properly in child classes,
                  reset() being applied without certain fixes (specific from each wave)
                  can cause glitches at the beginning and end of a note event.
         
                  For example: 
                                /\      /\.../......reset() applied at the middle of note event
                               /  \    / |  /       can produce a discontinuity. This can be handled
                              /    \  /  | /        by using the envelope generators
                             /      \/   |/
         
         */
void COscillator::reset()
{
    //--- Pitched modulos, wavetables start at 0.0
    //This needs to be done in the child class
    //m_dModulo = 0.0;
    
    // --- needed fror triangle algorithm, DPW
    //m_dDPWSquareModulator = -1.0;
    
    // --- flush DPW registers
    //m_dDPW_z1 = 0.0;
    
    // --- modulation variables
    m_dAmpMod = 1.0;                    //**** note default to 1 to avoid silent osc
    m_dPWMod = 0.0;
    m_dPitchBendMod = 0.0;
    m_dFoMod = 0.0;
    m_dFoModLin = 0.0;
    m_dPhaseMod = 0.0;
}