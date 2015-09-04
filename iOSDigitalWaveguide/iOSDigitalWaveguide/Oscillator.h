//
//  Oscillator.h
//  Synth_Osc
//
//  Created by Ness on 7/18/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//


#pragma once
#include "pluginconstants.h"
#include "synthfunctions.h"

#define OSC_FO_MOD_RANGE 2			//2 semitone default
#define OSC_HARD_SYNC_RATIO_RANGE 4	//
#define OSC_PITCHBEND_MOD_RANGE 12	//12 semitone default
#define OSC_FO_MIN 20				//20Hz
#define OSC_FO_MAX 20480			//20.480kHz = 10 octaves up from 20Hz
#define OSC_FO_DEFAULT 440.0		//A5
#define OSC_PULSEWIDTH_MIN 2		//2%
#define OSC_PULSEWIDTH_MAX 98		//98%
#define OSC_PULSEWIDTH_DEFAULT 50	//50%

class COscillator{
    
public:
/////-----> CONSTRUCTOR / DESTRUCTOR    
            COscillator(void);
            virtual ~COscillator(void);
/////-----> OSCILLATOR VARIABLES
            /*  The values of these variables are controller from
                the Graphic User Interface. */

            //---   Oscillator run flag
            bool m_bNoteOn;
            //---   Oscillator Math parameters
            double m_dOscFo;        // Oscillator Frequency (From keyboard Controller)
            double m_dAmplitude;    // 0->1 from GUI
            double m_dFoRatio;    // FM Synth Modulator OR Hard Sync ratio
    
            //---   Controls the Pulse Width Modulation in % (Only for square wave)
            double m_dPulseWidthControl;
    
            //---   Modulo counter and inc for timebase
            double m_dModulo;		// modulo counter 0->1
            double m_dInc;			// phase inc = fo/fs
    
            //---   Pitch Modes (These have an effect in the final oscillator frequency)
            int m_nOctave;			// octave tweak
            int m_nSemitones;		// semitones tweak
            int m_nCents;			// cents tweak
    
            //--- Enums for wave selections
            //--- for PITCHED Oscillators
            enum {SINE,SAW1,SAW2,SAW3,TRI,SQUARE,NOISE,PNOISE};
            UINT m_uWaveform;	// to store type
    
            //--- for LFOs
            enum {sine,usaw,dsaw,tri,square,expo,rsh,qrsh};
    
            //--- for LFOs - MODE
            enum {sync,shot,free};
            UINT m_uLFOMode;	// to store MODE
    
            // --- MIDI note that is being played
            //UINT m_uMIDINoteNumber;

protected:
/////-----> VARIABLES USED FOR INNER CALCULATIONS
        /*  This variables will be used for the child classes to implement
         algorithms like the: Blep algortihm.... */
    
        double m_dSampleRate;	// Sample Rate (Fs is DSP literature) Base of many calculations
        double m_dFo;			// Real current frequency of oscillator (from calculations of inputs parameters)
        double m_dPulseWidth;	// pulse width in % for calculation
    
        //--- for noise and random sample/hold
        UINT   m_uPNRegister;	// for PN Noise sequence
        int    m_nRSHCounter;	// random sample/hold counter
        double m_dRSHValue;		// currnet rsh output
    
        //--- for Triangle (Differentiated Parabolic Waveform, DPW)
        double m_dDPWSquareModulator;	// square toggle
        double m_dDPW_z1; // memory register for differentiator
    
        //--- Frequency mondulation inputs
        double m_dFoMod;			/* Change from GUI (LFO as modulation input)  [-1...+1] */
        double m_dPitchBendMod;	    /* A controller from GUI serves as modulation input [-1...+1] */
        double m_dFoModLin;			/* A controller from GUI serves as modulation input--not linear [-1 to +1] */
        double m_dPWMod;			/* (only for square wave) modulation input for PWM [-1 to +1] */
        double m_dPhaseMod;			/* Phase modulation input -1 to +1 (used for DX synth) */

        //--- Amplitude modulation
        double m_dAmpMod;			/* output amplitude modulation for AM 0 to +1 (not dB)*/
    
public:
/////-----> OSCILLATOR FUNCTIONS
            /*  All the oscillators functions are PUBLIC. 
                They contain a wide range of utility operations. mainly getters, setters
                and check-operations to control the trivial oscillators used as base of the algorithms.
                Special attention to: update(), reset() and doOscillate().
             */
    
        //--- Base Sawtooth trivial oscillator operations
        inline void incModulo(){m_dModulo += m_dInc;}               // Increments modulo counter
        inline void resetModulo(double d = 0.0){m_dModulo = d;}     // Resets modulo counter
        inline bool checkWrapModulo()                               //--- Maintains the limits between [-1..+1]
        {
            //--- for positive frequencies
            if(m_dInc > 0 && m_dModulo >= 1.0)
            {
                m_dModulo -= 1.0;
                return true;
            }
            //--- for negative frequencies
            if(m_dInc < 0 && m_dModulo <= 0.0)
            {
                m_dModulo += 1.0;
                return true;
            }
            return false;
        }

    
        //--- Amplitude and Frequency Modulation operations
        inline void setAmplitudeMod(double dAmp){m_dAmpMod = dAmp;}  //Amplitude Mod [0->1], not DB
        inline void setFoModExp(double dMod){m_dFoMod = dMod;}      //Exponential Mod
        inline void setPitchBendMod(double dMod){m_dPitchBendMod = dMod;}//From pitchBend controller
        inline void setPWMod(double dMod){m_dPWMod = dMod;}         //Pulse Width Mod
        inline void setPhaseMod(double dMod){m_dPhaseMod = dMod;}

/////-----> VIRTUAL FUNCTIONS
    
    ////---> PURE ABSTRACT: derived class MUST implement
    
        //--- start/stop control
        virtual void startOscillator() = 0;
        virtual void stopOscillator() = 0;
    
        //--- Render
        //		    for LFO: pAuxOutput = QuadPhaseOutput
        //			Pitched: pAuxOutput = Right channel (return value is left Channel)
        virtual double doOscillate(double* pAuxOutput = NULL) = 0;
    
    
    ////---> ABSTRACT: derived class overrides if needed
    
        virtual void setSampleRate(double dFs){m_dSampleRate = dFs;}    //Set the Fs value
        virtual void reset();                                           //reset counters, etc...
    
////---> INLINE FUNCTIONS
        /*  these are inlined because they will be
            called every sample period
            (You may want to move them to the .cpp file and
            enable the compiler Optimization setting for
            Inline Function Expansion)
         */
    
        inline virtual void update(){
            // --- ignore LFO mode for noise sources
            if(m_uWaveform == rsh || m_uWaveform == qrsh)
                m_uLFOMode = free;
            
            // Calculate the final oscillator frequency using all frequency mod parameters
            m_dFo = m_dOscFo*m_dFoRatio*pitchShiftMultiplier(m_dFoMod +
                                                             m_dPitchBendMod +
                                                             m_nOctave*12.0 +
                                                             m_nSemitones + 
                                                             m_nCents/100.0);

            m_dFo += m_dFoModLin;                           // Apply linear FM (Effect on the overall Freq)
            
            // Protect the limits of the Oscillation frequency  (+/- 20480)
            if(m_dFo > OSC_FO_MAX)
                m_dFo = OSC_FO_MAX;
            if(m_dFo < -OSC_FO_MAX)
                m_dFo = -OSC_FO_MAX;
            
            // Calculate increment (a.k.a. phaseIncrement)
            m_dInc = m_dFo/m_dSampleRate;
            
            // Pulse Width Modulation
            m_dPulseWidth = m_dPulseWidthControl + m_dPWMod*(OSC_PULSEWIDTH_MAX - OSC_PULSEWIDTH_MIN)/OSC_PULSEWIDTH_MIN;
            // Protect limits  [2% <---> 98%]
            m_dPulseWidth = fmin(m_dPulseWidth, OSC_PULSEWIDTH_MAX);
            m_dPulseWidth = fmax(m_dPulseWidth, OSC_PULSEWIDTH_MIN);

        }

};


