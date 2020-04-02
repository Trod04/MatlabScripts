function [ PCDSignals, velocityData, numSamplesADC ] = ADCParcer(strADC, strMeasurement)

%Parce csv from LPUSM ADC in to separte A/B signal per sample
%-------------------------------------------------------------

%read ADC csv into stable
rawDataSignals = readtable(strADC);

%extract sample data from upstream and downstream signal
upstreamSignalsRAW = table2array(rawDataSignals(:,4));
downstreamSignalsRAW = table2array(rawDataSignals(:,7));

%collect ADC timestamps and convert to datenum for time correlation with
%measurement data
timeStampsADC = table2array(rawDataSignals(:,9));
timeStampsADC = datenum(timeStampsADC);

%Read in measurement data velocities and timestamps to compose velocity
%table per ADC sample
%--------------------------------------------------------------

%read measurement csv into table
rawMeasurementData = readtable(strMeasurement);

%extract velocity data
velocityPointRAW = table2array(rawMeasurementData(:,4));

%collect ADC timestamps and convert to datenum for time correlation with
%measurement data

timeStampsMeasurement = table2array(rawMeasurementData(:,25));
timeStampsMeasurement = datenum(timeStampsMeasurement);

%compose velocity table per ADC sample
%-------------------------------------

%get number of ADC samples (for 2 paths)
[numSamplesADC,~] = size(upstreamSignalsRAW);
numSamplesADC = numSamplesADC / 1024;

%get number of Measurement Data samples
[numSamplesMD,~] = size(velocityPointRAW);

%find out first sample in measurement data where timestamp is equal or
%bigger than the timestamp of the current ADC sample

velocityData = 0;

for i = 1:numSamplesADC
    
    startADCsample = ((i-1)*1024)+1;
    
    %get time stamp from current ADC sample
    currentAdcTS = timeStampsADC(startADCsample);
    
    belowTS = find(timeStampsMeasurement < currentAdcTS);    

    %do check if velocity data point is first
    
    if velocityData == 0
        velocityData = velocityPointRAW(belowTS(end));
    else
        velocityData = [velocityData ; velocityPointRAW(belowTS(end))];
    end     
    
end

%fill in mismatch numvelocityData/numADCsamples (if any) with last velocity
%data val

numVD = size(velocityData);

if numVD < numSamplesADC
    
    numFS = numSamplesADC - numVD;
    
    for i = 1:numFS
        velocityData = [velocityData ; velocityPointRAW(end)];
    end
end

%compose processed signals array
%-------------------------------
PCDSignals = zeros(4,512,numSamplesADC);

for i = 1:numSamplesADC
    startSigPath1 = ((i-1)*1024)+1;
    startSigPath2 = startSigPath1 +512;
    
    PCDSignals(1,:,i) = upstreamSignalsRAW(startSigPath1:startSigPath1+511)';
    PCDSignals(2,:,i) = downstreamSignalsRAW(startSigPath1:startSigPath1+511)';
    PCDSignals(3,:,i) = upstreamSignalsRAW(startSigPath2:startSigPath2+511)';
    PCDSignals(4,:,i) = downstreamSignalsRAW(startSigPath2:startSigPath2+511)';  
    
end

end

