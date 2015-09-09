clear;
%This program will perform a fuzz distorsion over input signal x

%Introduction of the input signal x
    [x Fs]=wavread('astrud.wav');
    
%{    
%set the amount of distortion.
    G=7;

%Normalize the input signal and multiply it by G
    x=x/max(abs(x));
    x=G*x;
    
%Implement the function for the fuzz distortion:
    
for i=1:length(x);
    if(x(i)<0)
        y(i)= -( 1-exp(x(i)) );
    else
        y(i)=1-exp(-x(i));
    end
end

%soundsc(y,Fs);
    %}

%%%%%   Implementation of the Vacuum tube distorsion
%setting variables

%v = [-pi : 0.01 : pi] ;
%x=sin(v);
%set the amount of distortion.
    G=7;

%Normalize the input signal and multiply it by G
    x=x/max(abs(x));
    x=G*x;
    



%Q is the 'work point'  and determines the linearity of the function. For Q
%large and negative compared to x then the output reduces to y=x.
    Q=-5;
    
%D termines the  harshness of the distorsion    
    D=5;

%Now we prepare the implementation of the  valve-clipping function. And
%resolve the output taking in account the different cases that may cause an
%indetermination in the function.

%    y=(  (x-Q)/(1-exp(-D*(x-Q)))  ) + (Q/(1-exp(D*Q)));

%Special cases:
%x=Q; By using MacLaurin-Taylor series
%y=(1/D) + ( Q/(1-exp (D*Q)) );


%When Q->0, by using taylor series the function the function converges
%to...
    %y= (  x/(1-exp(-D*x))  ) - (1/D);
    
%  Initialization of the output vector    
    y=zeros(1,length(x))

%  Function implementation
    
    for i=1:length(x);
        
    if (x(i)==Q)
        y(i)=(1/D) + ( Q/(1-exp (D*Q)) );
    end
    if (Q==0)
        y(i)= (  x(i)/(1-exp(-D*x(i)))  ) - (1/D);        
    
    else 
         y(i)=(  (x(i)-Q)/(1-exp(-D*(x(i)-Q)))  ) + (Q/(1-exp(D*Q)));
    end
    
    end
   
%Normalize y
y=y/max(y);


%Applying filters
r1=0.5;
r2=0.5;
%High Pass Filter
y=filter([1, -2, 1],[1, -2*r1, r1^2],y);

%Low pass filter
y=filter([1-r2],[1,-r2],y);


    
%Visual Feedback
subplot(2,1,1)
axis=[1:length(x)];
plot(axis,x);


subplot(2,1,2)
axis=[1:length(x)];
plot(axis,y);