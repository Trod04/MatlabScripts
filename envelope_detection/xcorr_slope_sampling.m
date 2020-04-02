function xcorr_slope_sampling(data)
%-------------------------------------------------------------------------
%Author: TROD
%Date modified: 18/02/2020
%
%Description:
%
%find minimum between signal and tail oscilation to use as reference
%-------------------------------------------------------------------------

%SIGNAL PROCESSING
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

%input data
%-------------------------------------------------------------------------
    
strTestSignal = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\envelope_detection\up_down_signal.csv';
rawSignal = importdata(strTestSignal);
rawSignal = rawSignal';

%input parameters
%-------------------------------------------------------------------------

numCorrSamples = 140;
numPkWindow = numCorrSamples/10;

%normalize test signals
%-------------------------------------------------------------------------

for i = 1:2
    maxPeakVal = max(rawSignal(i,:));
    minPeakVal = min(rawSignal(i,:));
    
    if abs(minPeakVal) > maxPeakVal
        rawSignal(i,:) = rawSignal(i,:)/abs(minPeakVal);
    else
        rawSignal(i,:) = rawSignal(i,:)/maxPeakVal; 
    end

    [~,numSamples] = size(rawSignal);
end

% compose peak tables
%-------------------------------------------------------------------------

%find samples between peaks useful signal
posPkTable = zeros(4,numPkWindow);
negPkTable = zeros(4,numPkWindow);

for i = 1:2
    [posPks,posLocs] = findpeaks(rawSignal(i,:));
    [negPks,negLocs] = findpeaks(-rawSignal(i,:));
    negPks = -negPks;

    maxValPeak = max(posPks);

    %include 3 vals before max peak to include ZC peak
    pkwStart = find(posPks == maxValPeak) - 5;
    pkwStop = pkwStart + numPkWindow -1;

    posPkTable(i*2-1:i*2,:) = [posLocs(pkwStart:pkwStop);posPks(pkwStart:pkwStop)];
    negPkTable(i*2-1:i*2,:) = [negLocs(pkwStart:pkwStop);negPks(pkwStart:pkwStop)];
end

%find shift between signals towards peak max
%-------------------------------------------------------------------------
corrWindow = zeros(2,numCorrSamples);

for i = 1:2
    maxPeakVal = max(rawSignal(i,:));
    
    centerCorrWindow = find(rawSignal(i,:) == maxValPeak);
    
    start = centerCorrWindow - numCorrSamples/2; 
    stop = centerCorrWindow + numCorrSamples/2 - 1;

    corrWindow(i,:) = rawSignal(i,start:stop);
end

%find correlation shift
%-------------------------------------------------------------------------
delayCorrelation = xcorr(corrWindow(1,:),corrWindow(2,:));
peakCorr = max(delayCorrelation);
xshift = find(peakCorr == delayCorrelation) - numCorrSamples;

corrPlot = zeros(2, numCorrSamples - abs(xshift));

if xshift >= 0
    corrPlot(1,:) = corrWindow(1, 1: end-abs(xshift));
    corrPlot(2,:) = corrWindow(2, abs(xshift):end);
else
    corrPlot(2,:) = corrWindow(1, 1: end-abs(xshift));
    corrPlot(1,:) = corrWindow(2, abs(xshift)+1:end);
end

%calculate how many samples are between peaks and convert xshift to peak
%shift

pkTopkSamples = abs(posPkTable(1,6)-posPkTable(1,5));
peakShift = round(xshift/pkTopkSamples,0);

%calculate positive slopes
%-------------------------------------------------------------------------
slopes = zeros(3,numPkWindow -1);

for i = 1:numPkWindow-1
    for y = 1:2
        slopes(y*2-1,i) = (posPkTable(y*2-1,i+1) + posPkTable(y*2-1,i)) /2;
        slopes(y*2,i) = (posPkTable(y*2,i+1) - posPkTable(y*2,i))/(posPkTable(y*2-1,i+1) - posPkTable(y*2-1,i));        
    end    
end

%correlate slopes
slopePlot = zeros(2, numPkWindow -1 - abs(peakShift));

if xshift >= 0
    slopePlot(1,:) = slopes(1, 1: end-abs(peakShift));
    slopePlot(2,:) = slopes(2, abs(peakShift):end);
else
    slopePlot(2,:) = slopes(1, 1: end-abs(peakShift));
    slopePlot(1,:) = slopes(2, abs(peakShift)+1:end);
end


%plots
%-------------------------------------------------------------------------
%x-vals for plotting
t = 1:numCorrSamples - abs(xshift);
plot_param = {'Color', [0 0 0.6],'Linewidth',0.5};

for i = 1:2
    if i == 1
        plot_param = {'Color', [0 0 0.6],'Linewidth',0.5};
    else
        plot_param = {'Color', [0.6 0 0],'Linewidth',0.5};
    end
    
    plot(t, corrPlot(i,:), plot_param{:});
    hold on;
end

%plot values 

if xshift >= 0
    corrPlot(1,:) = corrWindow(1, 1: end-abs(xshift));
    corrPlot(2,:) = corrWindow(2, abs(xshift):end);
else
    corrPlot(2,:) = corrWindow(1, 1: end-abs(xshift));
    corrPlot(1,:) = corrWindow(2, abs(xshift)+1:end);
end
end
