function [validPlot] = plotSNR(currentMeterDir, fidLog, pathConfig, resultStdPaths, resultsPksPaths, resultsDiffPP, resultsDiffType, resultsDiffGeneral, resultsMinLim, maxSTDdev, maxPeaks, maxDiffPP, maxDiffType, maxDiffGnrl, MinBnd, SNRaveragePP, MinBndPlt);
   
%initialise return parameter
validPlot = 0;

try
    pathConfig = pathConfig(2,:);

    plotName = 'SNR';

    [ numRows, numPaths] = size(SNRaveragePP);
    
    %create subfolder for test
     
    createDir(plotName, currentMeterDir, fidLog);
    currentMeterDir = strcat(currentMeterDir, '\', plotName);


    %merge results diff subtest to determine a faulty path
    faultyPaths(1,numPaths)=0;
    for i = 1:numPaths
       if resultStdPaths(1,i) | resultsPksPaths(1,i)  | resultsDiffPP(1,i) | resultsDiffType(1,i) | resultsDiffGeneral(1,i) | resultsMinLim(1,i) 
           faultyPaths(1,i) = 1;
       end
    end

    %generate different colors for all lines
    cc=hsv(numPaths);

    % generate x values
    xVals(1: numRows) = [1:numRows];

    %generate limits
    xmin = 1;
    xmax = numRows;
    ymin= 0;
    ymax= 7000;

    %make different colors
    cc=color();

    %maak figuur
    f = figure();
    set(f,'Visible','off');                                 %command voor figuur niet te plotten op desktop


    title('SNR Limits & Deviation FAT ','FontWeight','bold', 'FontSize', 14);
    xlabel('Samples');
    ylabel('SNR [dB]');
    xlim([xmin,xmax]);
    ylim([ymin,ymax]);

    hold on;
    %plot AGC
    for i = 1: numPaths
        if faultyPaths(i)
            plot(xVals,SNRaveragePP(:,i),'--','Color',cc(i,:),'LineWidth', 1);
            hold on;
        else
            plot(xVals,SNRaveragePP(:,i),'Color',cc(i,:),'LineWidth', 1);
            hold on;
        end
    end
    
    %plot legend
    legend(pathConfig,'location','Eastoutside');
    hold on;

    %plot grenzen
    plot(xVals, MinBndPlt,':', 'color', [1,0,0]);
    hold on;
    text(numRows * 0.85,MinBnd,' Lower Limit');

    hold on;

    fullPathPlotName = strcat(currentMeterDir, '\', plotName);
    saveas(gcf,fullPathPlotName,'png');
    close(f);
    

    %generate tables with results from subtests ktDiff
           
    validTblSTD = testToCsv(currentMeterDir, fidLog, 'STDdev', 'max', resultStdPaths, maxSTDdev);
    validTblPKS = testToCsv(currentMeterDir, fidLog, 'Peaks', 'PKS', resultsPksPaths, maxPeaks);
    validTblDiffPP = testToCsv(currentMeterDir, fidLog, 'LimitsPP', 'max', resultsDiffPP, maxDiffPP);
    validTblDiffTYPE = testToCsv(currentMeterDir, fidLog, 'LimitsType', 'max', resultsDiffType, maxDiffType);
    validTblDiffGNRL = testToCsv(currentMeterDir, fidLog, 'LimitsGeneral', 'max', resultsDiffGeneral, maxDiffGnrl);
    validTblMinLim = testToCsv(currentMeterDir, fidLog, 'MinAGC', 'max', resultsMinLim, MinBnd);
    
    %write to logfile
    if validTblSTD & validTblPKS & validTblDiffPP & validTblDiffTYPE & validTblDiffGNRL & validTblMinLim 
        WriteToLogFile(fidLog,'SNR Plot succesfully terminated');   
        validPlot = 1;
    else
        WriteToLogFile(fidLog,'SNR Plot succesfull, error in generating table(s)'); 
    end
catch err 
    WriteToLogFile(fidLog,'Error in plotting SNR');
    WriteToLogFile(fidLog,err.message);
end


end

