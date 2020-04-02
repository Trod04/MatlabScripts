function [validPeakSearch, nSig, posPeakSig, negPeakSig, pltLimits, pulseResults, ValidDetection, VirtualDetection, SnrDetails ] = PulseProcess(fidLog, signal, detection, currPathCT, strCurrPath, numCSV, PulseSB)
%Function processes the pulse in the following order:
%compose CT array for current path
%normalize the signal
%get all the peak tops coördinates: x = samplenumber, y = peakvalue
%assign peak number to positive and negative peaks according to position
%to the detection point Detection point
%determine the peak ratio, as well negative as positive
%determine second wave ratio
%calculate SNR
%compose results file

%initialize return parameters
validPeakSearch = 0;
PeakVals = 0;
ValidDetection = 0;
snrCriteria = readSNRcriteria();


try
    %get path Criteria
    maxP4P2CT = currPathCT(1,1);
    minP3P1CT = currPathCT(1,2);

    maxN4N2CT = currPathCT(1,3);
    minN3N1CT = currPathCT(1,4);

    minSecondWaveCT = currPathCT(1,5);
    inversion = currPathCT(1, end);

    minSNRCT = currPathCT(1,6);
    
    
    %normalize signal    
    nSig = NormSignal(signal);   
   
    
    %generate criteria array, second row = min or max limit comparission value 
    % 1= max 0 = min

    LimitsCT = [ maxP4P2CT, minP3P1CT, maxN4N2CT, minN3N1CT, minSecondWaveCT, minSNRCT, 1; 1,0,1,0,0,0,0 ];

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
    
    if detection < 100
        threshold = 0.5;
        switch inversion
            case 1
                posMax = max(posPeaks(2,:));
                thresholdVal = posMax * threshold;
                PosPeakPosition = min(find(posPeaks(2,:) >= thresholdVal));
                detectionPeakPos = posPeaks(1,PosPeakPosition);
                zeroCrossPosition = min(find(zeroCross > detectionPeakPos));
                detection = zeroCross(1,zeroCrossPosition);
            case 0
                negMax = min(negPeaks(2,:));
                thresholdVal = negMax * threshold;
                NegPeakPosition = min(find(negPeaks(2,:) <= thresholdVal));
                detectionPeakPos = negPeaks(1,NegPeakPosition);
                zeroCrossPosition = min(find(zeroCross > detectionPeakPos));
                detection = zeroCross(1,zeroCrossPosition);
        end
        
        
    else
        ValidDetection = 1;
    end
    
    %if detection is invalid save virtualdetection
    VirtualDetection = 0;
    
    if ~ValidDetection
        VirtualDetection = detection;
    end
            
    %determine Peak Numbers: 3 row array, peak number, sample number,
    %peakvalue

    %find out what's the first peak sample before the detection point en
    %determine it's index position in the peakvalue table

    %positive peaks
    SampleValP2= max(posPeaks(1,posPeaks(1,:) < detection));
    indexP2 = find(posPeaks(1,:) == SampleValP2);

    %negative peaks
    SampleValN2= max(negPeaks(1,negPeaks(1,:) < detection));
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

    %determine max & min peaks in usefull signal and compare them with the
    %total signal to determine de seconde wave size


    %usefull signal: start P1 --> end P4, start N1 --> end N4

    %max --> positive side
    startPosSig = max( zeroCross(1,zeroCross(1,:) < posPeakSig(2,2)));
    stopPosSig = min( zeroCross(1,zeroCross(1,:) > posPeakSig(2,5)));

    [maxPeakUsefull, posmaxPeakUsefull] = max(nSig.signalNorm(1,startPosSig:stopPosSig));
    posmaxPeakUsefull = posmaxPeakUsefull + startPosSig -1;
    [maxPeakTotal, posmaxPeakTotal] = max(nSig.signalNorm(1,:));


    %min --> negative side
    startNegSig = max( zeroCross(1,zeroCross(1,:) < negPeakSig(2,2)));
    stopNegSig = min( zeroCross(1,zeroCross(1,:) > negPeakSig(2,5)));

    [minPeakUsefull, posminPeakUsefull]  = min(nSig.signalNorm(1,startNegSig:stopNegSig));
    posminPeakUsefull = posminPeakUsefull + startNegSig -1;
    [minPeakTotal, posminPeakTotal] = min(nSig.signalNorm(1,:)); 
      
    if inversion
        %positive detection
        SeconWaveRatio = maxPeakUsefull / maxPeakTotal;
    else
        %negative detection
        SeconWaveRatio = abs(minPeakUsefull) / abs(minPeakTotal);
    end

    %calculate signal to noise ratio, look at max peaks positive &
    %negative, 200 samples before peak 1.

    noisePosSampleStop = max( zeroCross(1,zeroCross(1,:) < posPeakSig(2,2)));
    %noisePosSampleStart = noisePosSampleStop -200; 
    noisePosSampleStart = 25;
    
    if PulseSB
        noisePosSampleStart = 1;
    end        

    noiseNegSampleStop = max( zeroCross(1,zeroCross(1,:) < negPeakSig(2,2)));
    %noiseNegSampleStart = noiseNegSampleStop -200;
    noiseNegSampleStart = 25;
    
    if PulseSB
        noiseNegSampleStart = 1;
    end


    [maxPosNoise, posmaxPosNoise] = max(nSig.signalNorm(1,noisePosSampleStart:noisePosSampleStop));
    [maxNegNoise, posmaxNegNoise] = min(nSig.signalNorm(1,noiseNegSampleStart:noiseNegSampleStop));

    noisePkToPk = (maxPeakTotal + abs(minPeakTotal));
    signalPkToPk = (maxPosNoise + abs(maxNegNoise));

    noiseratio = noisePkToPk / signalPkToPk;

    SNRratio = 20 *log10(noiseratio);
    
    %extended SNR test Fabien
    noise = nSig.signalNorm(1,noisePosSampleStart:noisePosSampleStop);
    signal = nSig.signalNorm;
    fr_length = snrCriteria.fr_length;
    SNR_lim = minSNRCT;
    RMS_lim = snrCriteria.RMS_limit;
    WN_lim = snrCriteria.WN_limit;
    fig = 0;
    
    [code, SNR_min, SNR_max, RMS,WN] = analyze_noise(noise,signal,fr_length, SNR_lim,RMS_lim,WN_lim,fig);
    
    SnrDetails.code = code;
    SnrDetails.SNR_min = SNR_min;
    SnrDetails.SNR_max = SNR_max;
    SnrDetails.RMS = RMS;
    SnrDetails.WN = WN;
    
    
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


    %compose results array

    tempresult = [P4P2, P3P1, N4N2, N3N1, SeconWaveRatio, SNRratio, ValidDetection];

    pulseResults(4,6) = 0;

    for i = 1:7
       if  LimitsCT(2,i)
           if tempresult(1,i) < LimitsCT(1,i)
               pulseResults(1,i) = 1;
               pulseResults(2,i) = tempresult(1,i);
           else
               pulseResults(2,i) = tempresult(1,i);
           end
       else
           if tempresult(1,i) >= LimitsCT(1,i)
               pulseResults(1,i) = 1;
               pulseResults(2,i) = tempresult(1,i);
           else
               pulseResults(2,i) = tempresult(1,i);
           end

       end
    end

    pulseResults(3:4,:) = LimitsCT(:,:);


    %write finish test to logfile & set valid bit check
    validPeakSearch = 1;
    WriteToLogFile(fidLog,['Peak value generation in CSV', num2str(numCSV), ', transducer ', strCurrPath ,' succesfully terminated']);      

catch err
    WriteToLogFile(fidLog,['Error in processing CSV ' , num2str(numCSV), ', tranducer ', strCurrPath]);
    WriteToLogFile(fidLog,err.message) ;
    return;
end


end

