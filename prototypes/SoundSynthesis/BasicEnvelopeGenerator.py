__a__author__ = 'Ness'
from pylab import *
from numpy import *


''' ----Background
The envelope generators are incharge of the modulation of the sound amplitude in
4 main stages during the sound life cycle.

_____________________________________________   For a basic functional prototype, this module requires of
| Attack                                    |   4 basic input values of time which define the duration of
|1        /\Decay                            |   each stage PLUS the sustain level value(from 0 to 1)
|.       /  \                                |
|.      /    \                               |
|.     /      \   sustain                    |
|.    /        \_____________                |
|.   /                       \  Realease     |
|0  /                         \              |
|___________________________________________|
    |       |       |       |         |
    A       D       S       R   SustainLevel


'''

''' functions for the Iterative exponential method'''
''' Attack'''
def IterativeExp_AttackParameters(samples):
    #caculate the exponential coefficient
    attackCoefficient=exp((-math.log((1.0+TCO_attack)/TCO_attack))/samples)
    #calculate the offset
    attackOffset=(1.0+TCO_attack)*(1.0-attackCoefficient)
    return (attackCoefficient, attackOffset)

def IterativeExp_CreateAttackSignal(samples,coefficient, offset):
    y=zeros(samples)
    y[0]=offset
    for i in range(1, samples):
        y[i]=offset+coefficient*y[i-1]

    return y
''' Decay'''
def IterativeExp_DecayParameters(samples):
    #caculate the exponential coefficient
    decayCoefficient=exp((-math.log((1.0+TCO_decay)/TCO_decay))/samples)
    #calculate the offset
    decayOffset=(SustainLevel-TCO_decay)*(1.0-decayCoefficient)
    return(decayCoefficient, decayOffset)

def IterativeExp_CreateDecaySignal(samples,coefficient, offset):
    y=zeros(samples)
    y[0]=1.0
    for i in range(1, samples):
        y[i]=offset+coefficient*y[i-1]
    return y

''' Release'''
def IterativeExp_ReleaseParameters(samples):
    #caculate the exponential coefficient
    releaseCoefficient=exp((-math.log((1.0+TCO_release)/TCO_release))/samples)
    #calculate the offset
    releaseOffset= TCO_release*(1.0-releaseCoefficient)
    return  (releaseCoefficient,releaseOffset)

def IterativeExp_CreateReleaseSignal(samples, coefficient, offset):
    y=zeros(samples)
    y[0]=1.0*SustainLevel
    for i in range(1, samples):
        y[i]=offset+coefficient*y[i-1]
    return y


''' Utility functions'''
def timeToSamples(time, sampleRate=44100):
    samples=time/(1.0/sampleRate)
    return int(samples)


'''Input values from User Interface'''
AttackTime=1.0       #AttackTime in seconds
DecayTime=0.20       #DecayTime in seconds
SustainTime=0.50     #SustainTime in seconds: In practice, this time is given by the duration of the user pressing the key
ReleaseTime=0.20     #ReleaseTime in seconds

SustainLevel=0.80

''' Pre-defined values'''
Fs=100                   #Sample rate in Hertz
TCO_attack=exp(-1.5)    #goes from %0 to %77 in 1 time constant (tau here is normalized to 1)
TCO_decay=exp(-4.95)
TCO_release=exp(-4.95)  #goes down in 1 time constant



def main():

    #start using the iterative exponential method

    #attack curve
    #get the number of samples for the attack curve
    attackSamples=timeToSamples(AttackTime,Fs)
    #get the coefficient and the offset for the iterative model
    attackParameters=IterativeExp_AttackParameters(attackSamples)
    #Perform the method
    y_attack=IterativeExp_CreateAttackSignal(attackSamples,attackParameters[0],attackParameters[1])

    #decay curve
    decaySamples=timeToSamples(DecayTime,Fs)
    decayParameters=IterativeExp_DecayParameters(decaySamples)
    y_decay=IterativeExp_CreateDecaySignal(decaySamples,decayParameters[0],decayParameters[1])

    #sustain curve
    sustainSamples=timeToSamples(SustainTime,Fs)
    y_sustain=ones(sustainSamples)*SustainLevel

    #release curve
    ##get the number of samples for the release curve
    releaseSamples=timeToSamples(ReleaseTime,Fs)
    #get the coefficient and the offset for the iterative model
    releaseParameters=IterativeExp_ReleaseParameters(releaseSamples)
    y_release=IterativeExp_CreateReleaseSignal(releaseSamples,releaseParameters[0],releaseParameters[1])


    fig=figure(1)
    title('Construction of attack, decay,sustain and release phases')
    graph1=fig.add_subplot(511)
    axis1=arange(0,attackSamples,1)
    graph1.bar(axis1,y_attack,0.1, facecolor='purple')


    graph2=fig.add_subplot(512)
    axis2=arange(0,decaySamples,1)
    graph2.bar(axis2,y_decay,0.1, facecolor='blue')

    graph3=fig.add_subplot(513)
    axis3=arange(0,sustainSamples,1)
    graph3.bar(axis3,y_sustain,0.1, facecolor='black')

    graph4=fig.add_subplot(514)
    axis4=arange(0, releaseSamples,1)
    graph4.bar(axis4,y_release,0.1,facecolor='red')


    graph5=fig.add_subplot(515)
    y=concatenate((y_attack,y_decay,y_sustain,y_release))
    axis5=arange(0,size(y),1)
    graph5.bar(axis5,y,0.1,facecolor='green')

    show()


if __name__=="__main__":main()



