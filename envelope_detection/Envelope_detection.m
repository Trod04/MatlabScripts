function  TotalTT = Envelope_detection(data)
%-------------------------------------------------------------------------
%Author: TROD
%Date modified: 12/03/2019
%
%Description:
%
%breakdown functionallily simple envelope detection and how it should work
%inside NGQ
%-------------------------------------------------------------------------

%initialize return parameter
%-------------------------------------------------------------------------
TotalTT = 0;

%input parameters function 
%-------------------------------------------------------------------------
%data variable unpacked
currentPathName = data.currentPathName; 
currentFileName = data.currentFileName;
numSignal = data.numSignal  
flowpoint = data.flowpoint; 
outputFolder = data.outputFolder; 
velocity = data.velocity;

%for MPC testing only
pathNum = 1;
transmitSide = 0; %0 = a-side, 1 = b-side
invSig = 0; %invert signal for testing
blnMPCformat = 0; %select signal format type MPC = 0, scope = 0

%input pars DSP
%-------------------------------------------------------------------------

threshold = 50; %threshold percentage
sampleWindow = 500; %number of samples where the envelope function is applied, threhold = middle of window
ZCWPosCorrF = 0.5; %correction factor ZCWPosCorr
ZCWSizeF = 0.5; %correction factor ZCWSize

%open testdata
%-------------------------------------------------------------------------
if blnMPCformat == true    
    selectedSignalMPC = (pathNum*2) - 1 + transmitSide;

    data=importdata(currentPathName, ',',0);
    csvdata = data.data;
    %trim csv matrix to signal only, select first path
    
    csvdata = csvdata(:,25:end-5);
    rawSignal = csvdata(selectedSignalMPC,:);
else
    sigData = importdata(currentPathName);
    sigData = sigData.data(:,3)';
    
    avgSigOffset = mean(sigData);
    
    rawSignal = sigData - avgSigOffset;
end

%normalize test signal
maxPeakVal = max(rawSignal);
minPeakVal = min(rawSignal);

if abs(minPeakVal) > maxPeakVal
    rawSignal = rawSignal/abs(minPeakVal);
else
    rawSignal = rawSignal/maxPeakVal; 
end

%threshold window selection (STEP 1 of pulseprocessing)
%-------------------------------------------------------------------------
[~,numSamples] = size(rawSignal);
threshold = threshold/100;

%inital scan raw signal to find threshold sample number
sampleTH = 0;


for i = 1:numSamples
    if rawSignal(i) > threshold
        sampleTH = i;
        break;
    end
end

%find number of samples between peaks to determine 


%trim window according to samplewindow size (threshold = middle)
sampleWindow = sampleWindow/2;
ThWindowStart = sampleTH - sampleWindow;
ThWindowStop = sampleTH + sampleWindow;

ThSignal = rawSignal(ThWindowStart:ThWindowStop);

if invSig == true
    ThSignal = ThSignal * -1;
end

[~,THnumSamples] = size(ThSignal);

%generate envelope functions (STEP 2 of pulseprocessing)
%-------------------------------------------------------------------------
env = abs(hilbert(ThSignal));

%find first package peaks (STEP 3 of pulseprocessing)
%-------------------------------------------------------------------------
%find samples between peaks useful signal
[pks,locs] = findpeaks(rawSignal);
maxValPeak = max(pks);
maxPkLoc = find(pks == maxValPeak);
numSamplesPkPk = locs(maxPkLoc) - locs(maxPkLoc - 1);

%define search window for maximum first envelope (1.5 time pktpk num
%samples)

maxEnvWindow = numSamplesPkPk * 1.5;

%find max from first envelope --> start = threshold position - maxEnvWindow, stop =
%threshold position + maxEnvWindow

MaxValFirstEnv = max (env(250-maxEnvWindow:250+maxEnvWindow));

%sample position of first maximum peak of envelope
xSelPmax = find(env==MaxValFirstEnv);


%define spline window based on selected reference envelope peak (STEP 4 of pulseprocessing)
%-------------------------------------------------------------------------

ZCWPosCorr = round(numSamplesPkPk * ZCWPosCorrF, 0); %samples behind the max of the envelope to start looking for peak in signal(=end of spline window), value should be > half cycle time and < full cycle time # samples. To disable set to 0;
ZCWSize = round(numSamplesPkPk * ZCWSizeF, 0); %zero cross window size, 60% samples between peaks

%find first peak behind max of envelope (corrected with ZCWPosCorr val to
%eleminate first peak if the max envelope falls between signal peaks
endLookPos = xSelPmax - ZCWPosCorr;
[~,locs] = findpeaks(ThSignal(1:endLookPos));

xsplineWStop = locs(end);
xsplineWStart = locs(end)-ZCWSize;

splineWxvals = xsplineWStart:xsplineWStop;

splineWindow = ThSignal(xsplineWStart:xsplineWStop);

splineWindow = [splineWxvals ; splineWindow];

%find spline points (STEP 5 of pulseprocessing, same of current detection)
%-------------------------------------------------------------------------

%select 4 ZeroCross spline points, 2 before and 2 after zerocross
[~, splineWsize] = size(splineWindow);

for i = 1:splineWsize
    if splineWindow(2,i)> 0
        ZCpksTable = [splineWindow(:,i-2), splineWindow(:,i-1), splineWindow(:,i), splineWindow(:,i+1)];
        break;       
    end
end

%find polynomilal and calculate roots to determine exact zerocross (STEP 6
%of pulseprocessing,  same of current detection)
%-------------------------------------------------------------------------

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

%calculate transit time (STEP 7 of pulseprocessing)
%-------------------------------------------------------------------------

%add number of samples of raw signal before THwindow to rounded zerocross
%value of THwindow sample number

totZCsamples = ThWindowStart + ZC;

%calculate final Transit time by calculating and adding the full samples TT
%and the fraction TT to eachother taking into account the ADC sample rate

Fs = 3125000; %sample rate ADC in HZ

TTsample = 1/Fs; %time between samples in seconds
TotalTT = TTsample * totZCsamples;

TTns = TotalTT * 1000000; %time in milli seconds, just for debugging

%calculate SNR (additional information)
%-------------------------------------------------------------------------

%find index of max peak to find limit between signal and noise
[~,indexMaxPeak] = max(rawSignal);    
signalStart = indexMaxPeak - 200;

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

Fs = 5000000; %sample rate ADC (3125000) or scope
nfft = length(rawSignal); %length of the time domain signal
nfft2 = 2^nextpow2(nfft); %lenght of the signal in power of 2 for higher resolution
ff = fft(rawSignal, nfft2);
fff = ff(1:nfft2/4);
xfft = Fs*(0:nfft2/4-1)/nfft2;

%signal and detection plots (for illustration)
%-------------------------------------------------------------------------
    
%x-vals for plotting
t = 1:numSamples;
t2 = 1:THnumSamples;

%clear plot window in case of previous plots
clf;

%envelope window
%xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx

%signals
%oooooooooo
h = figure();
set(h, 'visible', 'off'); %don't plot to desktop
h(1) = subplot(2,3,1:3);

%threshold window plot
plot_param = {'Color', [0 0 0.6],'Linewidth',1.5};
plot(t2, ThSignal, plot_param{:});
xlim([0 THnumSamples]);
ylim([-1.5 1.5]);
xlabel('samples');
title('Threshold Window Envelope Detection');
hold on;

%plot envelopes
plot_param = {'Color', [0 0.6 0],'Linewidth',1.5};
plot(t2,env, plot_param{:});
plot(t2,-1*env, plot_param{:});
hold on;

%Lines
%oooooooooo

%plot x axis
plot_param = {'Color', [0 0 0],'Linewidth',0.5};
plot([0 THnumSamples],[0 0], plot_param{:});
hold on;

%plot x line threshold
plot_param = {'--', 'Color', [0 0 0],'Linewidth',2};
plot([0 THnumSamples],[ threshold threshold], plot_param{:});
hold on;

%plot y line envelope maximum
plot_param = {'--', 'Color', [1 0 0],'Linewidth', 0.25};
plot([xSelPmax xSelPmax],[1.5 -1.5], plot_param{:});
hold on;

%plot y line start ZC window
plot([xsplineWStart xsplineWStart],[1.5 -1.5], plot_param{:});
hold on;

%plot y line stop ZC window
plot([xsplineWStop xsplineWStop],[1.5 -1.5], plot_param{:});
hold on;

%Legend
%oooooooooo

%lgd = legend('signal','top envelope','bottom envelope','x axis','threshold','max envelope','start ZCW','stop ZCW');
%lgd.FontSize = 5;


%Makers
%oooooooooo

%mark envelope maximum
x_pos = xSelPmax;
y_pos = MaxValFirstEnv*1.08;

description = strcat('First Pmax Envelope'); 

plot_param = {'v','MarkerEdgeColor',[1 0 0]};
plot(x_pos,y_pos,plot_param{:});
text(x_pos + 5,y_pos,description,'FontSize', 7);
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

%print MPC/scope information
%dim = [0.2 0.5 0.2 0.4];
dim = [0.14 0.52 0.2 0.4];

strFile = ['Currentfile : ', currentFileName]; 
strnumSample = ['Scope sample : ', num2str(numSignal)];  
strFlowrate = ['Flowrate testpoint : ', flowpoint];
strVelocity = ['Path velocity : ' , velocity];

str = {strFile,strnumSample,strFlowrate,strVelocity};
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
hold on;

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

