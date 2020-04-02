function [validProcess, pulseData] = PulseProcessScope(handles, autoProcess, hObject)

validProcess = 0;
signal = handles.CSVdata;

try
    %normalize signal    
    nSig = NormSignal(signal);
    pulseData.nSig = nSig;

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
    
    %set detection point based on threshold or altered manual set detection
    %point
    if autoProcess
        posMax = max(posPeaks(2,:));
        thresholdVal = posMax * threshold;
        PosPeakPosition = min(find(posPeaks(2,:) >= thresholdVal));
        detectionPeakPos = posPeaks(1,PosPeakPosition);
        zeroCrossPosition = min(find(zeroCross > detectionPeakPos));
        posdetection = zeroCross(1,zeroCrossPosition);        
        negdetection = zeroCross(1,zeroCrossPosition - 1);
       
        pulseData.posdetection = posdetection;      
        pulseData.negdetection = negdetection;
    else
        pt = get(hObject,'CurrentPoint');
        x = round(pt(1,1));

        %beginning zoom window
        zoomstart = handles.pulseData.plotData.zoomStart;

        %determine click point in signal and find pos and negative zoom
        clickpoint = zoomstart + x;

        %see if the user clicked  between a pos or neg peak

        zeroCrossPosition = min(find(zeroCross > clickpoint));  

        p1 = round((zeroCross(1,zeroCrossPosition) + zeroCross(1,zeroCrossPosition - 1))/2); %find x position beween zerocrosses --> estimated to be in beween
        minmaxPointClick = nSig.signalNorm(1,p1);

        if minmaxPointClick < 0
            posdetection = zeroCross(1,zeroCrossPosition - 1);
            negdetection = zeroCross(1,zeroCrossPosition);            
        else
            posdetection = zeroCross(1,zeroCrossPosition);
            negdetection = zeroCross(1,zeroCrossPosition - 1);
        end
            
        pulseData.posdetection = posdetection;      
        pulseData.negdetection = negdetection;
            
    end
    
    %determine Peak Numbers: 3 row array, peak number, sample number,
    %peakvalue

    %find out what's the first peak sample before the detection point en
    %determine it's index position in the peakvalue table

    %positive peaks
    SampleValP2= max(posPeaks(1,posPeaks(1,:) < posdetection));
    indexP2 = find(posPeaks(1,:) == SampleValP2);

    %negative peaks
    SampleValN2= max(negPeaks(1,negPeaks(1,:) < negdetection));
    indexN2 = find(negPeaks(1,:) == SampleValN2);    

    %generate final peaktables
    posPeakSig(3,6) = 0;
    negPeakSig(3,6) = 0;
    peakNumber = [0:5];
    posPeakSig(1,:) = peakNumber;
    negPeakSig(1,:) = peakNumber;
    posPeakSig(2:3,:) = posPeaks(:,indexP2-2:indexP2+3);
    negPeakSig(2:3,:) = negPeaks(:,indexN2-2:indexN2+3);


    %calculate peak ratios
    P4P2 = posPeakSig(3,5)/posPeakSig(3,3);
    P3P1 = posPeakSig(3,4)/posPeakSig(3,2);

    N4N2 = negPeakSig(3,5)/negPeakSig(3,3);   
    N3N1 = negPeakSig(3,4)/negPeakSig(3,2);
    
    pulseData.posPeakSig = posPeakSig;
    pulseData.negPeakSig = negPeakSig;

    %determine max & min peaks in usefull signal and compare them with the
    %total signal to determine de seconde wave size


    %usefull signal: start P1 --> end P4, start N1 --> end N4

    %max --> positive side
    startPosSig = max( zeroCross(1,zeroCross(1,:) < posPeakSig(2,2)));
    stopPosSig = min( zeroCross(1,zeroCross(1,:) > posPeakSig(2,5)));

    [maxPeakUsefull, posmaxPeakUsefull] = max(nSig.signalNorm(1,startPosSig:stopPosSig));
    posmaxPeakUsefull = posmaxPeakUsefull + startPosSig -1;
    [maxPeakTotal, posmaxPeakTotal] = max(nSig.signalNorm(1,:));

    [maxPeakAfterUsefull, posmaxPeakAfterUsefull] = max(nSig.signalNorm(1,stopPosSig:end));


    %min --> negative side
    startNegSig = max( zeroCross(1,zeroCross(1,:) < negPeakSig(2,2)));
    stopNegSig = min( zeroCross(1,zeroCross(1,:) > negPeakSig(2,5)));

    [minPeakUsefull, posminPeakUsefull]  = min(nSig.signalNorm(1,startNegSig:stopNegSig));
    posminPeakUsefull = posminPeakUsefull + startNegSig -1;
    [minPeakTotal, posminPeakTotal] = min(nSig.signalNorm(1,:));
    
    [minPeakAfterUsefull, posminPeakAfterUsefull]  = min(nSig.signalNorm(1,stopNegSig:end));
    
    
    %calculate second wave ratio, if second wave is smaller than the total peak recalculate  
    SeconWaveRatio = (maxPeakUsefull + abs(minPeakUsefull))/(maxPeakTotal+ abs(minPeakTotal));
    
    if SeconWaveRatio ==1
        SeconWaveRatio = (maxPeakUsefull + abs(minPeakUsefull))/(maxPeakAfterUsefull+ abs(minPeakAfterUsefull));
    end
    

    %calculate signal to noise ratio, look at max peaks positive &
    %negative, 200 samples before peak 1.

    noisePosSampleStop = max( zeroCross(1,zeroCross(1,:) < posPeakSig(2,2)));
    noisePosSampleStart = 50; 
 
    noiseNegSampleStop = max( zeroCross(1,zeroCross(1,:) < negPeakSig(2,2)));
    noiseNegSampleStart = 50;
    
    [maxPosNoise, posmaxPosNoise] = max(nSig.signalNorm(1,noisePosSampleStart:noisePosSampleStop));
    [maxNegNoise, posmaxNegNoise] = min(nSig.signalNorm(1,noiseNegSampleStart:noiseNegSampleStop));

    noisePkToPk = (maxPeakTotal + abs(minPeakTotal));
    signalPkToPk = (maxPosNoise + abs(maxNegNoise));

    noiseratio = noisePkToPk / signalPkToPk;

    SNRratio = 20 *log10(noiseratio);
    
   
    %compose y-coördinates array for pk to pk noise, usefull signal, total
    %signal
    
   
    pltLimits(2,1)= maxPosNoise;
    pltLimits(1,1)= posmaxPosNoise;
    pltLimits(4,1)= maxNegNoise;
    pltLimits(3,1)= posmaxNegNoise;
    pltLimits(2,2)= maxPeakUsefull;
    pltLimits(1,2)= posmaxPeakUsefull;
    pltLimits(4,2)= minPeakUsefull;
    pltLimits(3,2)= posminPeakUsefull;
    pltLimits(2,3)= maxPeakTotal;
    pltLimits(1,3)= posmaxPeakTotal;
    pltLimits(4,3)= minPeakTotal;
    pltLimits(3,3)= posminPeakTotal;
    
    
    pulseData.pltLimits = pltLimits;

    %compose results array

    pulseResult = [P4P2, P3P1, N4N2, N3N1, SeconWaveRatio, SNRratio];

    pulseData.pulseResult = pulseResult;
    
    %write event to logfile
    WriteToLogFile(handles.fidLog,'Pulse was processed succesfully');
    validProcess = 1;
    
catch err
    WriteToLogFile(handles.fidLog,'Error in PulseProcessScope CSV');
    WriteToLogFile(handles.fidLog,err.message) ;
    return;
end


end

