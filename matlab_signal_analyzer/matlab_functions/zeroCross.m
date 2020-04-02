function [ xvalue ] = zeroCross(pulseData,posneg)
%find zerocross function

if posneg
    %point 1
    P1X = pulseData.posdetection;
    P1Y = pulseData.nSig.signalNorm(1,P1X);

    %point 2
    P2X = pulseData.posdetection -1;
    P2Y = pulseData.nSig.signalNorm(1,P2X);
else
    %point 1
    P1X = pulseData.negdetection;
    P1Y = pulseData.nSig.signalNorm(1,P1X);

    %point 2
    P2X = pulseData.negdetection -1;
    P2Y = pulseData.nSig.signalNorm(1,P2X);
end

rico = (P2Y-P1Y)/(P2X-P1X);

b = P1Y - (rico*P1X)

xvalue = -b/rico;
end

