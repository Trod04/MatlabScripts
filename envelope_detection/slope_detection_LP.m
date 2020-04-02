function [ outputData ] = slope_detection_LP(rawSignal,slope_flat_limit)
%-------------------------------------------------------------------------
%Author: TROD
%Date modified: 13/02/2020
%
%Description:
%
%find max peak, calculate slope data 2 peaks before/after and convert to
%slope direction 1 = rising, 0 = flat (with tolerance factor) and -1 =
%falling
%-------------------------------------------------------------------------

%input signal for testing 
%-------------------------------------------------------------------------
% strTestSignal = 'C:\Users\H162437\OneDrive for Business\documents_onedrive\MATLAB\envelope_detection\signal_sample.csv';
% rawSignal = importdata(strTestSignal);
% rawSignal = rawSignal.data';

boolPlot = 0;

%input pars DSP
%-------------------------------------------------------------------------

maxSampleDiffCL = 3;

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

%find peaks 
%-------------------------------------------------------------------------

%find samples between peaks useful signal
[posPks,posLocs] = findpeaks(rawSignal);
[negPks,negLocs] = findpeaks(-rawSignal);
negPks = -negPks;

maxValPeak = max(posPks);
minValPeak = min(negPks);

maxPkLoc = find(posPks == maxValPeak);
minPkLoc = find(negPks == minValPeak);

%check if there are no 2 max/min peak values --> when the case select first max
%peak
[~,sizeMaxP] = size(maxPkLoc);
[~,sizeMinP] = size(minPkLoc);

if sizeMaxP > 1
    maxPkLoc = maxPkLoc(1);
end

if sizeMinP > 1
    minPkLoc = minPkLoc(1);
end

%compose xy coordinates 2 peaks before after local maxima/minima
%-------------------------------------------------------------------------
%posivive peak coordinates

startPosPeaks = maxPkLoc - 3;
xyPositive = 0;

for i = 1:5
    xCoordinate = posLocs(startPosPeaks + i);
    yCoordinate = posPks(startPosPeaks + i);
    
    if xyPositive == 0
        xyPositive = [xCoordinate; yCoordinate];
    else
        inject = [xCoordinate; yCoordinate];        
        xyPositive = [xyPositive , inject];
    end    
end

%negative peak coordinates

startNegPeaks = minPkLoc - 3;
xyNegative = 0;

for i = 1:5
    xCoordinate = negLocs(startNegPeaks + i);
    yCoordinate = negPks(startNegPeaks + i);
    
    if xyNegative == 0
        xyNegative = [xCoordinate; yCoordinate];
    else
        inject = [xCoordinate; yCoordinate];        
        xyNegative = [xyNegative , inject];
    end    
end

%calculate slopes between positive and negative peaks and determine slope
%direction
%-------------------------------------------------------------------------
%positive slopes

posSlopes = 0;

for i = 1:4
    currentSlope = (xyPositive(2,i+1) - xyPositive(2,i))/(xyPositive(1,i+1) - xyPositive(1,i));
    
    if posSlopes == 0
        posSlopes = currentSlope;
    else
        posSlopes = [posSlopes, currentSlope];
    end   
end

posSlopeDir = -2;

for i = 1:4
    if abs(posSlopes(i)) < slope_flat_limit
        currentDir = 0;
    else
        if posSlopes(i) > 0
            currentDir = 1;
        else
            currentDir = -1;
        end        
    end
    
    if posSlopeDir == -2
        posSlopeDir = currentDir;
    else
        posSlopeDir = [posSlopeDir, currentDir];
    end
end

%negative slopes

negSlopes = 0;

for i = 1:4
    currentSlope = (xyNegative(2,i+1) - xyNegative(2,i))/(xyNegative(1,i+1) - xyNegative(1,i));
    
    if negSlopes == 0
        negSlopes = currentSlope;
    else
        negSlopes = [negSlopes, currentSlope];
    end   
end

negSlopeDir = -2;

for i = 1:4
    if abs(negSlopes(i)) < slope_flat_limit
        currentDir = 0;
    else
        if negSlopes(i) > 0
            currentDir = 1;
        else
            currentDir = -1;
        end        
    end
    
    if negSlopeDir == -2
        negSlopeDir = currentDir;
    else
        negSlopeDir = [negSlopeDir, currentDir];
    end
end

%determine position centerline signal
%-------------------------------------------------------------------------
%combine positive and negative slopeDirection  and xy peak coordinates 
%for easy itteration
SlopeDirCombined = [posSlopeDir; negSlopeDir];
PeakxyCombined = [xyPositive; xyNegative];

%find number of flat points in signal, positive and negative
zeroPoints = zeros(2,1);

for i = 1:2
    currentSet = SlopeDirCombined(i,:);
    [~,zeroPoints(i,1)] = size(find(currentSet == 0));    
end
    
%if no or multiple flat points are found , 
%local maximum/minimum == centerline signal
centerLineCoordinates = zeros(2,2);

for i = 1:2
    if zeroPoints(i,1) == 0 || zeroPoints(i,1) == 2
        xCenterline = PeakxyCombined(i*2-1,3);
        yCenterLine = PeakxyCombined(i*2,3) * 1.1; %only important for plotting;
    else
        %find out where flat point is located position 2 = peak before max,
        %position 3 = peak after max
        flatPosition = find(SlopeDirCombined(i,:) == 0);
        
        if flatPosition == 2
            xCenterline = round((PeakxyCombined(i*2-1,3) + PeakxyCombined(i*2-1,2))/2); %average position between flat peaks;
            yCenterLine = PeakxyCombined(i*2,3) * 1.1; %only important for plotting;
        else
            xCenterline =  round((PeakxyCombined(i*2-1,3) + PeakxyCombined(i*2-1,4))/2); %average position between flat peaks;
            yCenterLine = PeakxyCombined(i*2,3) * 1.1; %only important for plotting;
        end        
    end
    
    centerLineCoordinates(:,i) = [xCenterline; yCenterLine];
end

%calculate average centerline x position and check if centerline
%positive/negative inversion deviation limit is not exceeded
%-------------------------------------------------------------------------

CLxval = mean(centerLineCoordinates(1,:));

if abs(centerLineCoordinates(1,1)-centerLineCoordinates(1,2)) > maxSampleDiffCL
    boolSelfTest = 0;
else
    boolselfTest = 1;
end


%gather output data
%-------------------------------------------------------------------------

outputData.CLxval = CLxval;
outputData.centerLineCoordinates = centerLineCoordinates;
outputData.SlopeDirCombined = SlopeDirCombined;
outputData.PeakxyCombined = PeakxyCombined;

%plots
%-------------------------------------------------------------------------


if boolPlot == 1
    %signals
    %oooooooooo
    t = 1:numSamples;
    h = figure();

    plot_param = {'Color', [0 0 0.6],'Linewidth',1.5};
    plot(t, rawSignal, plot_param{:});
    hold on;
    ylim([-1.5 1.5]);

    %Lines
    %oooooo

    %plot slopes 
    plot_param = {'Color', [0 0.6 0],'Linewidth',1.5};

    for i = 1:2
        for y = 1:4
            x1 = PeakxyCombined(i*2-1,y);
            x2 = PeakxyCombined(i*2-1,y+1);
            y1 = PeakxyCombined(i*2,y);
            y2 = PeakxyCombined(i*2,y+1);
            plot([x1 x2],[y1 y2], plot_param{:});
            hold on;
        end
    end

    %plot centerline

    plot_param = {'--', 'Color', [1 0 0],'Linewidth', 0.25};
    plot([CLxval CLxval],[1.5 -1.5], plot_param{:});
    hold on;

    %Makers
    %oooooooooo

    plot_param = {'x','MarkerEdgeColor',[0 0 0],'MarkerSize',6, 'LineWidth',2};
    plot(centerLineCoordinates(1,1),1.3,plot_param{:});
    plot(centerLineCoordinates(1,2),-1.3,plot_param{:});
    hold on;

    %Mark slope directions
    %ooooooooooooooooooooo

    for i = 1:2
        for y = 1:4
            x1 = (PeakxyCombined(i*2-1,y) + PeakxyCombined(i*2-1,y+1))/2-3; 
            y1 = (PeakxyCombined(i*2,y) + PeakxyCombined(i*2,y+1))/2*1.1; 

            switch SlopeDirCombined(i,y)
                case -1
                    text(x1, y1 ,'$\searrow$','Interpreter','latex', 'FontWeight', 'bold');
                    hold on;
                case 0
                    text(x1, y1 ,'$\rightarrow$','Interpreter','latex', 'FontWeight', 'bold');
                    hold on;
                case 1
                    text(x1, y1 ,'$\nearrow$','Interpreter','latex', 'FontWeight', 'bold');
                    hold on;

            end
        end
    end
end


end

