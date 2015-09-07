//
//  CQBLimitedOscillator.h
//  Synth_Osc
//
//  Created by Ness on 7/18/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#pragma once
#include "Oscillator.h"
#include <iostream>
class CQBLimitedOscillator: public COscillator{
public:
///---> CONSTRUCTOR / DESTRUCTOR
    CQBLimitedOscillator(void);
    ~CQBLimitedOscillator(void);

///---> INLINE FUNCTIONS: for real time operations ...
    
    ////////////////////////////////
    ////SAWTOOTH WAVE        ///
    ////////////////////////////////
    /*
        Bandlimited Step Function (BLEP)
        The algorithm that synthesizes a sawtooth consists in the integration of a bandlimited impulse
        response,storing that integration previous to the calculation of the sawtoot.
     
        There's another varyant named polyBLEP, which uses a polynomial ....
     */
    inline double doSawtooth(double dModulo, double dInc){
        
        double dTrivialSaw = 0.0;
        double dOut = 0.0;
        
        if(m_uWaveform == SAW1)			// SAW1 = normal sawtooth (ramp)
            dTrivialSaw = unipolarToBipolar(dModulo);
        else if(m_uWaveform == SAW2)	// SAW2 = one sided wave shaper
            dTrivialSaw = 2.0*(tanh(1.5*dModulo)/tanh(1.5)) - 1.0;
        else if(m_uWaveform == SAW3)	// SAW3 = double sided wave shaper
        {
            dTrivialSaw = unipolarToBipolar(dModulo);
            dTrivialSaw = tanh(1.5*dTrivialSaw)/tanh(1.5);
        }
        
        // --- NOTE: Fs/8 = Nyquist/4
        if(m_dFo <= m_dSampleRate/8.0)
        {
            dOut = dTrivialSaw + doBLEP_N(&dBLEPTable_8_BLKHAR[0], /* BLEP table */
                                          4096,			/* BLEP table length */
                                          dModulo,		/* current phase value */
                                          fabs(dInc),	/* abs(dInc) is for FM synthesis with negative frequencies */
                                          1.0,			/* sawtooth edge height = 1.0 */
                                          false,		/* falling edge */
                                          4,			/* 1 point per side */
                                          false);		/* no interpolation */
        }
        else // to prevent overlapping BLEPs, default back to 2-point for f > Nyquist/4
        {
            dOut = dTrivialSaw + doBLEP_N(&dBLEPTable[0], /* BLEP table */
                                          4096,			/* BLEP table length */
                                          dModulo,		/* current phase value */
                                          fabs(dInc),	/* abs(dInc) is for FM synthesis with negative frequencies */
                                          1.0,			/* sawtooth edge height = 1.0 */
                                          false,		/* falling edge */
                                          1,			/* 1 point per side */
                                          true);		/* no interpolation */
        }
        
        // --- or do PolyBLEP
        //dOut = dTrivialSaw + doPolyBLEP_2(dModulo, 
        //								  abs(dInc),/* abs(dInc) is for FM synthesis with negative frequencies */
        //								  1.0,		/* sawtooth edge = 1.0 */
        //								  false);	/* falling edge */
        
        return dOut;
    }
    ////////////////////////////////
    ////SQUARE WAVE with polyBLEP///
    ////////////////////////////////
    /*
     
     */
    inline double doSquare(double dModulo, double dInc){
        // --- sum-of-saws method
        //
        // --- pretend to be SAW1 type
        m_uWaveform = SAW1;
        
        // --- get first sawtooth output
        double dSaw1 = doSawtooth(dModulo, dInc);
        
        // --- phase shift on second oscillator
        if(dInc > 0)
            dModulo += m_dPulseWidth/100.0;
        else
            dModulo -= m_dPulseWidth/100.0;
        
        // --- for positive frequencies
        if(dInc > 0 && dModulo >= 1.0)
            dModulo -= 1.0;
        
        // --- for negative frequencies
        if(dInc < 0 && dModulo <= 0.0)
            dModulo += 1.0;
        
        // --- subtract saw method
        double dSaw2 = doSawtooth(dModulo, dInc);
        
        // --- subtract = 180 out of phase
        double dOut = 0.5*dSaw1 - 0.5*dSaw2;
        
        // --- apply DC correction
        double dCorr = 1.0/(m_dPulseWidth/100.0);
        
        // --- modfiy for less than 50%
        if((m_dPulseWidth/100.0) < 0.5)
            dCorr = 1.0/(1.0-(m_dPulseWidth/100.0)); 
        
        // --- apply correction
        dOut *= dCorr;
        
        // --- reset back to SQUARE
        m_uWaveform = SQUARE;
        
        return dOut;
    }

    
    
    ////////////////////////////////
    ////TRIANGLE WAVE with DPW  ////
    ////////////////////////////////
    /*
        The triangilar wave is synthesized using DPW (Differentiated Parabolic Waveform)
     */
    inline double doTriangle(double dModulo, double dInc, double dFo, double dSquareModulator, double* pZ_register){
//        double dOut = 0.0;
//        bool bDone = false;
        
        // bipolar conversion and squaring
        double dBipolar = unipolarToBipolar(dModulo);
        double dSq = dBipolar*dBipolar;
        
        // inversion
        double dInv = 1.0 - dSq;
        
        // modulation with square modulo
        double dSqMod = dInv*dSquareModulator;
        
        // original
        double dDifferentiatedSqMod = dSqMod - *pZ_register;
        *pZ_register = dSqMod;
        
        // c = fs/[4fo(1-2fo/fs)]
        double c = m_dSampleRate/(4.0*2.0*dFo*(1-dInc));
        
        //Reduce amplitude by %50
        return (dDifferentiatedSqMod*c)*0.5;
    }


///---> VIRTUAL OVERRIDES

    virtual void reset();
    virtual void startOscillator();
    virtual void stopOscillator();
    
    virtual inline double doOscillate(double* pAuxOutput = NULL){
        if(!m_bNoteOn)      // Verify note event
            return 0.0;

        double dOut = 0.0;  //Prepare output
        
        bool bWrap = checkWrapModulo(); //Check if basic Osc is under the limits
        
        double dCalcModulo = m_dModulo + m_dPhaseMod;   //Add the phase modulation input value
        
        if(m_dPhaseMod!=0)
            checkWrapIndex(dCalcModulo);                //You have to check again if phase mod didn't affect limits

        switch (m_uWaveform) {
            case SINE:
            {
                // calculate angle
                double dAngle = dCalcModulo*2.0*(double)pi - (double)pi;
                
                // call the parabolicSine approximator
                dOut = parabolicSine(-1.0*dAngle);
                
                break;
            }
            case SAW1:
            case SAW2:
           
            case SAW3:
            {
                // do first waveform
                dOut = doSawtooth(dCalcModulo, m_dInc);

                break;
            }
            case SQUARE:
            {
                dOut = doSquare(dCalcModulo, m_dInc);

                break;
            }
            case TRI:
            {
                // do first waveform
                if(bWrap)
                    m_dDPWSquareModulator *= -1.0;
                
                //printf("%f ",m_dDPW_z1);
                dOut = doTriangle(dCalcModulo, m_dInc, m_dFo, m_dDPWSquareModulator, &m_dDPW_z1);
                
                break;
            }
            case NOISE:
            {
                // use helper function
                dOut = doWhiteNoise();
                break;
            }
            case PNOISE:
            {
                // use helper function
                dOut = doPNSequence(m_uPNRegister);
                break;
            }
                
            default:
                break;
        }
        
        
        
        incModulo();                //Increment modulo
        if(m_uWaveform == TRI)      //Double if it is the triangle wave
            incModulo();
        
        // if Amplitude Modulation in GUI:m_dAmpMod needs to be set in update()
        if(pAuxOutput)
            *pAuxOutput = dOut*m_dAmplitude*m_dAmpMod;;
        
        // if Amplitude Modulation in GUI:m_dAmpMod needs to be set in update()
        return dOut*m_dAmplitude*m_dAmpMod;
        
    }

    
    
    
    
};