
import numpy as np
from pylab import *
import wave
import struct
import pyaudio

'''Utility functions '''

def pcm2Float(sig, dtype=np.float64):
    """
       Converts a PCM signal into a floating point signal with a range between -1 and 1

    """
    # TODO: allow unsigned (e.g. 8-bit) data
    sig = np.asarray(sig)  # make sure it's a NumPy array
    assert sig.dtype.kind == 'i', "'sig' must be an array of signed integers!"
    dtype = np.dtype(dtype)  # allow string input (e.g. 'f')

    # Note that 'min' has a greater (by 1) absolute value than 'max'!
    # Therefore, we use 'min' here to avoid clipping.
    return sig.astype(dtype) / dtype.type(-np.iinfo(sig.dtype).min)




'''Extract data from wav file'''
w=wave.open('astrud.wav','r')
numberOfChannels=w.getnchannels()
sampleWidth=w.getsampwidth()
frequencySampleRate=w.getframerate()
numberOfFrames=w.getnframes()
rawData=w.readframes(numberOfFrames)


"""Re-order the data into groups of 2 bytes integers(intelligible PCM data)"""
pcmData=np.frombuffer(rawData, dtype='<i2').reshape(-1, numberOfChannels)
#plot(pcmData)
#show()

'''Normalize the pcmData'''
normData=pcm2Float(pcmData)
#plot(normData)
#show()

'''Create a sine signal to perform a tremolo effect'''
Fs=44100                #Frequencia de muestreo
samples=numberOfFrames  #Numero de muestras
w=2*pi/Fs               #Velocidad angular... w=2pi/f
f=5                  #Frequency of signal
x=arange(0.0,(w*samples),w)    #Generacion de variable independiente (eje x)En radianes
y=((1+sin(x*f))/2)

'''Perform the amplitud modulation'''
for i in range(len(normData)):
    normData[i]=normData[i]*y[i]


'''After processing, data should be converted from normalized to PCM.
 First is organized in 2 byte integers (PCM format'''
normData=normData*(-32767)
outData=normData.astype(np.int16)
#plot(outData)
#show()


'''Then is packet '''
fmt='<%ih'%samples
out=struct.pack(fmt,*outData)

'''Finally we can use pyAudio to play the resulting packet: out'''
#instantiate PyAudio
p = pyaudio.PyAudio()
#open stream
stream = p.open(format = p.get_format_from_width(2), channels = 1, rate = Fs, output = True)

stream.write(out)


stream.stop_stream()
stream.close()

#close PyAudio
p.terminate()

