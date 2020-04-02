function [ validPlot ] = plotAGC(currentMeterDir, fidLog, pathConfig, resultStdPaths, resultsPksPaths, resultsDiffPP, resultsDiffType, resultsDiffGeneral, resultsMinLim, resultsMaxLim, maxSTDdev, maxPeaks, maxDiffPP, maxDiffType, maxDiffGnrl, MinBnd, MaxBnd, AGCaveragePP, MinMaxBndPlt)
%initialise return parameter
validPlot = 0;

try
    pathConfig = pathConfig(2,:);

    plotName = 'AGC';

    [ numRows, numPaths] = size(AGCaveragePP);
    
    %create subfolder for test
     
    createDir(plotName, currentMeterDir, fidLog);
    currentMeterDir = strcat(currentMeterDir, '\', plotName);

    %merge results diff subtest to determine a faulty path
    faultyPaths(1,numPaths)=0;
    for i = 1:numPaths
       if resultStdPaths(1,i) | resultsPksPaths(1,i)  | resultsDiffPP(1,i) | resultsDiffType(1,i) | resultsDiffGeneral(1,i) | resultsMinLim(1,i) | resultsMaxLim(1,i) 
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
    ymax= 8000;

    %make different colors
    cc=color();

    %maak figuur
    f = figure();
    set(f,'Visible','off');                                 %command voor figuur niet te plotten op desktop


    title('AGC Limits & Deviation FAT ','FontWeight','bold', 'FontSize', 14);
    xlabel('Samples');
    ylabel('AGC [dB]');
    xlim([xmin,xmax]);
    ylim([ymin,ymax]);

    hold on;
    %plot AGC
    for i = 1: numPaths
        if faultyPaths(i)
            plot(xVals,AGCaveragePP(:,i),'--','Color',cc(i,:),'LineWidth', 1);
            hold on;
        else
            plot(xVals,AGCaveragePP(:,i),'Color',cc(i,:),'LineWidth', 1);
            hold on;
        end
    end
    
    %plot legend
    legend(pathConfig,'location','Eastoutside');
    hold on;

    %plot grenzen
    plot(xVals, MinMaxBndPlt,':', 'color', [1,0,0]);
    hold on;
    text(numRows * 0.85,MinBnd,' MinLimit');
    text(numRows * 0.85,MaxBnd,' MaxLimit');
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
    validTblMaxLim = testToCsv(currentMeterDir, fidLog, 'MaxAGC', 'max', resultsMaxLim, MaxBnd);


    %write to logfile
    if validTblSTD & validTblPKS & validTblDiffPP & validTblDiffTYPE & validTblDiffGNRL & validTblMinLim & validTblMaxLim
        WriteToLogFile(fidLog,'AGC Plot succesfully terminated');   
        validPlot = 1;
    else
        WriteToLogFile(fidLog,'AGC Plot succesfull, error in generating table(s)'); 
    end
catch err 
    WriteToLogFile(fidLog,'Error in plotting AGC');
    WriteToLogFile(fidLog,err.message);
end


end

