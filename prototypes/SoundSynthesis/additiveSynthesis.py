__author__ = 'Ness'
from pylab import figure, show
from numpy import *
import scipy.fftpack





'''
Constants
'''
freq=20;
t = arange(0.0, 1.0, 1.0/44100.0)
sineSig=sin(freq*2*pi*t)
#Number of frequency points
N=44100;
#Period
T=1.0/44100.0

fig = figure(1)
ax1 = fig.add_subplot(221)
ax1.plot(t, sineSig)
ax1.grid(True)
ax1.set_ylim( (-2,2) )
ax1.set_ylabel('Amplitude')
ax1.set_title('sine wave ')


'''
Now get the fft
'''
yf = scipy.fftpack.fft(sineSig)         #Transform
xf =linspace(0.0, 1.0/(2.0*T), N/2)     #Frequency Space
ax2=fig.add_subplot(2,2,2)
ax2.plot(xf, 2/N*abs(yf[0:N/2]))      #Normalize result
ax2.grid(True)
ax2.set_ylim( (-1,1) )
ax2.set_xlim( (0,100) )
ax2.set_title('Sine Wave at the Frequency domain')


''' Square signal made of 18 harmonics'''
squareSig=0.0
for i in range (1,18):
    if(i % 2 !=0):
        print(i)
        squareSig=squareSig+sin(i*freq*2*pi*t)* (1.0/i)

ax3 = fig.add_subplot(2,2,3)
ax3.plot(t, squareSig)
ax3.grid(True)
ax3.set_title("Square wave")
#p1.set_ylim( (-2,2) )

yf_square=scipy.fftpack.fft(squareSig)         #Transform
xf_square =linspace(0.0, 1.0/(2.0*T), N/2)     #Frequency Space
ax4=fig.add_subplot(2,2,4)
ax4.plot(xf_square, 2/N *abs(yf_square[0:N/2]))
ax4.grid(True)
ax4.set_ylim( (-1,1) )
ax4.set_xlim( (0,500) )
ax4.set_title("Sine square at the frequency domain")





'''
Construction of a simple square signal with additive synthesis
'''
fig2 = figure(2)
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
squareSig=0.0
for i in range (1,3):
    if(i % 2 !=0):
        print(i)
        squareSig=squareSig+sin(i*freq*2*pi*t)* (1.0/i)

p1 = fig2.add_subplot(5,1,1)
p1.plot(t, squareSig)
p1.grid(True)
#p1.set_ylim( (-2,2) )
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
squareSig=0.0
for i in range (1,6):
    if(i % 2 !=0):
        print(i)
        squareSig=squareSig+sin(i*freq*2*pi*t)* (1.0/i)

p1 = fig2.add_subplot(5,1,2)
p1.plot(t, squareSig)
p1.grid(True)
#p1.set_ylim( (-2,2) )
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
squareSig=0.0
for i in range (1,10):
    if(i % 2 !=0):
        print(i)
        squareSig=squareSig+sin(i*freq*2*pi*t)* (1.0/i)

p1 = fig2.add_subplot(5,1,3)
p1.plot(t, squareSig)
p1.grid(True)
#p1.set_ylim( (-2,2) )
''''''''''''''''''''''''''''''''''''''''''''''''''''''''''''
squareSig=0.0
for i in range (1,14):
    if(i % 2 !=0):
        print(i)
        squareSig=squareSig+sin(i*freq*2*pi*t)* (1.0/i)

p1 = fig2.add_subplot(5,1,4)
p1.plot(t, squareSig)
p1.grid(True)
#p1.set_ylim( (-2,2) )
''''''
squareSig=0.0
for i in range (1,18):
    if(i % 2 !=0):
        print(i)
        squareSig=squareSig+sin(i*freq*2*pi*t)* (1.0/i)

p1 = fig2.add_subplot(5,1,5)
p1.plot(t, squareSig)
p1.grid(True)
#p1.set_ylim( (-2,2) )

show()