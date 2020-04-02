%input parameters
%oooooooooooooooo
clear('all');

strPath = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_07_17_cycle_skip_filter_dnvgl_data';
strFile = '06270_RQX_second_baseline.csv';

strMeterSn = '06270_RQX_baseline';

%logfile read in
%ooooooooooooooo

strFullPath = strcat(strPath,'\', strFile);
SonicData = csvread(strFullPath,1,1);


qlineAll = SonicData(:,46); %put breakpoint for determining positions start/stop flowpoint

%flowpoint data
%oooooooooooooo

flowPoints = ['24mps'; '20mps';'10mps';'05mps' ];

%FPstartStop = [600,1800;2400,2900;3300,3800;4000,4300;4600,4900]; %06270_RQX_15bar_PD
%FPstartStop = [600,1700;2200,2650;3100,3550;3700,3900;4300,4540]; %69511440_RQX_15bar_PD
FPstartStop = [200,530;600,900;1050,1400;1600,1850]; %06270_baseline
%FPstartStop = [150,450;550,850;1100,1350;1600,1850]; %06270_baseline


[numFP, ~]= size(flowPoints);

for i = 1:numFP    
    currentFP = flowPoints(i, :);
    
    Fpstart = FPstartStop(i,1);
    Fpstop = FPstartStop(i,2);
    
    
    [ PercentagesError ] = wetgasfilter( strPath, strFile, strMeterSn, currentFP, Fpstart, Fpstop, SonicData);
    
    ErrVals(i,:) = PercentagesError;
    
end

 

percentageErrorSamples = ErrVals(:,1); 
cycleSkipError = ErrVals(:,2); 

%Plots
%ooooo

f = figure();
set(f, 'visible', 'off'); %don't plot to desktop



%plot Qline all, mark start and stop flowpoints
maxY = max(qlineAll)*1.1;

f(1) = subplot(3,1,1);
plot(qlineAll);
ylim([0 3000]);
xlabel('Samples');
ylabel('Qline [m3/h]');
legend('Qline');
titlePlot = 'Qline all flowpoints';
title(titlePlot,'fontsize',12);
hold on;

%mark start stop points
for i = 1:numFP
 for y = 1:2
    currentMarker = FPstartStop(i,y);
    plot(currentMarker, qlineAll(currentMarker),'r*');
    hold on;
 end
end

%plot error shift filtered/unfiltered per flowpoint


f(2) = subplot(3,1,2);
bar(percentageErrorSamples, 'r');
if max(percentageErrorSamples) == 0
    maxYlim = 1;
else
    maxYlim = max(percentageErrorSamples)*1.1;    
end
ylim([0, maxYlim]);
ylabel('Error percentage [%]');
for i = 1:numFP
    if percentageErrorSamples(i)<10
        if percentageErrorSamples(i) == 0
            labelArray(i,:) = '00.0000%';
        else
            if percentageErrorSamples(i) < 1
                currentpercentage = num2str(percentageErrorSamples(i));
                currentpercentage = currentpercentage(1:end-1);
                labelArray(i,:) = strcat('0', currentpercentage,'%');
            else
                labelArray(i,:) = strcat('0', num2str(percentageErrorSamples(i)),'%');
            end
        end
    else
        labelArray(i,:) = strcat(num2str(percentageErrorSamples(i)),'%');
    end
end
text(1:length(percentageErrorSamples),percentageErrorSamples',labelArray,'FontSize',12,  'HorizontalAlignment','center','VerticalAlignment','bottom'); 
set(gca,'xtick',1:numFP);
set(gca,'xticklabel',flowPoints,'fontsize',12)
title('Percentage samples with Cycleskips');
hold on;

f(3) = subplot(3,1,3);
bar(cycleSkipError, 'r');
if max(cycleSkipError) == 0
    maxYlim = 1;
else
    maxYlim = max(cycleSkipError)*1.1;
end
ylim([0, maxYlim]);
ylabel('Error percentage [%]');
cycleSkipError = round(cycleSkipError, 4);
for i = 1:numFP        
        if percentageErrorSamples(i) == 0
            labelArray2(i,:) = '0.000%';
        else
            currentLabel = strcat( num2str(cycleSkipError(i)),'%');
            labelArray2(i,:) = currentLabel;
        end
end
text(1:length(cycleSkipError),cycleSkipError',labelArray2,'FontSize',12,  'HorizontalAlignment','center','VerticalAlignment','bottom'); 
set(gca,'xtick',1:numFP);
set(gca,'xticklabel',flowPoints,'fontsize',12)
title('Error shift filtered/unfiltered samples');
hold on;

%save graph to folder
outputFolder = strcat(strPath, '\samples_meter_', strMeterSn);

if ~exist(outputFolder, 'dir')
   mkdir(outputFolder)
end

savedir = strcat(outputFolder,'\overview_all_flowpoints.png');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 15 9]);
saveas(gcf,savedir,'png');

