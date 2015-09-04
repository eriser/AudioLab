//
//  EnvelopeGenerator.h
//  Synth_Osc
//
//  Created by Ness on 7/20/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#pragma once
//#include "pluginconstants.h"
#include "synthfunctions.h"
#include <iostream>

class CEnvelopeGenerator{
public:
/////-----> CONSTRUCTOR / DESTRUCTOR

    CEnvelopeGenerator(void);
    ~CEnvelopeGenerator(void);

/////-----> ENVELOPE VARIABLES

    //--- analog and digital mode
    UINT m_uEGMode;
    enum {analog, digital};
    
    //--- Envelope modes
    bool m_bResetToZero; // return to zero
    bool m_bLegatoMode;  // S-trigger
    bool m_bOutputEG;	 // true if this EG is being used to control the DCA output
    
protected:
    double m_dSampleRate;
    
    //--- current output
    double m_dEnvelopeOutput;
    
    //--- Coefficient, offset and TCO values for each state
    double m_dAttackCoeff;
    double m_dAttackOffset;
    double m_dAttackTCO;
    
    double m_dDecayCoeff;
    double m_dDecayOffset;
    double m_dDecayTCO;
    
    double m_dReleaseCoeff;
    double m_dReleaseOffset;
    double m_dReleaseTCO;
    
    //--- ADSR times from user
    double m_dAttackTime_mSec;	// att: is a time duration
    double m_dDecayTime_mSec;	// dcy: is a time to decay 1->0
    double m_dReleaseTime_mSec;	// rel: is a time to decay 1->0

    //--- this is set internally; user normally not allowed to adjust
    double m_dShutdownTime_mSec; // shutdown is a time
    
    //--- sustain is a level, not a time
    double m_dSustainLevel;
    
    //--- inc value for shutdown
    double m_dIncShutdown;
    
    // --- stage variable
    UINT m_uState;
    enum {off, attack, decay, sustain, release, shutdown};
    
/////-----> OSCILLATOR FUNCTIONS
    /*  These are the functions public to all instances. This section will contain
        a classifications of: Accessors, which will serve as layer between the GUI
        and the inner variables.
        And inline functions, which use those internal values to calculate the 
        result.
     
     */
public:
    // --- reset
    void reset();
    
    // --- function to set the time constants
    void setEGMode(UINT u);
    
    // --- calculate time params
    void calculateAttackTime();
    void calculateDecayTime();
    void calculateReleaseTime();
    
    // --- go to release state; reset counter
    void noteOff();
    
    // --- go to shutdown state
    void shutDown();

/////-----> INLINE FUNCTIONS
    /*
     Constant access to these functions to calculate the state of the envelope
     */
    // --- accessors - allow owner to get our state
    inline UINT getState() {return m_uState;}
    
    // --- is the EG active
    inline bool isActive()
    {
        if(m_uState != release && m_uState != off)
            return true;
        return false;
    }
    
    // --- can do note off now?
    inline bool canNoteOff()
    {
        if(m_uState != release && m_uState != shutdown && m_uState != off)
            return true;
        return false;
    }
    

    //--- MUTATORS: This function change the configuration of the envelope
    
    //	inline void setState(UINT u){m_uState = u;}
    inline void setSampleRate(double d){m_dSampleRate = d;}
    
    // --- called during updates
    inline void setAttackTime_mSec(double d)
    {
        m_dAttackTime_mSec = d;
        calculateAttackTime();
    }
    inline void setDecayTime_mSec(double d)
    {
        m_dDecayTime_mSec = d;
        calculateDecayTime();
    }
    inline void setReleaseTime_mSec(double d)
    {
        m_dReleaseTime_mSec = d;
        calculateReleaseTime();
    }
    // --- sustain is a level not a time
    inline void setSustainLevel(double d)
    {
        m_dSustainLevel = d;
        
        // --- sustain level affects decay
        calculateDecayTime();
        
        // --- and release, if not in release state
        if(m_uState != release)
            calculateReleaseTime();
    }
    
    // reset and go to attack state
    inline void startEG()
    {
        // --- ignore
        if(m_bLegatoMode && m_uState != off && m_uState != release){
            return;
        }
        
        
//        if(m_uState==release){
//            printf("FLAG-->");
//        }
        
        
        // --- reset and go
        /******RESET HAVES THE SAME PROBLEMS THAN THE OSCILLATORS
         WHEN THEY HAD TO BE RESETED
         ********/
        //reset();
        m_uState = attack;
        
    }
    
    // --- go to off state
    inline void stopEG()
    {
        m_uState = off;
    }
    
    // --- update params
    inline void update()
    {
        // nothing yet
        
    }
    
    /* do the envelope
     returns normal Envelope out
     optionally, can get biased output in argument
     */
    inline double doEnvelope(double* pBiasedOutput = NULL)
    {
        // --- decode the state
        //printf("%f ",m_dReleaseTime_mSec);
        //printf("%u ",getState());
        switch(m_uState)
        {
            case off:
            {
                //printf("OFF ");
                // --- output is OFF
                if(m_bResetToZero)
                    m_dEnvelopeOutput = 0.0;
                break;
            }
            case attack:
            {
                // --- render value
                m_dEnvelopeOutput = m_dAttackOffset + m_dEnvelopeOutput*m_dAttackCoeff;
                
                // --- check go to next state
                if(m_dEnvelopeOutput >= 1.0 || m_dAttackTime_mSec <= 0.0)
                {
                    m_dEnvelopeOutput = 1.0;
                    m_uState = decay;	// go to next state
                    break;
                }
                break;
            }
            case decay:
            {
                //printf("decay ");
                // --- render value
                m_dEnvelopeOutput = m_dDecayOffset + m_dEnvelopeOutput*m_dDecayCoeff;
                
                // --- check go to next state
                if(m_dEnvelopeOutput <= m_dSustainLevel || m_dDecayTime_mSec <= 0.0)
                {
                    m_dEnvelopeOutput = m_dSustainLevel;
                    m_uState = sustain;		// go to next state
                    break;
                }
                break;
            }
            case sustain:
            {
                // --- render value
                m_dEnvelopeOutput = m_dSustainLevel;
                break;
            }
            case release:
            {
                // --- render value
                m_dEnvelopeOutput = m_dReleaseOffset + m_dEnvelopeOutput*m_dReleaseCoeff;
                
                // --- check go to next state
                if(m_dEnvelopeOutput <= 0.0 || m_dReleaseTime_mSec <= 0.0)
                {
                    m_dEnvelopeOutput = 0.0;
                    m_uState = off;		// go to next state
                    break;
                }
                break;
            }
            case shutdown:
            {   //printf("SHUTDOWN ");
                if(m_bResetToZero)
                {
                    // --- the shutdown state is just a linear taper since it is so short
                    m_dEnvelopeOutput += m_dIncShutdown;
                    
                    // --- check go to next state
                    if(m_dEnvelopeOutput <= 0)
                    {
                        m_uState = off;		// go to next state
                        m_dEnvelopeOutput = 0.0; // reset envelope
                        break;
                    }
                }
                else
                {
                    // --- we are guaranteed to be retriggered
                    //     just go to off state
                    m_uState = off;
                }
                break;
            }
        }
        
        // --- set the biased (pitchEG) output if there is one
        if(pBiasedOutput)
            *pBiasedOutput = m_dEnvelopeOutput - m_dSustainLevel;
        
        // --- set the normal
        return m_dEnvelopeOutput;
    }

    
};