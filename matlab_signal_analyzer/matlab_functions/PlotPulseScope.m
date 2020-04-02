function [ validPlot, plotData ] = PlotPulseScope(pulseData,handles)
%plot pulses onto graphs
validPlot = 1;

%clear graphs gui
cla(handles.axSignal);
cla(handles.axSignalZoom);
cla(handles.axFFT);

try       
    signal = pulseData.nSig.signalNorm;
	posPeaks = pulseData.posPeakSig;
	negPeaks = pulseData.negPeakSig;
	detectionPoint = pulseData.posdetection;

    %zoominfo
    
    zoomStartX = min(posPeaks(2,2), negPeaks(2,2));
    zoomEndX = max(posPeaks(2,6), negPeaks(2,6));
    zoomWindowWidth = zoomEndX - zoomStartX;
    zoomStartX = round(zoomStartX - zoomWindowWidth*0.1);
    
    %save zoomstart for future replots
    plotData.zoomStart = zoomStartX
    
    zoomEndX = round(zoomEndX + zoomWindowWidth*0.05);
    zoomWindowWidth = zoomEndX - zoomStartX;
    
    zoomPosDetectionPoint = zeroCross(pulseData,1) - zoomStartX;
    zoomNegDetectionPoint = zeroCross(pulseData,0) - zoomStartX;
    
    zoomPosPeaks = posPeaks;
    zoomNegPeaks = negPeaks;
    
    zoomPosPeaks(2,:) = zoomPosPeaks(2,:) - zoomStartX;
    zoomNegPeaks(2,:) = zoomNegPeaks(2,:) - zoomStartX;
    
    zoomMax = 0;
   
    for z = 1:6
        temp = max(posPeaks(3,z));
        if temp > zoomMax
            zoomMax = temp;
        end
    end


    zoomMin = 0;
    for z = 1:6
        temp = min(negPeaks(3,z));
        if temp < zoomMin
            zoomMin = temp;
        end
    end

    zoomStartY = zoomMin * 1.005;

    if abs(zoomMin) > zoomMax
       zoomAmplitude = abs(zoomMin) * 1.005;
    else
       zoomAmplitude = zoomMax * 1.005;
    end

    zoomWindowHeight = (zoomMax + abs(zoomMin)) * 1.005;
    


    %GENERAL FIGURE
    %-------------------------------------------
    
    %get number of samples
    [ ~ ,samples ] = size(signal);
    t=1:samples;

    %generate zeros for x axis
    xAxis=zeros(samples,1);
    PosThresholdAx = handles.threshold/100 * ones(samples,1);
    NegThresholdAx = handles.threshold/100 * -1 * ones(samples,1);
    
    %define y-axis
    amplitude = 1.05;
    

    %plot samples
    axes(handles.axSignal);

    p1 = plot(t,signal(:),'-b');
    hold on;
    p2 = plot(t,xAxis,'k');  
    hold on;
    p3 = plot(t,PosThresholdAx,':k');
    hold on;
    p4 = plot(t,NegThresholdAx,':k');
    hold on;
    

    %generate general figure
    %set(handles.axSignal,'yticklabel',{[]}) 
   
    xlabel('Samples');
    ylabel('Amplitude');
    xlim([1,samples]);
    ylim([-amplitude,amplitude]);
    hold on;


    %mark zoomed area

    rectangle('Position',[zoomStartX,zoomStartY,zoomWindowWidth,zoomWindowHeight], 'EdgeColor', 'red', 'LineWidth', 1);
    hold on;                  

    %plot limits


    %eval(['maxPeakUsefull = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,2,2);']);
    %eval(['minPeakUsefull = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,4,2);']);
    %eval(['maxPeakTotal = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,2,3);']);
    %eval(['maxPeakTotalSample = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,1,3);']);
    %eval(['minPeakTotal = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,4,3);']);
    %eval(['minPeakTotalSample = processedData.t' num2str(i), TrLetter(j), '.pltLimits(1,3,3);']);

    
    maxPeakTotalSample = pulseData.pltLimits(1,3);
    maxPeakTotal = pulseData.pltLimits(2,3);
    minPeakTotalSample = pulseData.pltLimits(3,3);
    minPeakTotal = pulseData.pltLimits(4,3);
    
    plot(maxPeakTotalSample,maxPeakTotal , 'o', 'MarkerEdgeColor','r', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
    hold on;
    text(maxPeakTotalSample,maxPeakTotal + 0.03 ,'Pmax', 'FontWeight','bold', 'FontSize', 8)
    hold on;

    plot(minPeakTotalSample,minPeakTotal , 'o', 'MarkerEdgeColor','r', 'MarkerSize', 4, 'MarkerFaceColor', 'r');
    hold on;
    text(minPeakTotalSample,minPeakTotal - 0.03 ,'Nmin', 'FontWeight','bold', 'FontSize', 8)
    hold on;



    %ZOOM FIGURE
    %-------------------------------------------

    %get number of samples            
    t=1:zoomWindowWidth;

    %generate zeros for x axis
    xAxis=zeros(zoomWindowWidth,1);

    %define y-axis
    amplitude = zoomAmplitude;

    %generate general figure
    axes(handles.axSignalZoom);
    set(handles.axSignal,'yticklabel',{[]}) 
    set(handles.axSignal,'xticklabel',{[]})
    xlim([1,zoomWindowWidth]);
    ylim([-amplitude,amplitude]);
    hold on;


    %plot samples
    
    zoomSig = signal(zoomStartX + 1:zoomEndX);
    plot(t,zoomSig,'-r');
    hold on;


    plot(t,xAxis,'k');
    hold on;
    
        
    plot(zoomPosDetectionPoint, 0 , 'o', 'MarkerEdgeColor','b', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
    hold on;

    str1 = 'Pos. Det.';
    text(zoomPosDetectionPoint,0.1 ,str1, 'FontWeight','bold', 'FontSize', 8, 'color', 'b');
    hold on;
    
    plot(zoomNegDetectionPoint, 0 , 'o', 'MarkerEdgeColor','r', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
    hold on;

    str1 = 'Neg. Det.';
    text(zoomNegDetectionPoint,-0.1 ,str1, 'FontWeight','bold', 'FontSize', 8, 'color', 'r');
    hold on;

    %plot peaks

    for m = 2 : 5        
        plot(zoomPosPeaks(2,m), zoomPosPeaks(3,m) , 'o', 'MarkerEdgeColor','b', 'MarkerSize', 5, 'MarkerFaceColor', 'b');
        hold on;

        str1 = ['P', num2str(zoomPosPeaks(1,m))];
        text(zoomPosPeaks(2,m) + 2,zoomPosPeaks(3,m)+0.03 ,str1, 'FontWeight','bold', 'FontSize', 8)
        hold on;
    end

    for m = 2 : 5
        plot(zoomNegPeaks(2,m), zoomNegPeaks(3,m) , 'o', 'MarkerEdgeColor','r', 'MarkerSize', 5, 'MarkerFaceColor', 'r');
        hold on;

        str1 = ['N', num2str(zoomNegPeaks(1,m))];
        text(zoomNegPeaks(2,m) + 2,zoomNegPeaks(3,m)-0.03 ,str1, 'FontWeight','bold', 'FontSize', 8)
        hold on;
    end
    
        %FFT FIGURE
    %-------------------------------------------
    Fs = 30000000; %sample rate scope: estimation
    nfft = length(signal); %length of the time domain signal
    nfft2 = 2^nextpow2(nfft); %lenght of the signal in power of 2 for higher resolution
    ff = fft(signal, nfft2);
    fff = ff(1:nfft2/4);
    xfft = Fs*(0:nfft2/4-1)/nfft2;
    
    axes(handles.axFFT);
    hold on;
    
    plot(xfft,abs(fff));
    set(gca,'xticklabel',{[0,100,200,300,400,500,600,700,800]});
    xlabel('Frequency spectrum (KHz)');
    hold on;
    
    validPlot = 1;
  
    WriteToLogFile(handles.fidLog,'PlotPulseScope finished succesfully ');

catch err
    WriteToLogFile(handles.fidLog,'Error in PulseProcessScope CSV');
    WriteToLogFile(handles.fidLog,err.message) ;
    return;
end

end

