function TestLPF()

%import csv
pathname = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\MPC_lowpassfilter\MPC_sample\'; 
filename = 'sample_MPC.csv';

scopeSample = 0; %select data processing between scope or MPC sample


strFullPath = strcat(pathname, filename);

if scopeSample == true
    data=importdata(strFullPath, ',',3);
    csvDataSelectPath = data.data(:,2)';
    
else    
    

    data=importdata(strFullPath, ',',0);
    csvdata = data.data;


    %trim csv matrix to signal only
    csvdata = csvdata(:,25:end-5);

    %select specific signal
    pathNumber = 1;
    pathSide = 0; % 0 = a-side, 1 = b-side

    selectedRowCsv = (pathNumber*2) - 1 + pathSide;

    csvDataSelectPath = csvdata(selectedRowCsv, :);
end

csvNormalized = csvDataSelectPath/max(csvDataSelectPath);


%generate time x values

sampleStartVos = 300;
sampleStopVos = 500;

pathLenght = 0.43;

startTimeSW = pathLenght/sampleStopVos;
stopTimeSW = pathLenght/sampleStartVos;

[~,numSamples] = size(csvDataSelectPath);

sampleTime = (stopTimeSW - startTimeSW)/numSamples;

Ts = startTimeSW+sampleTime:sampleTime:stopTimeSW;

MpcSamples = 1:numSamples;

%fft normal signal

Fs = 3125000; %sample rate ADC NGQ = 3125000 / scope 2000000000
nfft = length(csvNormalized); %length of the time domain signal
nfft2 = 2^nextpow2(nfft); %lenght of the signal in power of 2 for higher resolution
ff = fft(csvNormalized, nfft2);
fff = ff(1:nfft2/4);
xfft = Fs*(0:nfft2/4-1)/nfft2;


%apply digital filter (both hpf & lpf)

digFilt = designfilt('lowpassfir', 'FilterOrder', 60, 'CutoffFrequency', 190000, 'SampleRate', 3125000); %sample rate ADC NGQ = 3125000 / scope 2000000000
HPFdigFilt = designfilt('highpassfir', 'FilterOrder', 80, 'CutoffFrequency', 180000, 'SampleRate', 3125000);%sample rate ADC NGQ = 3125000 / scope 2000000000

filteredCSV = filtfilt(digFilt, csvNormalized);
HPFfilteredCSV = filtfilt(HPFdigFilt, csvNormalized);


filteredCSV = filteredCSV/max(filteredCSV);
HPFfilteredCSV = HPFfilteredCSV/max(HPFfilteredCSV);

%fft LPF signal
Fs = 3125000; %sample rate ADC NGQ = 3125000 / scope 2000000000
nfft = length(filteredCSV); %length of the time domain signal
nfft2 = 2^nextpow2(nfft); %lenght of the signal in power of 2 for higher resolution
ff = fft(filteredCSV, nfft2);
ffff = ff(1:nfft2/4);
xfft = Fs*(0:nfft2/4-1)/nfft2;

%fft HPF signal
nfft = length(HPFfilteredCSV); %length of the time domain signal
nfft2 = 2^nextpow2(nfft); %lenght of the signal in power of 2 for higher resolution
ff = fft(HPFfilteredCSV, nfft2);
fffff = ff(1:nfft2/4);
xfft = Fs*(0:nfft2/4-1)/nfft2;


%plots

%zoom variables
plotsamplestart = 800;
zoomstart = 1100;
zoomstop = 1400;

%normal signal
subplot(3,2,1);
plot(MpcSamples(plotsamplestart:end), csvNormalized(plotsamplestart:end));
ylim([-1 1]);
xlim([plotsamplestart numSamples]);
xlabel('samples');
title('MPC unfiltered');

%lpf filtered signal
subplot(3,2,3);
plot(MpcSamples(plotsamplestart:end), filteredCSV(plotsamplestart:end));
ylim([-1 1]);
xlim([plotsamplestart numSamples]);
xlabel('samples');
title('MPC LPF');

%hpf filtered signal
subplot(3,2,2);
plot(MpcSamples(plotsamplestart:end), HPFfilteredCSV(plotsamplestart:end));
ylim([-1 1]);
xlim([plotsamplestart numSamples]);
xlabel('samples');
title('MPC HPF');

%fft all signals
subplot(3,2,4);
plot(MpcSamples(plotsamplestart:end), filteredCSV(plotsamplestart:end));
hold on;
plot(MpcSamples(plotsamplestart:end), HPFfilteredCSV(plotsamplestart:end));
hold on;
bigCsvNormalized = csvNormalized * 4;
plot(MpcSamples(plotsamplestart:end), bigCsvNormalized(plotsamplestart:end), 'LineWidth', 2);
ylim([-4 4]);
xlim([zoomstart zoomstop]);
xlabel('samples');
title('MPC combined');
legend;
legend('signal LPF','signal HPF','signal Combined');


subplot(3,2,5:6);
plot(xfft,abs(ffff));
hold on;
plot(xfft,abs(fffff));
hold on;
plot(xfft,abs(fff),'LineWidth', 2);
xlabel('Frequency spectrum');
legend;
legend('fft LPF filtered','fft HPF filtered','fft unfiltered');
title('fft unfiltered/filtered');

end

