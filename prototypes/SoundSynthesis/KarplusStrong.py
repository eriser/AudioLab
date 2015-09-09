__author__ = 'Ness'
#python 2.7.5


from numpy import *
from pylab import *
import wave
import struct
import pyaudio

#Set the sample rate and fundamental frequency
Fs=44100
f=220

#Loss factor
rho=0.99

#Calculate the correspondant delay line length in samples
N=int(round(Fs/f))   #N=401
#length of output vector
M=80000

#Dynamics filter Coefficient
R=0.95



#Creation of random numbers between -1 and 1 in a vector 'u' of length N
u=zeros(N)
for i in range(0,N):
    u[i]=1+(-2)*random()


#Apply the dynamics filter and storage the processed signal in vector x
x=zeros(M)
for n in range(1,N):
    x[n]=(1-R)*u[n]+R*x[n-1]

fig=figure(1)
graph1=fig.add_subplot(211)
ax1=arange(0,N,1)
graph1.plot(ax1,x[0:N])

#Prepare for the karplus strong filter
#y(n)=x(n)+rho*(1/2)*(y(n-N)+y(n-(N+1)))

#The output signal will be of length(N+M)
y=zeros(N+M)
#Initialise the first N samples of y to be equal to the first samples of x
y[0:N]=x[0:N]

#The equation contains feedback in the term "y(n-N)+y(n-(N+1))"  This feedback will be zero until n>N
# when n=N+1, The first feedback term y(n-N) will find a valid element in the matrix.
# But the second term y(n-(N+1)) will be zero, so implement the first new value: y(N+1)=x(N+1) + rho* (y(1)/2 + 0);
y[N+1]= x[N+1] +rho *(y[1]/2 + 0)
#The next command will complete the calculation of the output vector.
# Starting at the index value n=N+2, the feedback terms
# will find valid elements along the matrix.
for n in range(N+2,M):
    y[n]= x[n] + rho*(  ( y[n-N]+ y[n-(N+1)] )/2 );

#Normalize the data
y=y/max(abs(y))
graph2=fig.add_subplot(212)
ax2=arange(0,size(y))
graph2.plot(ax2,y)
#show()
print("N={}\nM={}\nlength_U={}\noutput={}".format(N,M,size(u),size(y)))
#The current y contains the synthesized sound in float format, We need to create a wav file to hear it
#Convert from normalized float data to PCM
#First is organized in 2 byte integers (PCM format)
y=y*(-32767)
outData=y.astype(np.int16)
#Pack the data
fmt='<%ih'%size(y)
out=struct.pack(fmt,*outData)
"""Finally we can use pyAudio to play the resulting packet: out"""

#instantiate PyAudio
p = pyaudio.PyAudio()
#open stream
stream = p.open(format = p.get_format_from_width(2), channels = 1, rate = Fs, output = True)

stream.write(out)


stream.stop_stream()
stream.close()

#close PyAudio
p.terminate()

show()