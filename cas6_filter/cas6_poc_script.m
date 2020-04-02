%cas 6 proof of concept

%input parameters
%oooooooooooooooo
clear('all');

% strPath = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\cas6_filter';
% strFile = 'cas6_24mps_15bar_PD_dataset.csv';

strPath = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_08_29_DNVGL_pressure_drop_RQX_dataset_production_meter';
strFile = '69511440_RQX_15bPD_trimmed.csv';


errorBandwith = 0.03; 
longDirectRatio = 1.11;
shortDirectTRatio = 1;
shortDirectBRatio = 1;

pathTypesCAS6 = [4,4,1,1,3,3]; %stay as close as possible to meter types inside meter 'short direct bottom' will use path type 3

outputFolderFigs = strcat(strPath, '\figures');

if ~exist(outputFolderFigs, 'dir')
   mkdir(outputFolderFigs)
end

%logfile read in
%ooooooooooooooo

strFullPath = strcat(strPath,'\', strFile);
SonicData = csvread(strFullPath,1,1);


qlineAll = SonicData(:,46); %put breakpoint for determining positions start/stop flowpoint

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


%Data processing
%oooooooooooooooooo

%select vog values
vogVals = SonicData(:,vogStart:vogStop);
directVogvals = [vogVals(:,1:2), vogVals(:,5:6)];

[numSamples, ~] = size(vogVals);


medianVog = median(vogVals);

DirectMedianVals = [medianVog(1:2), medianVog(5:6)];

medianDirect = median(DirectMedianVals);

highLim = (medianDirect*1.035)*ones(numSamples);
lowLim = (medianDirect*0.965)*ones(numSamples);

try

for i = 1:numSamples
    currentSampleVogVals = vogVals(i,:);
    currentPerformanceVals = SonicData(i,2:7);
    
    currentSampleDirect = [currentSampleVogVals(1:2), currentSampleVogVals(5:6); 1,2,3,4];
    currentPerformanceValsDirect = [currentPerformanceVals(1:2),currentPerformanceVals(5:6); 1,2,3,4];    

   
    %sort paths in order of vogvals, give biast to 3th highest path (2
    %paths need to working properly, 3th value is to catch upwards cycle
    %skips
    
    allPerf = currentPerformanceValsDirect(1,:);
    firstPerf  = currentPerformanceValsDirect(1,1);
        
    [~, order] = sort(currentSampleDirect(1,:));
    DirectsSortedByHighestVogVal = currentSampleDirect(:,order);

    testval = currentSampleDirect(1,DirectsSortedByHighestVogVal(2,3));

    leadPath(i) = find(currentSampleVogVals==testval);
    
    %calculate bandWidthVal by appling the errobandwith percentage to the
    %testval, this needs to be corrected with the lead path ratio.
    
    switch pathTypesCAS6(leadPath(i))
        case 4
            
            neutralRatioVal = testval/shortDirectTRatio;
            bandWidthVal = neutralRatioVal * errorBandwith;
            
        case 3
            
            neutralRatioVal = testval/shortDirectBRatio;
            bandWidthVal = neutralRatioVal * errorBandwith;
            
    end
    
    
    highLimVal(i,:) = [0,0,0];
    lowLimVal(i,:) = [0,0,0];
    
    highLimVal(i,1) = (neutralRatioVal * shortDirectTRatio) + bandWidthVal;
    lowLimVal(i,1) = (neutralRatioVal * shortDirectTRatio) - bandWidthVal;
    
    highLimVal(i,2) = (neutralRatioVal * longDirectRatio) + bandWidthVal;
    lowLimVal(i,2) = (neutralRatioVal * longDirectRatio) - bandWidthVal;    
    
    highLimVal(i,3) = (neutralRatioVal * shortDirectBRatio) + bandWidthVal;
    lowLimVal(i,3) = (neutralRatioVal * shortDirectBRatio) - bandWidthVal;
    
    currentSampleValidPaths = [0, 0, 0, 0, 0, 0];    
    
    
    for y = 1:6
        switch y
            case {1,2}           
                if currentSampleVogVals(y) < highLimVal(i,1) && currentSampleVogVals(y) > lowLimVal(i,1)
                    currentSampleValidPaths(y) = 1;
                end                
            case {3,4}
                if currentSampleVogVals(y) < highLimVal(i,2) && currentSampleVogVals(y) > lowLimVal(i,2)
                    currentSampleValidPaths(y) = 1; 
                end
            case {5,6}
                if currentSampleVogVals(y) < highLimVal(i,3) && currentSampleVogVals(y) > lowLimVal(i,3)
                    currentSampleValidPaths(y) = 1; 
                end
        end
    end
    
    SampleValidPaths(i,:) = currentSampleValidPaths;
    
    

    
    %check if there are paths from current and previous cycle that have 2
    %valid samples in a row. if so calculate ratio corrected increase in
    %flow. If not use lead path. On first cycle increase = 0.    
  
    if i ~= 1     
        
        sumValidIncrease = 0;
        numValidIncreaseVals = 0;
        
        for y = 1:6            
            switch y
                case {1,2}           
                    if SampleValidPaths(i,y)== 1 && SampleValidPaths(i-1,y)==1
                        currentIncreasVal = vogVals(i,y) - vogVals(i-1,y);
                        sumValidIncrease = currentIncreasVal/shortDirectTRatio;
                        numValidIncreaseVals = numValidIncreaseVals + 1;
                    end                
                case {3,4}
                    if SampleValidPaths(i,y)== 1 && SampleValidPaths(i-1,y)==1
                        currentIncreasVal = vogVals(i,y) - vogVals(i-1,y);
                        sumValidIncrease = currentIncreasVal/longDirectRatio;
                        numValidIncreaseVals = numValidIncreaseVals + 1;
                    end
                case {5,6}
                    if SampleValidPaths(i,y)== 1 && SampleValidPaths(i-1,y)==1
                        currentIncreasVal = vogVals(i,y) - vogVals(i-1,y);
                        sumValidIncrease = currentIncreasVal/shortDirectBRatio;
                        numValidIncreaseVals = numValidIncreaseVals + 1;
                    end     
            end
        end
            
        if sumValidIncrease ~= 0
            neutralIncrease = sumValidIncrease/numValidIncreaseVals;
        else
            leadPath(i) 
            neutralIncrease = vogVals(i,leadPath(i)) - vogVals(i-1,leadPath(i));
        end
        
    end
    
    %for testing, set break on faulty lead path detection sample
    
    if i == 5
        test = 1;
    end
    
    %correct invalid paths by adjusting their previous vog value with the
    %neutralIncrease * path type ratio. on first cycle use lead path with
    %ratio correction (lead to neutral, neutral to raitiofailpath)
    

    currentCorrectedVogVals = [0, 0, 0, 0, 0, 0];    

    
    for y = 1:6
        if SampleValidPaths(i,y) == 0
            if i ~= 1
                switch y
                    case {1,2}           
                        currentCorrectedVogVals(y) = CorrectedVogVals(i-1,y) + (neutralIncrease * shortDirectTRatio);

                    case {3,4}
                        currentCorrectedVogVals(y) = CorrectedVogVals(i-1,y) + (neutralIncrease * longDirectRatio);

                    case {5,6}
                        currentCorrectedVogVals(y) = CorrectedVogVals(i-1,y) + (neutralIncrease * shortDirectBRatio);
                end 
            else
                switch y
                    case {1,2}           
                        neutralVog = vogVals(i,leadPath(i))/shortDirectTRatio;

                    case {5,6}
                        neutralVog = vogVals(i,leadPath(i))/shortDirectBRatio;
                end            

                switch y
                    case {1,2}           
                        currentCorrectedVogVals(y) = neutralVog * shortDirectTRatio;

                    case {3,4}
                        currentCorrectedVogVals(y) = neutralVog *  longDirectRatio;

                    case {5,6}
                        currentCorrectedVogVals(y) = neutralVog * shortDirectBRatio;
                end   

                currentCorrectedVogVals(y) = neutralVog;
            end
        else
            currentCorrectedVogVals(y) = vogVals(i,y);
        end
    end
    
    CorrectedVogVals(i,:) = currentCorrectedVogVals;
    
    [QlineRC(i), ] =  QlineCalc(currentCorrectedVogVals);
    
end
%filtering points without cycle skip to have reference data set

%trim sonic log by data

qline = SonicData(:,MeterConfig.dataPosLog.Qline);

%filter out error points by hlCuttoff
[rows,~] = size(SonicData);

for i = rows:-1:1
    if SonicData(i,MeterConfig.dataPosLog.Qline) > 9999999
        SonicData(i,:) = [];
    end
end

qlineWE = SonicData(:,MeterConfig.dataPosLog.Qline);

vogWE = SonicData(:,vogStart:vogStop);

%apply bandfilter to isolate the point that fall within the nominal
%testpoint value, eliminating big cycleskips
bandFilter = 0.01;
nominalValue = 2370;

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

catch exception
    test = exception
    test2 = i
    
end
%plot direct vogvals




qlineFilt = SonicData(:,MeterConfig.dataPosLog.Qline);
vogFilt = SonicData(:,vogStart:vogStop);

avgQllineRaW = mean(qlineAll);
avgQlineMedianFilt = mean(qlineFilt);
avgQlineRC = mean(QlineRC);

errorPercentageQlineRaw = round(abs(((avgQllineRaW/avgQlineMedianFilt)-1)*100),5);
errorPercentageCAS9 = round(abs(((avgQlineRC/avgQlineMedianFilt)-1)*100),5);

f1= figure();
%set(f1, 'visible', 'off');
yLimMinF = min(min(vogVals));
yLimMaxF = max(max(vogVals));
h = plot(vogVals);
set(h, {'color'}, {[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]});
hold on;
ylim([yLimMinF yLimMaxF]);
xlabel('Samples');
ylabel('VoG per path [m/s]');
legend('P1', 'P2', 'P3', 'P4', 'P5', 'P6');
titlePlot = 'Highest flowpoint - all paths - Lead path marked';
title(titlePlot,'fontsize',12);
plot(highLimVal(:,1), 'r', 'LineWidth',2, 'LineStyle', '--');
hold on;
plot(lowLimVal(:,1), 'r', 'LineWidth',2, 'LineStyle', '--');
hold on;
plot(highLimVal(:,2), 'y', 'LineWidth',2, 'LineStyle', '--');
hold on;
plot(lowLimVal(:,2), 'y', 'LineWidth',2, 'LineStyle', '--');
hold on;
for i = 1:numSamples  
  plot(i,vogVals(i,leadPath(i)),'r*');
  hold on
end

%save graph to folder
savedir = strcat(outputFolderFigs,'\Marked_priorityPath_1');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 15 9]);
saveas(gcf,savedir,'png');


%short direct top focus
f2= figure();
%set(f2, 'visible', 'off');
yLimMinSDT = min(min(vogVals(:,1:2)));
yLimMaxSDT = max(max(vogVals(:,1:2)));
h = plot(vogVals(:,1:2));
set(h, {'color'}, {[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]});
hold on;
ylim([yLimMinSDT yLimMaxSDT]);
xlabel('Samples');
ylabel('VoG per path [m/s]');
legend('P1', 'P2');
plot(highLimVal(:,1), 'r', 'LineWidth',2, 'LineStyle', '--');
hold on;
plot(lowLimVal(:,1), 'r', 'LineWidth',2, 'LineStyle', '--');
hold on;
titlePlot = 'Highest flowpoint -  Short Direct top isolated - faulty samples marked';
title(titlePlot,'fontsize',12);
for i = 1:numSamples
  for y = 1:2
    if SampleValidPaths(i,y) == 0
        plot(i,vogVals(i,y),'b*');
        hold on       
    end
  end
end
%save graph to folder
savedir = strcat(outputFolderFigs,'\short_direct_top_CS_marked_2');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 15 9]);
saveas(gcf,savedir,'png');


%long direct focus
f3= figure();
%set(f3, 'visible', 'off');
yLimMinLD = min(min(vogVals(:,3:4)));
yLimMaxLD = max(max(vogVals(:,3:4)));
h = plot(vogVals(:,3:4));
set(h, {'color'}, {[0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]});
hold on;
ylim([yLimMinLD yLimMaxLD]);
xlabel('Samples');
ylabel('VoG per path [m/s]');
legend('P3', 'P4');
plot(highLimVal(:,2), 'r', 'LineWidth',2, 'LineStyle', '--');
hold on;
plot(lowLimVal(:,2), 'r', 'LineWidth',2, 'LineStyle', '--');
hold on;
titlePlot = 'Highest flowpoint -  Long Directs isolated - faulty samples marked';
title(titlePlot,'fontsize',12);
for i = 1:numSamples
  for y = 3:4
    if SampleValidPaths(i,y) == 0
        plot(i,vogVals(i,y),'b*');
        hold on       
    end
  end
end

%save graph to folder
savedir = strcat(outputFolderFigs,'\long_direct_top_CS_marked_3');
%set(gcf,'PaperUnits','inches','PaperPosition',[0 0 15 9]);
saveas(gcf,savedir,'png');

%short direct bottom focus
f4= figure();
%set(f4, 'visible', 'off');
yLimMinSDB = min(min(vogVals(:,5:6)));
yLimMaxSDB = max(max(vogVals(:,5:6)));
h = plot(vogVals(:,5:6));
set(h, {'color'}, {[0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]});
hold on;
ylim([yLimMinSDB yLimMaxSDB]);
xlabel('Samples');
ylabel('VoG per path [m/s]');
legend('P5', 'P6');
plot(highLimVal(:,3), 'r', 'LineWidth',2, 'LineStyle', '--');
hold on;
plot(lowLimVal(:,3), 'r', 'LineWidth',2, 'LineStyle', '--');
hold on;
titlePlot = 'Highest flowpoint -  Short Direct bottom isolated - faulty samples marked';
title(titlePlot,'fontsize',12);
for i = 1:numSamples
  for y = 5:6
    if SampleValidPaths(i,y) == 0
        plot(i,vogVals(i,y),'b*');
        hold on       
    end
  end
end


%save graph to folder
savedir = strcat(outputFolderFigs,'\short_direct_bottom_CS_marked_4');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 15 9]);
saveas(gcf,savedir,'png');

%correct vog values with adaptive path substitution
f5= figure();
%set(f5, 'visible', 'off');
yLimMin = min(min(CorrectedVogVals));
yLimMax = max(max(CorrectedVogVals));
h = plot(CorrectedVogVals);
set(h, {'color'}, {[0 0.4470 0.7410]; [0.8500 0.3250 0.0980]; [0.9290 0.6940 0.1250]; [0.4940 0.1840 0.5560]; [0.4660 0.6740 0.1880]; [0.3010 0.7450 0.9330]});
hold on;
ylim([yLimMinF yLimMaxF]);
xlabel('Samples');
ylabel('VoG per path [m/s]');
legend('P1', 'P2', 'P3', 'P4', 'P5', 'P6');
titlePlot = 'filtered vog values with adaptive substitution';
title(titlePlot,'fontsize',12);

for i = 1:numSamples
  for y = 1:6
    if SampleValidPaths(i,y) == 0
        plot(i,CorrectedVogVals(i,y),'g*');
        hold on       
    end
  end
end

%save graph to folder
savedir = strcat(outputFolderFigs,'\vog_vals_corrected_5');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 15 9]);
saveas(gcf,savedir,'png');



%correct vog values with adaptive path substitution
f6= figure();
%set(f6, 'visible', 'off');
subplot(2,1,1);
yLimMin = min(qlineAll);
yLimMax = max(qlineAll);
h = plot(qlineAll);
hold on;
h = plot(QlineRC', 'LineWidth',3);
hold on;
ylim([yLimMin yLimMax]);
xlabel('Samples');
ylabel('Qline[m3/h]');
legend('Qline meter', 'Qline Recalculated');
titlePlot = 'Qline Recalculated vs Qline meter';
title(titlePlot,'fontsize',12);

ErrorsQline = [0,errorPercentageQlineRaw,errorPercentageCAS9,0];
subplot(2,1,2);
bar(ErrorsQline, 'r');
hold on;
ylim([0, 1.5]);
ylabel('Error percentage [%]');
cycleSkipError = round(ErrorsQline, 4);    
currentLabel1 = strcat( num2str(cycleSkipError(2)),'%');
currentLabel2 = strcat( '0',num2str(cycleSkipError(3)),'%');
labelArray = {'        ',currentLabel1, currentLabel2, '        '};
text(1:4,cycleSkipError',labelArray,'FontSize',12,  'HorizontalAlignment','center','VerticalAlignment','bottom'); 
set(gca,'xtick',1:2);
errorLabels = {' ';'Qline RAW'; 'Qline CAS6';' '};
set(gca,'xtick',[1:5],'xticklabel',errorLabels)
title('Error shift filtered/unfiltered samples');
hold on;

%save graph to folder
savedir = strcat(outputFolderFigs,'\QlineRaw_vs_CAS6_6');
set(gcf,'PaperUnits','inches','PaperPosition',[0 0 15 9]);
saveas(gcf,savedir,'png');




