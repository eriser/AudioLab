__author__ = 'Ness'
from numpy import *
from pylab import *
import wave
import struct
import pyaudio

'''///////////////////////////////////
//////////////Utility functions///////'''

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

def readWav(wavFile):
    '''Extract data from wav file'''
    w=wave.open(wavFile,'r')
    numberOfChannels=w.getnchannels()
    sampleWidth=w.getsampwidth()
    frequencySampleRate=w.getframerate()
    numberOfFrames=w.getnframes()
    print("numberOfChannels{}".format(numberOfChannels))
    rawData=w.readframes(numberOfFrames)
    '''Re-order the data into groups of 2 bytes integers(intelligible PCM data)'''
    pcmData=np.frombuffer(rawData, dtype='<i2').reshape(-1, numberOfChannels)
    '''Normalize the pcmData'''
    normData=pcm2Float(pcmData)

    return normData

def myReorderFunc(x):
    y=zeros(size(x))
    for i in range(0,size(x)):
        y[i]=x[i]
    return y




''' Mth order All-pass filter
   x is the input signal
   a is the filter coefficient
   M is the filter order

    The filter implements the difference equation
        y(n)=a*x(n)+x(n-M)-a*y(n-M)
'''
def AllPassFilter(a,x,M):
    N=size(x)                               #Store the length  of the input signal

    '''Prepare to implement the difference equation'''
    x_delay=zeros(M)
    x_delay=append(x_delay,x)        #Delay the input signal by M: x(n-M)
    delay=zeros(M)
    x=append(x,delay)               #Add the same number of zeros to keep the same length
    y=zeros(N)                              #This is the output signal
    '''
    With the next command we obtain the first M values of the difference
    equation by the sum of the input signals x and x_delay. We can simply
    add this input terms using the fact that for the first M calculation the
    feedback term a*y(n-M)is zero
    '''
    y[0:M] = a * x[0:M] + x_delay[0:M]
    '''
    The next loop will obtaining the rest of the values of the output vector y.
    At this moment we can take in count the feedback term y(n-M):
    vector y will be filled from y(M+1)to y(N)
    '''
    for n in range(M+1,N):
        y[n]=a*x[n]+x_delay[n]-a*y[n-M]

    return y        # The allpass filter has been implemented


def FeedFowardCombFilter(b,x,M):
    N=size(x)
    '''Prepare to implement the difference equation'''
    x_delay=zeros(M)
    x_delay=append(x_delay,x)        #Delay the input signal by M: x(n-M)
    delay=zeros(M)
    x=append(x,delay)               #Add the same number of zeros to keep the same length
    '''This commmand  will create the output vector with the filtered input
        signal'''
    y=zeros(N)
    '''Filter implementation'''
    y[0:N]=x[0:N]+b*x_delay[0:N]

    return y
def playWav(x):
    '''After processing, data should be converted from normalized to PCM.
        First is organized in 2 byte integers (PCM format)'''
    PCMData=x*(-32767)
    outData=PCMData.astype(np.int16)
    '''Then is packet '''
    fmt='<%ih'%size(x)
    out=struct.pack(fmt,*outData)
    '''Play with PyAudio '''
    #instantiate PyAudio
    p = pyaudio.PyAudio()
    #open stream
    stream = p.open(format = p.get_format_from_width(2), channels = 1, rate = 44100, output = True)

    stream.write(out)


    stream.stop_stream()
    stream.close()

    #close PyAudio
    p.terminate()

def main():
    input=myReorderFunc(readWav('astrud.wav'))
    ''' Serial configuration of allpass filters'''
    y_allpass=AllPassFilter(0.7,input,1051)
    y_allpass=AllPassFilter(0.7,y_allpass,337)
    y_allpass=AllPassFilter(0.7,y_allpass,113)

    ''' Parallel configuration of comb filters'''
    y_comb1=FeedFowardCombFilter(0.742,y_allpass,4799)
    y_comb2=FeedFowardCombFilter(0.733,y_allpass,4999)
    y_comb3=FeedFowardCombFilter(0.715,y_allpass,5399)
    y_comb4=FeedFowardCombFilter(0.697,y_allpass,5801)
    y=y_comb1+y_comb2+y_comb3+y_comb4
    #y=y/abs(max(y))
    y=y/2.0         #Suppose 2 is the max value you'll get

    print(size(y))
    fig=figure(1)
    ax=arange(0,size(input),1)

    graph1=fig.add_subplot(211)
    graph1.plot(ax,input)
    title('original input')

    graph2=fig.add_subplot(212)
    graph2.plot(ax,y)
    title('Signal after Reverb')



    playWav(y)
    show()

if __name__== "__main__":main()


