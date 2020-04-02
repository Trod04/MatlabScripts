function [ ZCall ] = splineCalculation(signalData, detectionPoint,splinestartDT, splinestopDT, numsplinePoints)

%process raw signal and caculate zero cross via spline interpolation
%oooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooooo

%find all zerocross possitions in signal
zci = @(signalData) find(signalData(:).*circshift(signalData(:), [-1 0]) <= 0);    
allZcPoints = zci(signalData); 

%select 4 spline interpolation points --> 3 before and 2 after DSP
%detection point

posDSPdetP = find(allZcPoints==detectionPoint-1);
zcSplinePoints = allZcPoints(posDSPdetP+splinestartDT:posDSPdetP+splinestopDT);

%calculate exact zerocross for each spline point
ZC = zeros(numsplinePoints,1);
ZCinterp1 = zeros(numsplinePoints,1);
ZCslope = zeros(numsplinePoints,1);
ZCmeter = zeros(numsplinePoints,1);

for i = 1:numsplinePoints
    
    %Polyfit ZC calculation
    %#######################
    
    %compose xval array for spline points
    xValsSpline = zcSplinePoints(i);
    xValsSpline = [xValsSpline-1; xValsSpline; xValsSpline+1; xValsSpline+2];
    
    %compose yval array for spline points
    yValsSpline = zeros(4,1);

    for y = 1:4
        yValsSpline(y) = signalData(xValsSpline(y));
    end
    
    %define polynome coeficients and find all roots
    p = polyfit(xValsSpline,yValsSpline,3);
    polyZC = roots(p);

    %zerocross is between middle spline points, filter out other ones
    polyFmin = xValsSpline(2);
    polyFmax = xValsSpline(3);
    
    try
        ZC(i) = polyZC(polyZC < polyFmax & polyZC > polyFmin);
    catch error
        stop = 1;
    end
    
    %interp1 ZC calculation
    %######################
    
    %finer sampling points definition: 0.5ns = 1/640 step between sampling
    %points ADC
    
    scndXval = xValsSpline(2);
    FSP = scndXval:1/640:scndXval+1;
    
    %find zero cross spline values
    
    yValsInt1 = interp1(xValsSpline,yValsSpline,FSP,'spline');    
    absYValsInt1 = abs(yValsInt1);
    
    minYVal = min(absYValsInt1);
    
    %find position minYval
    
    ZCint1Pos = find(absYValsInt1 == minYVal);    
    
    ZCinterp1(i) = scndXval + ZCint1Pos/640;
    
    %max slope ZC calculation
    %#########################
    
    % (x - (x-1)) is aways 1/640 so the slope formala = (y-(y1))*640,
    % calculate this between ZC points
    slopeVals = zeros(639);
    
    for y = 2:640        
        slopeVals(y-1) = (yValsInt1(y)-yValsInt1(y-1))*640;        
    end
    
    absSlopeVals = abs(slopeVals);
    
    %steepest slope == ZC point, find max val absSlopeVals
    
    maxSlopeVal = max(absSlopeVals);
    
    %find position max slope val    
    ZCSlopePos = find(absYValsInt1 == minYVal);    
    ZCslope(i) = scndXval + ZCSlopePos/639;
    
    %meter simulated ZC calculation
    %################################
    afterZCsample =  zcSplinePoints(i);
    yVals = signalData(afterZCsample-4:afterZCsample+5);
    ZCmeter(i) = spline_calculationMeter( yVals, afterZCsample );
    
end

ZCall = [ZC, ZCinterp1, ZCslope, ZCmeter];

end

