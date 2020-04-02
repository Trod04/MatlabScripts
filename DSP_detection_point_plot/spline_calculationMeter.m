function [ ZC ] = spline_calculationMeter( yVals, afterZCsample )
%spline_int.m
%Matlab version of C function CalcFineTravelTime
%
%Fabien Aeschlimann
%04/03/2011
%Copyright Elster Instromet

% clc
% close all
% clear all

SIZE_SPLINE_INT = 10;
NBR_OF_INT = 10;

SAMPLE_BEFORE_ZERO = 5;
SAMPLE_AFTER_ZERO = 6;

Ny = 10;   %resolution of y
Nx = 10;   %resolution of x = NBR_OF_INT
Nddy = 16; %resolution of ddy
Nsf = 8;  %resolution of SPLINE FACTOR

SPLINE_FACTOR = 1/6;                %Spline factor
SPLINE_FACTOR_q = round(1/6*2^Nsf); %Spline factor as a Nsf bit integer

% Test value #1 = from real signal

y = yVals;
% y = [0.6299 0.6050 0.5018 0.3416 0.1317 -0.1068 -0.3452 -0.5587 -0.7189 -0.8078]; %original values in double
yq = round(y*2^(Ny-1)); %value defined as Ny bit integers (-Ny/2 to +Ny/2)
y = yq / 2^(Ny-1); %value defined as Ny bits but renormalized to +/-1 used as original value

% Test value #2 = from VHDL test bench
%yq = [85 70 50 30 25 -10 -30 -50 -70 -85];
%y = yq / 2^(Ny-1); %value defined as Ny bits but renormalized to +/-1 used as original value

ts = 1/3.125e6;
fo = 200e3;

yq_long = round(100*cos((0:5*SIZE_SPLINE_INT-1)*ts*2*pi*fo - 0*pi/180));

% yq = yq_long(16:25);
% y = yq / 2^(Ny-1); %value defined as Ny bits but renormalized to +/-1 used as original value

% yq = yq_long(8:3:35);
% y = yq / 2^(Ny-1); %value defined as Ny bits but renormalized to +/-1 used as original value

% yq = [63 60 -30 -137 -108 56 215 132 -88 -257];
% y = yq / 2^(Ny-1); %value defined as Ny bits but renormalized to +/-1 used as original value

%ddy and u initialization (double)
ddy = zeros(1,10);
u = zeros(1,10);

%ddyq and uq initialization (quantified version)
ddyq = zeros(1,10);
uq = zeros(1,10);

%initialization loop
for i = 2:SIZE_SPLINE_INT-1
    
    % sig = ( x[i] - x[i-1] ) / ( x[i+1] - x[i-1] ) = constant = 0.5
    % p = sig * y"[i-1] + 2.0
    % y"[i] = ( sig - 1.0 ) / p => y"[i] = -1 / (y"[i-1] + 4);
    %
    % u[i] = ( y[i+1] - y[i] ) / ( x[i+1] - x[i] ) - ( y[i] - y[i-1] ) / ( x[i] - x[i-1] )
    %      = (y[i+1] - 2y[i] + y[i-1]) / dtx
    % if dtx = 1     => u[i] = (y[i+1] - 2y[i] + y[i-1])
    % if dtx = 2^Nx  => u[i] = (y[i+1] - 2y[i] + y[i-1]) / 2^Nx with Nu = Ny
    %                        = (y[i+1] - 2y[i] + y[i-1]) with u and y defined with Nu = Ny + Nx
    %
    % u[i] = ( 6.0 * u[i] / ( x[i+1] - x[i-1] ) - sig * u[i-1] ) / p
    %      = ( 6.0 * (y[i+1] - 2y[i] + y[i-1]) / dtx - u[i-1] ) * -y"[i]
    % if dtx = 1     => u[i] = ( 6.0 * (y[i+1] - 2y[i] + y[i-1]) / dtx - u[i-1] ) * -y"[i]
    % if dtx = 2^Nx  => u[i] = ( 6.0 * (y[i+1] - 2y[i] + y[i-1]) / 2^Nx - u[i-1] ) * -y"[i] with Nu = Ny 
    %                        = ( 6.0 * (y[i+1] - 2y[i] + y[i-1]) - u[i-1] ) * -y"[i] with u and y defined with Nu = Ny + Nx
    %
    % if y" is defined with Nddy bit, u is defined by Ny+Nx+Nddy, so the equation can be normalized by:
    % u[i] = ( 6.0 * (y[i+1] - 2y[i] + y[i-1]) - u[i-1] ) * -y"[i] / 2^Nddy with u and y defined with Nu = Ny + Nx
    % 
    
    
    ddy(i) = -1 / (ddy(i-1) + 4); %ddy(i) calculated as double
                                  %Note that ddy is an array of constant(since ddy(0) = 0 = constant)
                                  %which dont need to be calculated!
    ddyq(i) = round(ddy(i)*2^(Nddy-1)); %ddy values defined as Nddy bit integers also an array of constant
    
    u(i) = (6*(y(i+1) -2*y(i) + y(i-1)) - u(i-1)) * -ddy(i); %u(i) calculated as double
    uq(i) = fix(((6*(yq(i+1)*2^Nx -2*yq(i)*2^Nx + yq(i-1)*2^Nx) -uq(i-1)) * -ddyq(i)) / 2^(Nddy-1)); %u(i) calculated as Ny + Nx bit integers
                                                                         
end

uqt = round(u.*2^(Ny+Nx-1)); %Theoretical u values defined as Ny bit integers from u calculated with double values

%backward substitution loop
for i = SIZE_SPLINE_INT-1:-1:1
    
    ddy(i)  = (ddy(i) * ddy(i+1)) + u(i); %ddy(i) calculated as double
    ddyq(i) = fix((ddyq(i) * ddyq(i+1)) / 2^(Nddy-1)) + fix(uq(i)*2^(Nddy-Ny-Nx));  %ddy(i) calculated as Nddy bit integer

end

ddyqt = round(ddy.*2^(Nddy-1)); %Theoretical ddy values defined as Nddy bit integers from ddy calculated with double values


%Interpolation loop
splineX = 0; %initialization of the double values
selection = 0.5;

A = 0;
B = 0;
C = 0;
D = 0;

splineXq(1) = 0; %initialization of integer values 
selectionq(1) = 2^(Nx-1);

Aq = zeros(1,NBR_OF_INT);
Bq = zeros(1,NBR_OF_INT);
Cq = zeros(1,NBR_OF_INT);
Dq = zeros(1,NBR_OF_INT);

for i = 1:NBR_OF_INT
    
  
    B = splineX + selection; %interpolation parameter defined as double
    A = 1 - B;
    C = (A * A * A) - A;
    D = (B * B * B) - B;

    Bq(i) = splineXq(i) + selectionq(i); %interpolation parameter defined as Nx bit integers
    Aq(i) = 2^Nx - Bq(i);
    Cq(i) = floor(Aq(i)*Aq(i)*Aq(i) / 2^(2*Nx)) - Aq(i);
    Dq(i) = floor(Bq(i)*Bq(i)*Bq(i) / 2^(2*Nx)) - Bq(i);
    
    %SplineY using double values
    splineY(i) = A * y(SAMPLE_BEFORE_ZERO) + B * y(SAMPLE_AFTER_ZERO) + ...
                  (SPLINE_FACTOR * (C * ddy(SAMPLE_BEFORE_ZERO) + D * ddy(SAMPLE_AFTER_ZERO)));
    
    %SplineY using integer values and defined with Nsf + Nx + Nddy bits
     var1 = Aq(i) * yq(SAMPLE_BEFORE_ZERO);
     var2 = Bq(i) * yq(SAMPLE_AFTER_ZERO);
     var3 = (var1 + var2) *2^(Nsf+Nx+Nddy-Ny-Nx);
     
     var4 = Cq(i) * ddyq(SAMPLE_BEFORE_ZERO);
     var5 = Dq(i) * ddyq(SAMPLE_AFTER_ZERO); 
     var6 = SPLINE_FACTOR_q * (var4 + var5);
                 
    splineYq(i) = Aq(i) * yq(SAMPLE_BEFORE_ZERO)*2^(Nsf+Nx+Nddy-Ny-Nx) + ...
                  Bq(i) * yq(SAMPLE_AFTER_ZERO)*2^(Nsf+Nx+Nddy-Ny-Nx) + ...
                  fix(SPLINE_FACTOR_q * (Cq(i) * ddyq(SAMPLE_BEFORE_ZERO) + Dq(i) * ddyq(SAMPLE_AFTER_ZERO)));
    
    splineYqt(i) = splineY(i)*2^(Nsf+Nx+Nddy-1); %Theoretical splineY value defined as an integer from splineY calculated with double values
              
    err_splineY(i) = abs(splineYqt(i) - splineYq(i))/splineYqt(i) * 100; %relative error of splineY
     
    if sign(splineY(i)) ~= sign(splineYq(i))
        warning('splineY and splineYq with different sign. Condition loops won''t match')
    end    
    
    %splineX condition loop
    if y(SAMPLE_BEFORE_ZERO) >= 0
        
        if splineY(i) >= 0, splineX = B; end;
        
    else
        
        if splineY(i) < 0, splineX = B;  end
            
    end
    
    %splineXq condition loop
    if yq(SAMPLE_BEFORE_ZERO) >= 0
        
        if splineYq(i) >= 0
            
            splineXq(i+1) = Bq(i); 
        
        else
            
            splineXq(i+1) = splineXq(i);
        
        end;
        
    else
        
        if splineYq(i) < 0
            
            splineXq(i+1) = Bq(i);
        
        else
            
            splineXq(i+1) = splineXq(i);      
        
        end
            
    end
   
    selection = selection / 2;
    selectionq(i+1) = floor(selectionq(i) / 2);
end

%Display final values
splineXqn = splineXq(i+1) / 2^Nx; %Normalization of splineXq to +/-1

fs = 3.125e6; %sampling frequency
err_t = abs(splineX - splineXqn) / fs * 10^12; %err of transit time in ps

%Matlab Spline function
xfit = 1:0.0001:10;
yfit = spline(1:10,y,xfit);

%MOD TROD: return ZC paramter
ZC = afterZCsample + splineX;

% figure,
% hold on,
% plot(0:9, y,'.-')
% plot(xfit -1,yfit,'r')
% plot(SAMPLE_BEFORE_ZERO + splineX -1,0,'ro')
% plot(SAMPLE_BEFORE_ZERO + splineXqn -1,0,'g*')
% legend('Input data','Matlab Spline','Transit time (double)','Transit time (quant)')
% hold off
% grid on
%axis([5.548 5.566 -4e-4 4e-4]);

    
    


end

