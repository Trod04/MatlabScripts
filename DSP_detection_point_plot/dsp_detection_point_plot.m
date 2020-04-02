%simple signal path plot + DSP detection point mark
%################################################

%input parameters
%oooooooooooooooo

strPath = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\workflow\2019_09_28_offset_investigation\';
strFile = 'MPC_8inch_20bar_nitrogen_no_climate_control_6D_config_SB.csv';

pathNum = 6;
numPlotLineCSV = pathNum * 2 - 1;

splinestartDT = -3;
splinestopDT = 14;

numsplinePoints = splinestopDT - splinestartDT + 1;

%read CSV data
%oooooooooooooooo

strFullPath = strcat(strPath,strFile);

data=importdata(strFullPath, ',',0);
csvdata = data.data;

%signal plot data
%ooooooooooooooooo

%gather signal data from path to plot
signalData = csvdata(numPlotLineCSV:numPlotLineCSV + 1, 25:end-30);

%normalize signal
maxValArray = max(max(signalData));
minValArray = abs(min(min(signalData)));

if maxValArray > minValArray
    signalData = signalData/maxValArray;
else
    signalData = signalData/minValArray;
end

%gather detection point data from DSP and correct for missing samples
numSampleDetectionPoint = csvdata(numPlotLineCSV:numPlotLineCSV + 1, end-1);
numSampleDetectionPoint = numSampleDetectionPoint - 20;

%generate samples array
[~, numSamplesSignalData] = size(signalData);
t = 1:numSamplesSignalData;

%zero cross calculation
%oooooooooooooooooooooo
zeroCrosses = zeros(numsplinePoints,4,2);

for i = 1:2
    currentZC = splineCalculation(signalData(i,:), numSampleDetectionPoint(i), splinestartDT, splinestopDT, numsplinePoints);
    zeroCrosses(:,:,i)  = currentZC;
end


%calculate transit times
%ooooooooooooooooooooooo

%calculate diffTT for all zerocross positions
ttDiffAll = zeros(numsplinePoints,4);

for x = 1:4
    for i = 1:numsplinePoints
        ttDiffAll(i,x) = zeroCrosses(i,x,2)-zeroCrosses(i,x,1);
    end
end

%compose csv data output, format = (TTab: sample ZC current peak, Tdiff
%current and previous peak, Freq current and previous peak) x 3 (ZC poly,
%ZC interp1, ZC max slope) x 2(same for TTba), 3x ttdiff (ZC, ZCinterp1,
%ZCslope)

%AB path information

for i = 1:2
    for y = 1:4
        
        %first data column A/Bpath           
        if i == 1 && y == 1
            ZCinfoAll = zeroCrosses(:,y,i);
        else
            ZCinfoAll = [ZCinfoAll, zeroCrosses(:,y,i)];
        end
        
        %calculate sample time diff ZC's in combination with corresponding
        %Freqs
        freqTransitionPeaks = zeros(numsplinePoints,1);
        
        for z = 2: numsplinePoints
            splineSamplediff = zeroCrosses(z,y,i) - zeroCrosses(z-1,y,i); %sample diff
            ttDiffcurrentPeak = splineSamplediff * 0.000000320; %time in ns
            
            %pktpk = half a freq cycle
            freqTransitionPeaks(z) = 1/ttDiffcurrentPeak/2;
            
        end
        
        ZCinfoAll = [ZCinfoAll, freqTransitionPeaks];
    end
end

%add sample diff and ttdiff times all ZC methods

ZCinfoAll = [ZCinfoAll, ttDiffAll];
ZCinfoAll = [ZCinfoAll, ttDiffAll*320]; %time in ns


ttDiffOld = ttDiffAll(abs(splinestartDT)+1,1);
ttDiffMultiSpline = mean(ttDiffAll(12:14,1));

improvementfactor = 1/(abs(ttDiffMultiSpline)/abs(ttDiffOld));

%plot signals
%oooooooooooooo

%A
plot_param = {'Color', [0 0 0.6],'Linewidth',0.5};
plot(t, signalData(1,:), plot_param{:});
hold on;

%B
plot_param = {'Color', [0 0.6 0],'Linewidth',0.5};
plot(t, signalData(2,:), plot_param{:});
hold on;

%set limits
xlim([numSampleDetectionPoint(1)-100 numSampleDetectionPoint(1)+150]);
ylim([-1.2 1.2]);
xlabel('samples');
strTitle = strcat('A-B signal with DSP detection point marked - path: ', num2str(pathNum));
title(strTitle);
hold on;

%mark detection points dsp
for i = 1:2
   xPos = numSampleDetectionPoint(i);
   yPos = signalData(i,xPos);
   yPosB = signalData(i,xPos-1);
   
   %plot DSP detection point
   plot_param = {'v','MarkerEdgeColor',[1 0 1]};
   plot(xPos,yPos,plot_param{:});
   
   %plot exact zero cross points
   
   if i == 1
       plot_param = {'o','MarkerEdgeColor',[0 0 1]};
   else
       plot_param = {'o','MarkerEdgeColor',[0 1 0]};
   end

%    if i == 1      
%        strMarker = 'o';
%    else
%        strMarker = 'x';
%    end
   

   for y = 1:numsplinePoints%        
       plot(zeroCrosses(y,4,i),0,plot_param{:});        
   end
   

%    plot_param = {strMarker,'MarkerEdgeColor',[0 0 1]};
%    plot(zeroCrosses(4,1,i),0,plot_param{:});
%    
%    plot_param = {strMarker,'MarkerEdgeColor',[0 1 0]};
%    plot(zeroCrosses(4,3,i),0,plot_param{:});        
% 
%    
%    plot_param = {strMarker,'MarkerEdgeColor',[1 0 0]};
%    plot(zeroCrosses(4,4,i),0,plot_param{:});
   
   hold on;

end

legend('sig_a', 'sig_b');
hold on;

% ttDiffAll = ttDiffAll*320;
% test = 0;
% 
% zeroCrosses = zeroCrosses'; %for excel processing
% 
% ttDiffMultiSpline = mean(ttDiffAll(4:8)); %selected points for excel processing
% 
% vograwOldCalc = TT_calc( 350, 0.175, ttDiffAll(4)*320) 
% vograwmultispline = TT_calc( 350, 0.175, ttDiffMultiSpline*320)
% vogtestCalc = TT_calc( 350, 0.175, 1);
% 
% strImprovement = strcat('ImprovementFactor: ', num2str(improvementfactor));
% annotation('textbox', [0.15, 0.75, 0.1, 0.1], 'String', strImprovement);
% hold on;

