//
//  synthfunctions.h
//  Synth_Osc
//
//  Created by Ness on 7/18/15.
//  Copyright (c) 2015 Ness. All rights reserved.
//

#pragma once

#include <stdlib.h>
#include <time.h>
#include <math.h>

#define ARC4RANDOMMAX 4294967295 // (2^32 - 1)
#define CONVEX_LIMIT 0.00398107
#define CONCAVE_LIMIT 0.99601893


typedef unsigned int        UINT;
#define  pi 3.1415926535897932384626433832795


//For noise sequence
#define EXTRACT_BITS(the_val, bits_start, bits_len) ((the_val >> (bits_start - 1)) & ((1 << bits_len) - 1))

//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////              OSCILLATORS            ////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////


/* bipolarToUnipolar()
	
	calculates the unipolar (0 -> 1) value from a bipolar (-1 -> +1) value
	
	dValue = the value to convert
 */
inline double bipolarToUnipolar(double dValue)
{
    return 0.5*dValue + 0.5;
}

/* concaveInvertedTransform()
	
	calculates the concaveInvertedTransform of the input
	
	dValue = the unipolar (0 -> 1) value to convert
 */
inline double concaveInvertedTransform(double dValue)
{
    if(dValue <= CONVEX_LIMIT)
        return 1.0;
    
    return -(5.0/12.0)*log10(dValue);
}



/*  This functions calculates the appropiate change in the oscillator frequency
    caused by a frequency shift from the user interface. Remember this tweaks can be:
            -LF0
            -Octave
            -Semitone
            -Cent
 */
inline double pitchShiftMultiplier(double dPitchShiftSemitones)
{
    if(dPitchShiftSemitones == 0)
        return 1.0;
    // 2^(N/12)
    //	return fastPow(2.0, dPitchShiftSemitones/12.0);
    return pow(2.0, dPitchShiftSemitones/12.0);
}

/*
    Used if the phase modulation (m_dPhaseMod) has a value other than 0
    This functions wraps the modulo used as phase for the waves
 
 */
inline void checkWrapIndex(double& dIndex)
{
    while(dIndex < 0.0)
        dIndex += 1.0;
    
    while(dIndex >= 1.0)
        dIndex -= 1.0;
}

/*
    Parabolic approximation to a sine signal
 */
const double B = 4.0/(float)pi;
const double C = -4.0/((float)pi*(float)pi);
const double P = 0.225;
// http://devmaster.net/posts/9648/fast-and-accurate-sine-cosine
// input is -pi to +pi
inline double parabolicSine(double x, bool bHighPrecision = true)
{
    double y = B * x + C * x * fabs(x);
    
    if(bHighPrecision)
        y = P * (y * fabs(y) - y) + y;
    
    return y;
}


/*
    Converts the range from [0 ... +1] to [-1 ... +1]
 */
inline double unipolarToBipolar(double dValue)
{
    return 2.0*dValue - 1.0;
}

inline double doWhiteNoise()
{
    float fNoise = 0.0;
    // fNoise is 0 -> ARC4RANDOMMAX
    fNoise = (float)arc4random();
    
    // normalize and make bipolar
    fNoise = 2.0*(fNoise/ARC4RANDOMMAX) - 1.0;
    
    return fNoise;
    
}
inline double doPNSequence(UINT& uPNRegister)
{
    // get the bits
    UINT b0 = EXTRACT_BITS(uPNRegister, 1, 1); // 1 = b0 is FIRST bit from right
    UINT b1 = EXTRACT_BITS(uPNRegister, 2, 1); // 1 = b1 is SECOND bit from right
    UINT b27 = EXTRACT_BITS(uPNRegister, 28, 1); // 28 = b27 is 28th bit from right
    UINT b28 = EXTRACT_BITS(uPNRegister, 29, 1); // 29 = b28 is 29th bit from right
    
    // form the XOR
    UINT b31 = b0^b1^b27^b28;
    
    // form the mask to OR with the register to load b31
    if(b31 == 1)
        b31 = 0x10000000;
    
    // shift one bit to right
    uPNRegister >>= 1;
    
    // set the b31 bit
    uPNRegister |= b31;
    
    // convert the output into a floating point number, scaled by experimentation
    // to a range of o to +2.0
    float fOut = (float)(uPNRegister)/((pow((float)2.0,(float)32.0))/16.0);
    
    // shift down to form a result from -1.0 to +1.0
    fOut -= 1.0;
    
    return fOut;
}

//---> Interpolation algorithm (used to find the value between 2 points in the IR table)
inline float dLinTerp(float x1, float x2, float y1, float y2, float x)
{
    float denom = x2 - x1;
    if(denom == 0)
        return y1; // should not ever happen
    
    // calculate decimal position of x
    float dx = (x - x1)/(x2 - x1);
    
    // use weighted sum method of interpolating
    float result = dx*y2 + (1-dx)*y1;
    
    return result;
    
}


// --- N Sample BLEP (uPointsPerSide = N)
inline double doBLEP_N(const double* pBLEPTable, double dTableLen, double dModulo, double dInc, double dHeight,
                       bool bRisingEdge, double dPointsPerSide, bool bInterpolate = false)
{
    // return value
    double dBLEP = 0.0;
    
    // t = the distance from the discontinuity
    double t = 0.0;
    
    // --- find the center of table (discontinuity location)
    double dTableCenter = dTableLen/2.0 - 1;
    
    // LEFT side of edge
    // -1 < t < 0
    for(int i = 1; i <= (UINT)dPointsPerSide; i++)
    {
        if(dModulo > 1.0 - (double)i*dInc)
        {
            // --- calculate distance
            t = (dModulo - 1.0)/(dPointsPerSide*dInc);
            
            // --- get index
            float fIndex = (1.0 + t)*dTableCenter;
            
            // --- truncation
            if(bInterpolate)
            {
                dBLEP = pBLEPTable[(int)fIndex];
            }
            else
            {
                float fIndex = (1.0 + t)*dTableCenter;
                float frac = fIndex - int(fIndex);
                dBLEP = dLinTerp(0, 1, pBLEPTable[(int)fIndex], pBLEPTable[(int)fIndex+1], frac);
            }
            
            // --- subtract for falling, add for rising edge
            if(!bRisingEdge)
                dBLEP *= -1.0;
            
            return dHeight*dBLEP;
        }
    }
    
    // RIGHT side of discontinuity
    // 0 <= t < 1
    for(int i = 1; i <= (UINT)dPointsPerSide; i++)
    {
        if(dModulo < (double)i*dInc)
        {
            // calculate distance
            t = dModulo/(dPointsPerSide*dInc);
            
            // --- get index
            float fIndex = t*dTableCenter + (dTableCenter + 1.0);
            
            // truncation
            if(bInterpolate)
            {
                dBLEP = pBLEPTable[(int)fIndex];
            }
            else
            {
                float frac = fIndex - int(fIndex);	
                if((int)fIndex+1 >= dTableLen)
                    dBLEP = dLinTerp(0, 1, pBLEPTable[(int)fIndex], pBLEPTable[0], frac);
                else
                    dBLEP = dLinTerp(0, 1, pBLEPTable[(int)fIndex], pBLEPTable[(int)fIndex+1], frac);
            }
            
            // subtract for falling, add for rising edge
            if(!bRisingEdge)
                dBLEP *= -1.0;
            
            return dHeight*dBLEP;
        } 
    }
    
    return 0.0;
}



//////////////////////////////////////////////////////////////////////////////////////////////////////////////
//////////////////////       DIGITAL CONTROLLED AMPLIFIER DCA     ////////////////////////////////////////////
//////////////////////////////////////////////////////////////////////////////////////////////////////////////
/* calculatePanValues()
	
	calculates the left and right pan values
	
	dPanMod = bipolar (-1 -> 1) pan modulation value
 
	returns are via pass-by-reference mechanism
 */
inline void calculatePanValues(double dPanMod, double& dLeftPanValue, double& dRightPanValue)
{
    //dLeftPanValue = fastcos((pi/4.0)*(dPanMod + 1.0));
    //dRightPanValue = fastsin((pi/4.0)*(dPanMod + 1.0));
    
    dLeftPanValue = cos((pi/4.0)*(dPanMod + 1.0));
    dRightPanValue = sin((pi/4.0)*(dPanMod + 1.0));
    
    dLeftPanValue = fmax(dLeftPanValue, (double)0.0);
    dLeftPanValue = fmin(dLeftPanValue, (double)1.0);
    dRightPanValue = fmax(dRightPanValue, (double)0.0);
    dRightPanValue = fmin(dRightPanValue, (double)1.0);
}