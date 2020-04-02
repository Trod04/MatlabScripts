
%LF_recalc
%
%Date Modified:     03-07-2019
%Author:            TROD
%Description:       Low flow recalculation script based on different zero cross peaks
%--------------------------------------------------------------------------

%Script data and parameters
%oooooooooooooooooooooooooo

%script parameters
numPaths = 8;
meterSize = 8;
meterType = 68;

Vos = 350;

PInfo  = pathInfo(meterSize, meterType)';

%Sample file
pathDir = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\LowFlow_recalc\sample';
fileName = 'a2_offset.csv';

fullPath = strcat(pathDir, '\',fileName );

%data processing
%ooooooooooooooo

%LoadMPC
CSVdata = LoadMPC_LF(fullPath,numPaths);

sampleData = CSVdata.samples;
ZC = CSVdata.ZC';

%determine inversion paths, 1 = positive, 0 = negative

abPathNums = (numPaths*2);
zcVal = 0;

for i = 2:2:abPathNums
    currentZC = ZC(i);
    currentPathNum = i/2;
    
    zcVal(currentPathNum) = sampleData(i, currentZC);
    
    if zcVal(currentPathNum) >=0
        invPath(currentPathNum) = 0;
    else
        invPath(currentPathNum) = 1;
    end
   
end

invPath = invPath';

%spline points original zerocross

numSplinePoints = 4; %use even numbers only

TTinfo = splinePointcalc( numPaths, ZC, sampleData, numSplinePoints);

orExZC = TTinfo.exactZC;
orTTdiff = TTinfo.TTab;

%find sample after zerocross next peak
for i = 1:numPaths*2
    currentsamples = sampleData(i,:);
    
    %find all positions in MPC were there is a zerocross
    allZCsample = find(currentsamples(:).*circshift(currentsamples(:), [-1 0]) <= 0);
    
    %determine zercross position between slope next peak, correct with 1
    %sample as the zerocross function selects the sample before, not after
    %as the DSP does it
    minValZC = ZC(i) + 12;
    maxValZC = ZC(i) + 22;   
    
    SecondZC(i) = allZCsample(find(allZCsample > minValZC & allZCsample < maxValZC)) + 1;   
end

SecondZC = SecondZC';

%spline points original zerocross

TTinfo = splinePointcalc( numPaths, SecondZC, sampleData, numSplinePoints);

newExZC = TTinfo.exactZC;
newTTdiff = TTinfo.TTab;

%calculate RAW vog, new and old
orignalRawVog = VOG_calc( numPaths, Vos, PInfo, orTTdiff )';
newRawVog  = VOG_calc( numPaths, Vos, PInfo, newTTdiff )';

originalAvgVOG = mean(orignalRawVog(:))
newAvgVOG = mean(newRawVog(:))

%plots
%ooooo

xVals = [1:numPaths];
plot(xVals,orignalRawVog);
hold on;

plot(xVals,newRawVog);
hold on;

yLimVals(1:numPaths) = 0.006;
plot(xVals,yLimVals, 'r', 'LineWidth',3);
hold on;

legend('org peak ZC','new peak ZC', 'max VOG limit');
title('Second Pk vs third Pk Zerocross accuracy comparisson')
xlabel('numPath');
ylabel('velocity [m/s]');
hold on;

%Clear data
%oooooooooo

clear('all');

