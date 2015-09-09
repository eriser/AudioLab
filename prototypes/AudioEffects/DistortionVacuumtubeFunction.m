function [y]=DistortionVacuumtube(x, G, Q, D, r1, r2)
%This function will implement a vacuum tube distortion efect using a wav file as 
%an input.
%Q is the 'work point'  and determines the linearity of the function. For Q
%large and negative compared to x then the output reduces to y=x.
%D termines the  harshness of the distorsion   


   
    
%We start by preparing the input signal before applying the distortion function.
%The input signal is normalized and 'pre-Amplified' 
    x1=x/max(abs(x));
    x1=G*x;
    
%Initialization of output vector 'y'
y=zeros(1,length(x1));

%       Implementation of valve-clipping function.

%    y=(  (x-Q)/(1-exp(-D*(x-Q)))  ) + (Q/(1-exp(D*Q)));

%   To avoid indetermination that may casue problems, we need to take into acount
%   some special cases:
%   1) x=Q; 
%   By using MacLaurin-Taylor series: y=(1/D) + ( Q/(1-exp (D*Q)) );


%   2) Q->0 (Q tending to zero)
%   By using Taylor series: y= (  x/(1-exp(-D*x))  ) - (1/D);

   
    for i=1:length(x1);
        
    if (x1(i)==Q)
        y(i)=(1/D) + ( Q/(1-exp (D*Q)) );
    end
    if (Q==0)
        y(i)= (  x1(i)/(1-exp(-D*x1(i)))  ) - (1/D);        
    
    else 
         y(i)=(  (x1(i)-Q)/(1-exp(-D*(x1(i)-Q)))  ) + (Q/(1-exp(D*Q)));
    end
    
    end
   
%Normalization of output signal y
y=y/max(y);


%Applying filters
r1=0.5;
r2=0.5;
%High Pass Filter, this takes out the dc component of the output.
y=filter([1, -2, 1],[1, -2*r1, r1^2],y);

%Low pass filter, this models the capacitance of a vacuum tube.
y=filter([1-r2],[1,-r2],y);






