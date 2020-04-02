function [ dataOut ] = findDetectionPoint( signal, handles )
    
%normalize signal    
nSig = NormSignal(signal);   

%get number of samples
[ ~, samples ] = size(nSig.signalNorm);


%invert all negative peaks
invSig(1,1:samples) = 0;

for i = 1 : samples
    invSig(1,i) = abs(nSig.signalNorm(1,i));
end

%search for sample number of first sample in rising slope
zeroCross =0;
for i = 1: samples -1
    if ((nSig.signalNorm(1,i) > 0) && (nSig.signalNorm(1,i+1) <= 0)) || ((nSig.signalNorm(1,i) < 0) && (nSig.signalNorm(1,i+1) >= 0))
        zeroCross = [ zeroCross, i + 1];
    end
end
zeroCross(:,1) = [];   
zeroCross(:,end) = [];
[~, zeroSize] = size(zeroCross);

%determine positive/negative peak values related to their sample number   
posPeaks(2,1) = 0;
negPeaks(2,1) = 0;

for i = 1:zeroSize-1

    startPeak = zeroCross(1,i);
    stopPeak = zeroCross(1,i+1);
    [~, maxPos] = max(invSig(1,startPeak:stopPeak));
    peakPos = startPeak + maxPos - 1;


    if nSig.signalNorm(1,peakPos) > 0
        currentPeak = [ peakPos; nSig.signalNorm(1,peakPos) ];
        posPeaks = [ posPeaks, currentPeak ];
    else
        currentPeak = [ peakPos; nSig.signalNorm(1,peakPos) ];
        negPeaks = [ negPeaks, currentPeak ];
    end

end

posPeaks(:,1)=[];
negPeaks(:,1)=[];

%find 'virtual' dectection point if none is found by the meter


threshold = handles.threshold/100;

posMax = max(posPeaks(2,:));
thresholdVal = posMax * threshold;
PosPeakPosition = min(find(posPeaks(2,:) >= thresholdVal));
detectionPeakPos = posPeaks(1,PosPeakPosition);
zeroCrossPosition = min(find(zeroCross > detectionPeakPos));
posdetection = zeroCross(1,zeroCrossPosition);

negMax = min(negPeaks(2,:));
thresholdVal = negMax * threshold;
NegPeakPosition = min(find(negPeaks(2,:) <= thresholdVal));
detectionPeakPos = negPeaks(1,NegPeakPosition);
zeroCrossPosition = min(find(zeroCross > detectionPeakPos));
negdetection = zeroCross(1,zeroCrossPosition);

dataOut.posDetectionpoint = posdetection;
dataOut.negDetectionpoint = negdetection;

dataOut.posPeaks = posPeaks;
dataOut.negPeaks = negPeaks;








