function [ TotalTT ] = tailReference_LPUSM(data)
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

BoolStandAlone = 0; %set to 1 for standalone testing of function

if BoolStandAlone == 0
    %data variable unpacked

    boolSingle = data.boolSingle;
    pathName = data.pathName;
    numSignal = data.numADC;
    outputFolder = data.outputFolder; 
    velocity = data.velocity;      
    rawSignal = data.signal;
    
else
    %module test data
    
    boolSingle = 1;
    pathName = 'PathXX';
    numSignal = 1;   
    velocity = 0;
    
    strTestSignal = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\envelope_detection\signal_sample.csv';
    rawSignal = importdata(strTestSignal);
    rawSignal = rawSignal.data';
end


%input parameters
%-------------------------------------------------------------------------
threshold = 50; %threshold percentage
ZcWindow = 11; %numer of peaks included in window
ZcPeakShift = 6;
TToffset = 120; %offset when sampling window starts, time in micro seconds
Fs = 2000000; %sample rate ADC in HZ

%normalize test signal
%-------------------------------------------------------------------------

maxPeakVal = max(rawSignal);
minPeakVal = min(rawSignal);

if abs(minPeakVal) > maxPeakVal
    rawSignal = rawSignal/abs(minPeakVal);
else
    rawSignal = rawSignal/maxPeakVal; 
end

[~,numSamples] = size(rawSignal);



% compose peak tables
%-------------------------------------------------------------------------

%find samples between peaks useful signal
[posPks,posLocs] = findpeaks(rawSignal);
[negPks,negLocs] = findpeaks(-rawSignal);
negPks = -negPks;

maxValPeak = max(posPks);

%include 3 vals before max peak to include ZC peak
pkwStart = find(posPks == maxValPeak) - 3;
pkwStop = pkwStart + ZcWindow;

posPkTable = [posLocs(pkwStart:pkwStop);posPks(pkwStart:pkwStop)];
negPkTable = [negLocs(pkwStart:pkwStop);negPks(pkwStart:pkwStop)];

%calculate slopes before and after abs min value pos/neg peaktable
%-------------------------------------------------------------------------
%trim of end of peak table once the first local maxima/minima is reached
%(+ sample)

for i = 6:(ZcWindow+1)
    if posPkTable(2,i) > posPkTable(2,i-1)
        posPkTable = posPkTable(:,1:i);
        break
    end
end

for i = 6:(ZcWindow+1)
    if negPkTable(2,i) < negPkTable(2,i-1)
        negPkTable = negPkTable(:,1:i);
        break
    end
end

%positive peak table
minTailValPos = min(posPkTable(2,:));
locMinTailValPos = find(minTailValPos == posPkTable(2,:));

XMinTailValPos = posPkTable(1,locMinTailValPos);

%negative peak table
minTailValNeg = min(abs(negPkTable(2,:)));
minTailValNeg = -minTailValNeg;
locMinTailValNeg = find(minTailValNeg == negPkTable(2,:));

XMinTailValNeg = negPkTable(1,locMinTailValNeg);

%compose table for slope calculation
xvalsPos = [ posPkTable(1,locMinTailValPos -1), posPkTable(1,locMinTailValPos), posPkTable(1,locMinTailValPos + 1) ];
yvalsPos = [ posPkTable(2,locMinTailValPos -1), posPkTable(2,locMinTailValPos), posPkTable(2,locMinTailValPos + 1) ];
xvalsNeg = [ negPkTable(1,locMinTailValNeg -1), negPkTable(1,locMinTailValNeg), negPkTable(1,locMinTailValNeg + 1) ];
yvalsNeg = [ negPkTable(2,locMinTailValNeg -1), negPkTable(2,locMinTailValNeg), negPkTable(2,locMinTailValNeg + 1) ];

slopeTable = [xvalsPos; yvalsPos; xvalsNeg; yvalsNeg];

%calculate slopes
slopes = zeros(2);

for i = 1:2
    for y = 1:2 
        inversion = i * 2 - 1;
        
        x1 = slopeTable(inversion,y);
        x2 = slopeTable(inversion,y + 1);
        y1 = slopeTable(inversion + 1,y);
        y2 = slopeTable(inversion + 1,y + 1);
        
        currentSlope = ((y2 - y1)/(x2 - x1));
        slopes(i,y) = currentSlope;
    end
end

%find the inversion where the slopes are steepest and use as reference
%-------------------------------------------------------------------------

%convert slope array to absolute values, to compare rising and falling
%slopes with eachother

slopes = abs(slopes);

%find least steep angle for each inversion
posMinSlope = min(slopes(1,:));
negMinSlope = min(slopes(2,:));

%use inversion with the highest minimum slope as reference
boolRefInversion = 0; % 0 = positive inversion, 1 = negative inversion

% if posMinSlope < negMinSlope    
%     boolRefInversion = 1;
% end

%find positive peak to use for ZC calculation based on reference inversion
%-------------------------------------------------------------------------

%lookup xval boolRefInversion
if boolRefInversion == 0
    refPos = find(yvalsPos(2) == posPkTable(2,:)); 
else
    refPos = find(yvalsNeg(2) == negPkTable(2,:));
end

if boolRefInversion == 0
    RefVals = [posPkTable(1,refPos -ZcPeakShift), posPkTable(2,refPos -ZcPeakShift) ];
else
    %negative inversion
    samplesBeforeRef = find(posPkTable(1,:) < negPkTable(1,refPos));
    samplesBeforeRef = samplesBeforeRef(end);
    sPosPkTable = posPkTable(:,1:samplesBeforeRef);
    RefVals = sPosPkTable(:,end-ZcPeakShift+1)';  
end


%find zero cross window and do spline table
%-------------------------------------------------------------------------

%find number of samples between peaks
numSamplesPkPk = posPkTable(1,refPos) - posPkTable(1,refPos-1);

%dermine start/stop zero cross window
startZCW = RefVals(1) - round(numSamplesPkPk/2);
stopZCW = RefVals(1);

%find spline points
splineWxvals = startZCW:stopZCW;
splineWindow = rawSignal(:,startZCW:stopZCW);
splineWindow = [splineWxvals ; splineWindow];

%select 4 ZeroCross spline points, 2 before and 2 after zerocross
[~, splineWsize] = size(splineWindow);

for i = 1:splineWsize
    if splineWindow(2,i)> 0
        ZCpksTable = [splineWindow(:,i-2), splineWindow(:,i-1), splineWindow(:,i), splineWindow(:,i+1)];
        break;       
    end
end

% do spline interpolation
%-------------------------------------------------------------------------

%find polynomilal and calculate roots to determine exact zerocross 

%separate x & y values in to separate vectors
xValPoly = ZCpksTable(1,:);
yValPoly = ZCpksTable(2,:);

%define polynome coeficients and find all roots
p = polyfit(xValPoly,yValPoly,2);
polyZC = roots(p);

%zerocross is between middle spline points, filter out other ones
polyFmin = xValPoly(2)-1;
polyFmax = xValPoly(3)+1;

ZC = polyZC(polyZC < polyFmax & polyZC > polyFmin);

%calculate transit time 
%-------------------------------------------------------------------------
%convert TToffset from mirco second to seconds

TToffset = TToffset/1000000;
TTsampleInterval = 1/Fs;


TotalTT = TTsampleInterval * ZC + TToffset;

TTns = TotalTT * 1000000; %time in milli seconds, just for debugging

%calculate SNR (additional information)
%-------------------------------------------------------------------------

%find index of max peak to find limit between signal and noise
indexMaxPeak = find(maxValPeak ==posPkTable(2,:));
indexMaxPeak = posPkTable(1,indexMaxPeak);

signalStart = indexMaxPeak - 100;

%split up data in noise and signal package
signalNoise = rawSignal(20:signalStart);
signalUsefull = rawSignal(signalStart:end);

%determine Pk to Pk noise and usefull signal
noisePkToPk = abs(min(signalNoise)) + max(signalNoise);
signalPkToPk = abs(min(signalUsefull)) + max(signalUsefull);

%calculate SNR values
noiseratio = signalPkToPk / noisePkToPk;
currentSNR = 20 *log10(noiseratio);

%save values into array
SNRval = currentSNR;    

%FFT analysis (for illustration)
%-------------------------------------------------------------------------

nfft = length(rawSignal); %length of the time domain signal
nfft2 = 2^nextpow2(nfft); %lenght of the signal in power of 2 for higher resolution
ff = fft(rawSignal, nfft2);
fff = ff(1:nfft2/4);
xfft = Fs*(0:nfft2/4-1)/nfft2;

%PlOTS
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    
%x-vals for plotting
t = 1:numSamples;

%clear plot window in case of previous plots
clf;

%signals
%oooooooooo
h = figure();

if boolSingle == 0
    set(h, 'visible', 'off'); %don't plot to desktop
end

h(1) = subplot(2,3,1:3);

%threshold window plot
plot_param = {'Color', [0 0 0.6],'Linewidth',1.5};
plot(t, rawSignal, plot_param{:});
xlim([0 numSamples]);
ylim([-1.5 1.5]);
xlabel('samples');
title('Threshold Window Envelope Detection');
hold on;


%Lines
%oooooooooo

%plot x axis
plot_param = {'Color', [0 0 0],'Linewidth',0.5};
plot([0 numSamples],[0 0], plot_param{:});
hold on;

%plot x line threshold
threshold = threshold/100;
plot_param = {'--', 'Color', [0 0 0],'Linewidth',2};
plot([0 numSamples],[ threshold threshold], plot_param{:});
hold on;

%plot y line reference min signal/tail
if boolRefInversion == 0
    xLineRef = posPkTable(1,refPos);
else
    xLineRef = negPkTable(1,refPos);
end

plot_param = {'--', 'Color', [1 0 0],'Linewidth', 0.25};
plot([xLineRef xLineRef],[1.5 -1.5], plot_param{:});
hold on;

%plot y line start ZC window
plot([startZCW startZCW],[1.5 -1.5], plot_param{:});
hold on;

%plot y line stop ZC window
plot([stopZCW stopZCW],[1.5 -1.5], plot_param{:});
hold on;


%Makers
%oooooooooo

%mark minimum tail

if boolRefInversion == 0
    yTail = posPkTable(2,refPos);
else
    yTail = negPkTable(2,refPos);
end

plot_param = {'x','MarkerEdgeColor',[0 0 0],'MarkerSize',6, 'LineWidth',2};
plot(xLineRef,yTail,plot_param{:});
hold on;

%mark spline points
for i = 1:4
    x = xValPoly(i);
    y = yValPoly(i);

    plot_param = {'o','MarkerEdgeColor',[1 0 0],'MarkerSize',5};    
    plot(x,y,plot_param{:});
    hold on;
end

%mark ZC
plot_param = {'x','MarkerEdgeColor',[0 0 0],'MarkerSize',6, 'LineWidth',2};
plot(ZC,0,plot_param{:});
text(ZC + 5, 0.1 ,'Zero Cross Point','FontSize', 7);
hold on;


%print signal information
dim = [0.14 0.52 0.2 0.4];

strnumSample = ['ADC sample : ', num2str(numSignal)];  
strVelocity = ['Path velocity : ', num2str(velocity), 'm/s'];

str = {pathName, strnumSample,strVelocity};
annotation('textbox',dim,'String',str,'FitBoxToText','on','FontSize', 7);


%SNR chart
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
h(2) = subplot(2,3,4);
SNRval2 = [0,0,0,SNRval,0,0,0];
text(0,0,'test');
bar(SNRval2);    
ylabel('dB');
ylim([0 45]);
set(gca,'xticklabel',{[]});
title('SNR value');
hold on;

%FFT chart
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
h(3) = subplot(2,3,5:6);
plot(xfft,abs(fff),'LineWidth', 2);
title('FFT analysis');
xlim([0 350000]);
xlabel('Frequency spectrum');
set(gca,'yticklabel',{[]});
if boolSingle == 0
    hold on;
else
    hold on;
end
    

if boolSingle == 0
    %save frame
    %xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx
    %generate correct frame number string (max = 999 frames)
    if numSignal < 99 && numSignal > 9
        strFrameNum = strcat('0', num2str(numSignal));
    else
        if numSignal < 9
        strFrameNum = strcat('00', num2str(numSignal));
        else
            strFrameNum = num2str(numSignal);
        end    
    end


    savedir = strcat(outputFolder,'\frame_', strFrameNum, '.png');

    saveas(gcf,savedir,'png');
end

end

