clear;
tic

%%%%%%% READING A .WAV FILE %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
%[x, SR]=wavread('MonoSampleFile.wav');
%%[x, SR]=wavread('TestGuitarPhraseMono.wav');
[x, SR]=wavread('astrud.wav');
x=x';                %x is a row vector-horizontal
xs=length(x);        %Length of x for future calculations

%%%%%%%%%%%%%%%% GENERAL VARIBABLES %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
N=1024;             %window size. A good choise is a power of two.

distribution=4;     %hop size HA will be 1/4 of the size of N window. 
HA=N/distribution;  %hop size for HA            
HA=ceil(HA);        %rounding HA to an integer
Q=1.5;              %Expansion/compression factor Q
HS=HA*Q;            %hop size HS for synthesis.
HS=ceil(HS);        %we make sure that HS is an integer
NF=xs/HA;           %NF numbers of frames needed to cover the signal
NF=round(NF);       %rounding NF to an integer

%%%%%%%%%%%%%%%CONSTRUCTION OF HANN WINDOW%%%%%%%%%%%%%%%%%%%%%
n=[0:N-1];
w=0.5*(1-cos(2*pi*n/N));
w=w';               %The hann window will be a column vector
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%




%%%%%% THE ZERO PADDED VECTOR %%%%%%%%%%%%%%%%%%%%%%%%% 
z=(HA*NF)-xs;        %z is the numbers of zeros needed  
x=[x,zeros(1,z+HA*distribution-1)];% Adding zeros
x=x';                %leaving x as a column vector

%%%%%%%%%%%%%% ANALYSIS MATRIX %%%%%%%%%%%%%%%%%%%%%%%%%%%
X=zeros(N,NF);       %Creation of Matrix X

           %%%%%%%FILLING THE MATRIX%%%%%%%%%%%
for c=1:NF
  for r=1:N
   %In each cycle, we read the zero-padded-column-vector-x. 
   %in the first cycle, we read from x(1,1) to x(N,1)
   %in the second cycle, we read from x(HA+1,1) to x(HA+N)
   %in the third cycle, we read from x(HA*2+1,1) to x(HA*2+N,1) 
   %Values are copied to X.
   X(r,c)=x(((HA)*(c-1))+r,1)*w(r);
  end
end

XF= fft(X); %creation of XF matrix with the DFTs of the X matrix columns
            %XF is a matrix of dimensions (NxNF)
            
%Matrix XFM will have the magnitudes of the DFTs inside X
XFM=abs(XF);

%Matrix XFP will have the angles of the DFTs inside X
XFP=angle(XF); 

%Creation of a matrix called YFP, it will contain the phases of the output.
%For now, It will have only have zeros and the first column of XFP will be
%read into the first column of XFP.
YFP=zeros(N,NF);
YFP(:,1)=XFP(:,1);


%%%%%%%%%%%%%% PHASE VECTOR 'v' %%%%%%%%%%%%%%%%%%%%%%

%the first N/2 +1 values are given by v(1:N/2 +1)=2*pi*HA*[0:N/2]'/N
v=zeros(N,1);
v(1:N/2 +1,1)=(2*pi*HA*[0:N/2]')/N;

%the remaining values should be set antisimetrically.
%v(N)=-v(2).......v(N-1)=-v(3)........v(N-2)=-v(4)
for c=0:(N/2 -1);
   v(N-c)=-v(c+2);
end

%%%%%%%%%%%%%% PHASE DIFFERENCES %%%%%%%%%%%%%%%%%%%%%%%
%create a matrix D(N,NF) this will contain the phase difference  between
%succesive analysed frames down the columns. the mth column of D should
%contain the difference between the mth and m-1th columns of XFP, the first
%column of D should remain zero

D=zeros(N,NF);

for c=2:NF
D(:,c)=XFP(:,c)-XFP(:,c-1);   
end    

%%%%%%%%%%% PHASE INCREMENT %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Phase increment is obtained by substracting the column vector 'v' from
% each column of Matrix D.
for c=1:NF
   D(:,c)=D(:,c)-v; 
end

%%%%%%%%Converting the values in range (-pi,pi)%%%%%%%%%%%%%%%%%%%%%

D1=zeros(N,NF); %D1 is a matrix that will be used as auxil
                %to compare the original matrix D

for c=1:NF
    for r=1:N

        if (D(r,c)<=pi)&&(D(r,c)>=(-pi))  %values between -pi and pi will 
               D1(r,c)=D(r,c);            %remain unchanged
           
        end   
        if (D(r,c)>(pi))                 %The values > pi or < -pi
                  while(D(r,c)>pi)       %Will be reset to the fundamental period 
                  D(r,c)=D(r,c)-(2*pi);  % by adding/substrating 2*pi.
                  end
                  D1(r,c)=D(r,c);
        end
       
           
        if (D(r,c)<(-pi))
                 while(D(r,c)<(-pi))
                 D(r,c)=D(r,c)+(2*pi);
                 end
                 D1(r,c)=D(r,c);
        end
        
   end  
end
D=D1; %the final result of the scalation will be copied to D from D1.

%%%%%%%%%%%%%%PHASE RESCALING %%%%%%%%%%%%%%%%%%%
%The phases difference is stretched/compressed by a factor Q
for c=1:NF
    for r=1:N
    D(r,c)=Q*(D(r,c)+v(r,1));
    end
end

%%%%%%%%%%%% PHASE DIFFERENCES TO ABSOLUTE VALUE %%%%%%%%%%%%%%%%%%%%%%%
%First column of YFP should be the same as the first column of XFP. Then
%recursively, set the mth column of YFP to be equal to the m-1th column of
%YFP plus the mth column of D for m>1 until YFP has been filled
 for m=2:NF
     YFP(:,m)=YFP(:,m-1)+D(:,m);   
 end
 
 
%CREATION OF YF MATRIX. IT CONTAINS THE CARTESIAN FORM OF THE COMPLEX
%NUMBERS OBTAINED FROM THE MAGNITUDES AND PHASES OF THE SYNTHESIS FRAMES
%(CONTAINED IN MATRICES XFM AND YFP). 
%function pol2cart receves the angle and magnitudes of each column as arguments and
%storage the result in 2 column vector array with columns x1 and y1.
%Then we just add the real and imaginary part into our YF colums
YF=zeros(N,NF);

for c=1:NF
    [x1, y1]=pol2cart(YFP(:,c), XFM(:,c));
    YF(:,c)=x1+1i*y1;
end

%%%%%%%% INVERSE FOURIER TRANSFORM IFFT%%%%%%%%%%%%%%%%%%%
Y=ifft(YF);

%After veryfing the imaginary part is very small (almost zero), Y is rested
%to its own real part
Y= real(Y);


    
%%%%%%%%%%%%%%%  SYNTHESIS %%%%%%%%%%%%%%%%%%%%%
%The synthesis is made by the creation of 1 column vector 'y', which will
%store the output of our program. 
%vectors 'a' and 'b' are created with the same length as 'y' and will be
%auxiliars for the overlapping operation

%SOME AUXILIAR VARIABLES FOR THE OVERLAPING
y=zeros(HS*NF+(N-HS),1);
a=zeros(HS*NF+(N-HS),1);
b=zeros(HS*NF+(N-HS),1);
    
%LOAD THE FIRST y Column with the first column of Y   
    for c=1:N
       y(c,1)= Y(c,1)*w(c);
    end
   
%CONTINUE WITH THE OVERLAPING(FROM THE SECOND COLUMN OF Y)    
      for c=2:NF
                
             b=y;          %'b' will storage the previous value of y.
             a=zeros(HS*NF+(N-HS),1);
             for   r=1:N
             a(HS*(c-1)+r,1)=Y(r,c)*w(r); %'a' has the new values of 
             end
             y=b+a;       %The updated vector 'y' will contain the output
                 
      end
    
toc     

Q %to be shown in the console.        
soundsc(y,SR); % plays the stretched/compresed output 


    
    

    