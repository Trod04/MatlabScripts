function [ PercentagesError ] = wetgasfilter( strPath, strFile, strMeterSn, flowPoint, fpSampleStart, fpSampleStop, SonicData)
%input parameters script
%ooooooooooooooooooooooo

%input data for single use processing

% strPath = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\wetgasfilter';
% strFile = '06270_day_02_RQX_trim_15bar_PD_start_9.15.csv';
% 
% MeterSn = 06270;
% strMeterSn = num2str(MeterSn);
% 
% flowPoint = '20_mps';
% 
% fpSampleStart = 2500;
% fpSampleStop = 2800;

hlCutoff = 4000; %high limit cutoff point


%Collect meter Info
%oooooooooooooooooo

%input by user
meterSize = 8;
meterType = 74;

%compose and collect meter specific data, size and or metertype might need
%to be added
MeterConfig = MeterParameterConfig(meterSize, meterType);
MeterConfig.dataPosLog = dataPosSE(MeterConfig);


%used Sonic data locations
vogStart = MeterConfig.dataPosLog.vogPath;
vogStop = MeterConfig.dataPosLog.vogPath + MeterConfig.numPaths - 1;



%Select flowpoint and filter out error points
%oooooooooooooooooooooooooooooooooooooooooooo

%trim sonic log by data

SonicData = SonicData(fpSampleStart:fpSampleStop, :);

qline = SonicData(:,MeterConfig.dataPosLog.Qline);

%filter out error points by hlCuttoff
[rows,~] = size(SonicData);

for i = rows:-1:1
    if SonicData(i,MeterConfig.dataPosLog.Qline) > hlCutoff
        SonicData(i,:) = [];
    end
end

qlineWE = SonicData(:,MeterConfig.dataPosLog.Qline);

vogWE = SonicData(:,vogStart:vogStop);
avgWE = mean(qlineWE);

%apply bandfilter to isolate the point that fall within the nominal
%testpoint value, eliminating big cycleskips
bandFilter = 0.01;
nominalValue = 2370;

highLimit = nominalValue * (1 + bandFilter);
lowLimit = nominalValue * (1 - bandFilter);

[rows,~] = size(SonicData);

medianVog = median(vogWE);
vogBand = 0.5;

for i = rows:-1:1
    for y = 1:MeterConfig.numPaths
        highLim = medianVog(y) + vogBand;
        lowLim = medianVog(y) - vogBand;
        
        currentPath = vogStart + y - 1;
        currentVal = SonicData(i,currentPath);
        
        blnPathValid(y) = 1;
        
        if currentVal > highLim || currentVal < lowLim
            blnPathValid(y) = 0;
        end         
    end
    
    validSample =1;
    
    for z = 1:MeterConfig.numPaths
        validSample = validSample * blnPathValid(z);
    end
        
    if ~validSample 
        SonicData(i,:) = [];
    end
end


qlineFilt = SonicData(:,MeterConfig.dataPosLog.Qline);
vogFilt = SonicData(:,vogStart:vogStop);

%temp for data analysis

% longdirectavg = mean(mean(vogFilt(:,3:4)))
% longdirectmin = min(min(vogFilt(:,3:4)))
% longdirectmax = max(max(vogFilt(:,3:4)))
% shorttopdirectavg = mean(mean(vogFilt(:,1:2)))
% shorttopdirectmin = min(min(vogFilt(:,1:2)))
% shorttopdirectmax = max(max(vogFilt(:,1:2)))
% shortbottomdirectavg = mean(mean(vogFilt(:,5:6)))
% shortbottomdirectmin =min(min(vogFilt(:,5:6)))
% shortbottomdirectmax =max(max(vogFilt(:,5:6)))

avgFilt = mean(qlineFilt);

cycleSkipError = abs((avgWE/avgFilt - 1)*100);

[samples,~] = size(vogWE);
[samplesFilt,~] = size(vogFilt);

percentageErrorSamples = (1 - samplesFilt/samples)*100;

%output parameter script
PercentagesError = [percentageErrorSamples cycleSkipError];

%Plots
%ooooo

h = figure();
set(h, 'visible', 'off'); %don't plot to desktop

%yscale VoG

minY = min(min(vogWE))*0.9;
maxY = max(max(vogWE))*1.1;

%plot flowpoint vog RAW


h(1) = subplot(3,2,1);
plot(vogWE);
ylim([minY maxY]);
xlabel('Samples');
ylabel('Velocity [m/s]');
legend('path 1', 'path 2', 'path 3','path 4', 'path 5', 'path 6');
titlePlot = strcat('Unfiltered VOG: ', flowPoint);
title(titlePlot);
hold on;

%plot flowpoint vog Filtered


h(2) = subplot(3,2,2);
plot(vogFilt);
ylim([minY maxY]);
xlabel('Samples');
ylabel('Velocity [m/s]');
legend('path 1', 'path 2', 'path 3','path 4', 'path 5', 'path 6');
titlePlot = strcat('Filtered VOG: ', flowPoint);
title(titlePlot);
hold on;

%yscale Qline

minY = min(qlineWE)*0.9;
maxY = max(qlineWE)*1.1;

%plot Qline Unfiltered

h(3) = subplot(3,2,3);
plot(qlineWE);
ylim([minY maxY]);
xlabel('Samples');
ylabel('Qline [m3/h]');
legend('Qline Unfiltered');
titlePlot = strcat('Unfiltered Qline: ', flowPoint);
title(titlePlot);
hold on;

%plot Qline Filtered

h(4) = subplot(3,2,4);
plot(qlineFilt);
ylim([minY maxY]);
xlabel('Samples');
ylabel('Qline [m3/h]');
legend('Qline Filtered');
titlePlot = strcat('Filtered Qline: ', flowPoint);
title(titlePlot);
hold on;

%plot error percentages
perCycle = [0.00001 cycleSkipError 0.00001];
perErrSamples = [0.00001 percentageErrorSamples 0.00001];

h(5) = subplot(3,2,5);
bar(perCycle, 'r');
if cycleSkipError == 0
    ylim([0 1]);
else
    ylim([0 (cycleSkipError * 1.5)]);
end
ylabel('Error percentage [%]');
strLabel = strcat(num2str(cycleSkipError,'%0.4f'), '%');
text(2, cycleSkipError, strLabel,'FontSize',16, 'HorizontalAlignment','center','VerticalAlignment','bottom')
set(gca,'XTick',[]);
title('Error shift % filtered/unfiltered');
hold on;

h(6) = subplot(3,2,6);
bar(perErrSamples, 'r');
if percentageErrorSamples == 0
    ylim([0 1]);
else
    ylim([0 (percentageErrorSamples  * 1.5)]);
end
ylabel('Error percentage [%]');
strLabel = strcat(num2str(percentageErrorSamples,'%0.4f'), '%');
text(2, percentageErrorSamples, strLabel,'FontSize',16, 'HorizontalAlignment','center','VerticalAlignment','bottom')
set(gca,'XTick',[]);
title('Percentage samples with Cycleskips');
hold on;


%save plot to samples folder
outputFolder = strcat(strPath, '\samples_meter_', strMeterSn);

if ~exist(outputFolder, 'dir')
   mkdir(outputFolder)
end

savedir = strcat(outputFolder,'\processed_flowpoint_', flowPoint, '.png');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 15 9]);
saveas(gcf,savedir,'png');


end




